local vector2 = import("./libs/vector")
local Field = import("./Field")

local Ball = class()

function Ball:ctor(match)
    self.match = match
    self.position = vector2.clone(vector2.zero)
    self.height = 0
    self.owner = nil
    self.isFree = false
    self.flyStartTime = 0
    self.flyStartPosition = vector2.clone(vector2.zero)
    self.flyTargetPosition = vector2.clone(vector2.zero)
    self.flyDirection = vector2.clone(vector2.zero)
    self.flyDistance = 0
    self.flyDeceleration = 0
    self.flyDuration = 0
    self.flyStartSpeed = 0
    self.flyTargetSpeed = 0
    self.flyType = "Ground"
    self.objective = "Free"
    self.lastTouchAthlete = nil
    self.preTouchAthlete = nil
    self.passGroundSpeed = 12.5
    self.passHighSpeed = 18

    self.nextTask = nil

    self.outOfFieldPoint = nil
    self.events = {
        setOwner = event.new()
    }

    self.output = nil
    self.outputAnimation = nil
    self.nextOutput = nil
    self.nextPosition = nil
    self.nextHeight = nil
end

local BallTask = class()
function BallTask:ctor(config)
    config = config or { }
    for k, v in pairs(config) do
        self[k] = v
    end
end

Ball.Steal = class(BallTask, "Steal")
Ball.Foul = class(BallTask, "Foul")
Ball.Pass = class(BallTask, "Pass")
Ball.PassAndIntercept = class(BallTask, "PassAndIntercept")
Ball.ShootAndSave = class(BallTask, "ShootAndSave")

function Ball:getPassSpeed(athlete, targetPosition, type, isLeadPass)
    if isLeadPass then
        if type == "Ground" then
            return math.max(7, (-0.008 * vector2.sqrdist(athlete.position, targetPosition) + 10))
        elseif type == "High" then
            return math.clamp(0.4 * vector2.dist(athlete.position, targetPosition) + 3, 12, 19)
        else
            return 0
        end
    end

    local baseSpeed = type == "Ground" and self.passGroundSpeed or self.passHighSpeed

    if Field.isInHighSpeedPassArea(targetPosition, athlete.team:getSign()) then
        return baseSpeed * 1.3
    end

    return baseSpeed
end

function Ball:getCrossLowSpeed(ballFlyStartPosition, targetPosition, isLeadPass)
    if isLeadPass then
        return math.clamp(0.8 * vector2.dist(ballFlyStartPosition, targetPosition) + 10, 27.5, 32.5)
    end

    return self.passHighSpeed * 1.5
end

function Ball:setLastTouch(athlete)
    if self.lastTouchAthlete ~= nil and self.lastTouchAthlete ~= athlete then
        self.preTouchAthlete = self.lastTouchAthlete
    end
    self.lastTouchAthlete = athlete
end

function Ball:setOwner(athlete, isSaveBounce)
    if self.owner ~= nil then
        self.owner:clearManualOperate()
    end

    self.owner = athlete
    self.outputOwner = athlete

    if athlete then
        self.isFree = false
        self.position = athlete.position

        self:setLastTouch(athlete)

        if not isSaveBounce then
            self.events.setOwner:trigger(self, athlete)
        end
    end
end

function Ball:flyTo(startTime, startPosition, deceleration, targetPosition, targetSpeed, type, objective)
    local prediction = self:predictFlyTo(startTime, startPosition, deceleration, targetPosition, targetSpeed, type)
    for k, v in pairs(prediction) do
        self[k] = v
    end
    assert(self.owner)
    self.owner.graspBall = nil
    self.owner:clearManualOperate()
    self.outputOwner = self.owner
    self.owner = nil
    self.isFree = false
    self.objective = objective
end

function Ball:predictFlyTo(startTime, startPosition, deceleration, targetPosition, targetSpeed, type)
    local prediction = {}
    prediction.flyStartTime = startTime
    prediction.flyStartPosition = startPosition
    prediction.flyTargetPosition = targetPosition
    prediction.flyDirection = vector2.norm(targetPosition - startPosition)
    prediction.flyDistance = vector2.dist(startPosition, targetPosition)
    prediction.flyDeceleration = deceleration
    prediction.flyDuration = self:predictFlyDuration(deceleration, targetSpeed, prediction.flyDistance)
    prediction.flyStartSpeed = prediction.flyDistance / prediction.flyDuration + 0.5 * deceleration * prediction.flyDuration
    prediction.flyTargetSpeed = prediction.flyDistance / prediction.flyDuration - 0.5 * deceleration * prediction.flyDuration
    prediction.flyType = type
    return prediction
end

function Ball:predictFlyDuration(deceleration, targetSpeed, flyDistance)
    return math.roundWithMinStep(math.cmpf(deceleration, 0) == 0
            and (flyDistance / targetSpeed)
            or (-2 * targetSpeed + math.sqrt(4 * targetSpeed ^ 2 + 8 * deceleration * flyDistance)) / (2 * deceleration),
            0.1)
end

function Ball.predictPassSpeed(flyDuration, deceleration, flyDistance)
    return flyDistance / flyDuration - flyDuration * deceleration / 2
end

function Ball:calculateFlyStartSpeed(flyEndSpeed, deceleration, startPosition, endPosition)
    return math.sqrt(flyEndSpeed * flyEndSpeed + 2 * deceleration * vector2.dist(startPosition, endPosition))
end

function Ball:freeFly(startTime, startPosition, startSpeed, deceleration, direction, type)
    assert(self.owner)
    self.owner = nil
    self.isFree = true
    self.objective = "Free"
    self.flyStartTime = startTime
    self.flyStartPosition = startPosition
    self.flyDirection = direction
    local estimatedFlyDuration = math.cmpf(deceleration, 0) == 0 and math.huge or (startSpeed / deceleration)
    self.flyDuration = math.roundWithMinStep(estimatedFlyDuration, 0.1)
    self.flyDeceleration = startSpeed / self.flyDuration
    self.flyDistance = startSpeed * self.flyDuration - 0.5 * self.flyDeceleration * self.flyDuration ^ 2
    self.flyTargetPosition = startPosition + direction * self.flyDistance
    self.flyStartSpeed = startSpeed
    self.flyTargetSpeed = 0
    self.flyType = type
end

function Ball:predictPosition(timeStamp)
    local deltaTime = timeStamp - self.flyStartTime
    local deltaDistance = self.flyStartSpeed * deltaTime - 0.5 * self.flyDeceleration * deltaTime ^ 2

    local ret = self.flyStartPosition + self.flyDirection * deltaDistance
    if self.objective == "Pass" then
        ret.x = math.clamp(ret.x, math.min(self.flyStartPosition.x, self.flyTargetPosition.x), math.max(self.flyStartPosition.x, self.flyTargetPosition.x))
        ret.y = math.clamp(ret.y, math.min(self.flyStartPosition.y, self.flyTargetPosition.y), math.max(self.flyStartPosition.y, self.flyTargetPosition.y))
    end

    return ret
end

function Ball:predictHeight(timeStamp)
    if self.flyType == "Ground" then
        return 0
    end

    local deltaTime = timeStamp - self.flyStartTime
    local g = 10
    return 0.5 * g * self.flyDuration * deltaTime - 0.5 * g * deltaTime ^ 2
end

function Ball:update(timeStamp)
    if self.match.frozenType ~= "CornerKick" and self.match.frozenType ~= "WingDirectFreeKick"
        and self.match.frozenType ~= "CenterDirectFreeKick" and self.match.frozenType ~= "PenaltyKick" then
        self.position = self.owner == nil and self:predictPosition(timeStamp) or self.owner.position
    end
    self.height = self.owner == nil and self:predictHeight(timeStamp) or 0
    if self.lastTouchAthlete ~= nil then
        self.lastTouchAthlete.team.possession = self.lastTouchAthlete.team.possession + 1
    end
end

function Ball:clearOutput()
    self.output = nil
    self.outputAnimation = nil
    self.outputOwner = nil
    self.nextOutput = nil
end

if jit then jit.on(Ball.clearOutput, true) end

function Ball:resetBallStateOnBallOut()
    self.flyStartTime = 0
    self.flyDuration = 0
    self.flyStartPosition = vector2.clone(vector2.zero)
    self.flyTargetPosition = vector2.clone(vector2.zero)
end

return Ball

if jit then jit.off(true, true) end

local Athlete = import("./Core")
local Actions = import("../actions/Actions")
local AIUtils = import("../AIUtils")
local Ball = import("../Ball")
local Field = import("../Field")
local vector2 = import("../libs/vector")
local Animations = import("../animations/Animations")

local FixedGravity = 19.6
local ProjectileRetardFactor = 2

local function saveBounce(athlete)
    local ball = athlete.match.ball
    local bounceRangeX = math.range(Field.halfGoalWidth * 2, Field.halfWidth * 0.8)
    local moveDirection = vector2.vyrotate(athlete.currentAnimation.animationInfo.firstTouchBallPosition, athlete.bodyDirection)
    local targetXSign = math.sign(moveDirection.x)
    if math.cmpf(targetXSign, 0) == 0 then
        targetXSign = 1
    end
    local targetX = targetXSign * math.randomInRange(bounceRangeX.min, bounceRangeX.max)
    local bounceTarget = vector2.new(targetX, athlete.team.goal.center.y)
    local flyType = "Ground"

    -- 此时门将可能还没有移动到预定扑球点（仅发生在门将预期扑球时间=射门出球时间）
    -- 如果门将恰好在底线之外，修正弹飞起点到球场内部
    local bounceStartPosition = athlete.position
    if not Field.isInside(bounceStartPosition) or math.cmpf(math.abs(bounceStartPosition.y), Field.halfLength) == 0 then
        bounceStartPosition = vector2.new(bounceStartPosition.x, athlete.team:getSign() * (Field.halfLength - 0.1))
    end

    local bounceDirection = vector2.norm(bounceTarget - bounceStartPosition)
    local deceleration = AIUtils.getDeceleration(flyType)
    local flyStartSpeed = math.max(ball.flyTargetSpeed * 0.67, ball:calculateFlyStartSpeed(10, deceleration, bounceStartPosition, bounceTarget))
    ball:freeFly(athlete.match.currentTime, bounceStartPosition, flyStartSpeed, deceleration, bounceDirection, flyType)
end

function Athlete:startSave()
    local task = self.match.ball.nextTask

    -- Update outputActionStatus for status output
    if self.outputActionStatus == nil then
        local saveAction = Actions.Action.new()
        saveAction.name = "Save"
        saveAction.savePosition = task.savePosition
        saveAction.savePositionHeight = task.savePositionHeight
        saveAction.shootResult = task.shootResult
        self.outputActionStatus = saveAction
    end

    self.animationQueue = {}
    local animation = self:pushAnimation(task.saveAnimation, task.shootResult == AIUtils.shootResult.catch or task.shootResult == AIUtils.shootResult.saveBounce, nil, true, true)
    animation.type = "Save"
end

function Athlete:save()
    local task = self.match.ball.nextTask

    if task.shootResult == AIUtils.shootResult.catch then
        self.match.ball:setOwner(self)
        self.graspBall = true
        self:judgePatronSaint()
        self:judgePonytailCaptainEx1()
        self:judgeTheSoulOfTheMatador()
    elseif task.shootResult == AIUtils.shootResult.saveBounce then
        self.match.ball:setOwner(self, true)
        saveBounce(self)
        self:judgePatronSaint()
        self:judgePonytailCaptainEx1()
        self:judgeTheSoulOfTheMatador()
    end
end

local function easeBezierCurve(startPoint, controlPoint, endPoint, percent)
    local percentLeft = 1 - percent
    return percentLeft * percentLeft * startPoint + 2 * percent * percentLeft * controlPoint + percent * percent * endPoint
end

local function easeBezierCurvePercentBeforeWindDrag(duration, percent)
    local WIND_DRAG_COEFFICIENT = -0.65
    local factor = WIND_DRAG_COEFFICIENT * duration
    return math.log(percent * (math.exp(factor) - 1) + 1) / factor
end

local function easeVariablyRetardedVerticalUpwardProjectile(startHeight, initialSpeed, time)
    local p = ProjectileRetardFactor * FixedGravity
    local speed = (p + initialSpeed) * math.exp(-time / ProjectileRetardFactor) - p
    return math.max(0.1, ProjectileRetardFactor * (initialSpeed - speed - FixedGravity * time) + startHeight)
end

local function calculateInitialVerticalSpeed(startHeight, endHeight, flyDuration)
    if math.cmpf(startHeight, 0.1) == 0 and math.cmpf(endHeight, 0.1) == 0 then
        return 0
    else
        local h = endHeight - startHeight
        return -ProjectileRetardFactor * FixedGravity
            + (FixedGravity * flyDuration + h / ProjectileRetardFactor) / (1 - math.exp(-flyDuration / ProjectileRetardFactor))
    end
end

function Athlete.predictBallPositionHeight(percent, flyDuration, startBallPositionHeight, endBallPositionHeight)
    local v0 = calculateInitialVerticalSpeed(startBallPositionHeight, endBallPositionHeight, flyDuration)
    local time = percent * flyDuration
    return easeVariablyRetardedVerticalUpwardProjectile(startBallPositionHeight, v0, time)
end

function Athlete.predictBallPositionOnCertainTime(percent, flyDuration, startBallPosition, startBallPositionHeight, controlBallPosition, endBallPosition, endBallPositionHeight)
    local x = easeBezierCurve(startBallPosition.x, controlBallPosition.x, endBallPosition.x, percent)
    local y = easeBezierCurve(startBallPosition.y, controlBallPosition.y, endBallPosition.y, percent)

    local v0 = calculateInitialVerticalSpeed(startBallPositionHeight, endBallPositionHeight, flyDuration)
    local time = easeBezierCurvePercentBeforeWindDrag(flyDuration, percent) * flyDuration
    local height = easeVariablyRetardedVerticalUpwardProjectile(startBallPositionHeight, v0, time)

    return vector2.new(x, y), height
end

function Athlete.recalculateVerticalEndPoint(startBallHeight, originEndBallHeight, saveBallPositionHeight, saveTime, newFlyDuration)
    local v0 = nil
    if math.cmpf(startBallHeight, 0.1) == 0 and math.cmpf(originEndBallHeight, 0.1) == 0 then
        v0 = 0
    else
        v0 = calculateInitialVerticalSpeed(startBallHeight, saveBallPositionHeight, saveTime)
    end
    return easeVariablyRetardedVerticalUpwardProjectile(startBallHeight, v0, newFlyDuration)
end

-- shoot result: 0-goal, 1-catch, 2-save out, 3-miss
function Athlete.chooseSaveAction(shootResult, saveBallPosition, saveBallPositionHeight, gkPosition, gkDirection)
    local offset = saveBallPosition - gkPosition
    local sangle = vector2.sangle(gkDirection, vector2.forward)
    offset = vector2.rotate(offset,  sangle)

    local xDis = math.abs(offset.x)
    local sign = math.sign(offset.x)
    local choice = nil

    if shootResult == AIUtils.shootResult.catch then
        if math.cmpf(xDis, 0.6) <= 0 then
            if math.cmpf(saveBallPositionHeight, 0.7) < 0 then
                choice = 'E_B003'
            elseif math.cmpf(saveBallPositionHeight, 1.4) < 0 then
                choice = 'E_B002'
            elseif math.cmpf(saveBallPositionHeight, 1.9) < 0 then
                choice = 'E_B011_1'
            elseif math.cmpf(saveBallPositionHeight, 2.4) < 0 then
                choice = 'E_B011'
            else
                choice = 'E_B001'
            end
        else
            if math.cmpf(saveBallPositionHeight, 0.6) < 0 then
                if math.cmpf(xDis, 2.5) <= 0 then
                    if sign > 0 then
                        choice = 'E_B006'
                    else
                        choice = 'E_B006_1'
                    end
                else
                    if sign > 0 then
                        choice = 'E_B006_2'
                    else
                        choice = 'E_B006_3'
                    end
                end
            elseif math.cmpf(saveBallPositionHeight, 1.3) < 0 then
                if math.cmpf(xDis, 2.2) <= 0 then
                    if sign > 0 then
                        choice = 'E_B009'
                    else
                        choice = 'E_B009_1'
                    end
                else
                    if sign > 0 then
                        choice = 'E_B008'
                    else
                        choice = 'E_B008_1'
                    end
                end
            elseif math.cmpf(saveBallPositionHeight, 1.9) < 0 then
                if math.cmpf(xDis, 2.5) <= 0 then
                    if sign > 0 then
                        choice = 'E_B005_8'
                    else
                        choice = 'E_B005_9'
                    end
                else
                    if sign > 0 then
                        choice = 'E_B005_6'
                    else
                        choice = 'E_B005_7'
                    end
                end
            else
                if math.cmpf(xDis, 1.6) <= 0 then
                    if sign > 0 then
                        choice = 'E_B004'
                    else
                        choice = 'E_B004_1'
                    end
                else
                    if sign > 0 then
                        choice = 'E_B010'
                    else
                        choice = 'E_B010_1'
                    end
                end
            end
        end
    elseif shootResult == AIUtils.shootResult.shootWide then
        if math.cmpf(xDis, 1) <= 0 then
            if sign > 0 then
                choice = 'E_S005_1'
            else
                choice = 'E_S005'
            end
        elseif math.cmpf(xDis, 2.6) <= 0 then
            if sign > 0 then
                choice = 'E_S006_1'
            else
                choice = 'E_S006'
            end
        else
            if math.cmpf(saveBallPositionHeight, 0.8) < 0 then
                if sign > 0 then
                    choice = 'E_C006'
                else
                    choice = 'E_C006_2'
                end
            elseif math.cmpf(saveBallPositionHeight, 1.2) < 0 then
                if sign > 0 then
                    choice = 'E_C012'
                else
                    choice = 'E_C012_1'
                end
            else
                if sign > 0 then
                    choice = 'E_C010'
                else
                    choice = 'E_C010_1'
                end
            end
        end
    elseif shootResult == AIUtils.shootResult.saveBounce then
        if math.cmpf(xDis, 0.6) <= 0 then
            if math.cmpf(saveBallPositionHeight, 0.2) < 0 then
                if sign > 0 then
                    choice = 'E_C003'
                else
                    choice = 'E_C003_1'
                end
            elseif math.cmpf(saveBallPositionHeight, 1.5) < 0 then
                choice = 'E_C002_1'
            elseif math.cmpf(saveBallPositionHeight, 1.8) < 0 then
                choice = 'E_C002'
            else
                choice = 'E_C001'
            end
        else
            if math.cmpf(saveBallPositionHeight, 0.4) < 0 then
                if math.cmpf(xDis, 2.3) <= 0 then
                    if sign > 0 then
                        choice = 'E_C006_1'
                    else
                        choice = 'E_C006_3'
                    end
                else
                    if sign > 0 then
                        choice = 'E_C009'
                    else
                        choice = 'E_C009_1'
                    end
                end
            elseif math.cmpf(saveBallPositionHeight, 0.8) < 0 then
                if math.cmpf(xDis, 2.7) <= 0 then
                    if sign > 0 then
                        choice = 'E_C006'
                    else
                        choice = 'E_C006_2'
                    end
                else
                    if sign > 0 then
                        choice = 'E_C011'
                    else
                        choice = 'E_C011_1'
                    end
                end
            elseif math.cmpf(saveBallPositionHeight, 1.2) < 0 then
                if math.cmpf(xDis, 2.1) <= 0 then
                    if sign > 0 then
                        choice = 'E_C012'
                    else
                        choice = 'E_C012_1'
                    end
                else
                    if sign > 0 then
                        choice = 'E_C015'
                    else
                        choice = 'E_C015_1'
                    end
                end
            elseif math.cmpf(saveBallPositionHeight, 1.7) < 0 then
                if math.cmpf(xDis, 2) <= 0 then
                    if sign > 0 then
                        choice = 'E_C010'
                    else
                        choice = 'E_C010_1'
                    end
                else
                    if sign > 0 then
                        choice = 'E_C005'
                    else
                        choice = 'E_C005_1'
                    end
                end
            elseif math.cmpf(saveBallPositionHeight, 2.3) < 0 then
                if math.cmpf(xDis, 1.8) <= 0 then
                    if sign > 0 then
                        choice = 'E_C004_1'
                    else
                        choice = 'E_C004_3'
                    end
                elseif math.cmpf(xDis, 2.4) <= 0 then
                    if sign > 0 then
                        choice = 'E_C013'
                    else
                        choice = 'E_C013_1'
                    end
                else
                    if sign > 0 then
                        choice = 'E_C014'
                    else
                        choice = 'E_C014_1'
                    end
                end
            else
                if math.cmpf(xDis, 2.1) <= 0 then
                    if sign > 0 then
                        choice = 'E_C004'
                    else
                        choice = 'E_C004_2'
                    end
                else
                    if sign > 0 then
                        choice = 'E_C007'
                    else
                        choice = 'E_C007_1'
                    end
                end
            end
        end
    elseif shootResult == AIUtils.shootResult.goal then
        if math.cmpf(xDis, 0.9) <= 0 then
            if math.cmpf(saveBallPositionHeight, 0.2) < 0 then
                if sign > 0 then
                    choice = 'E_C003' -- 0.4
                else
                    choice = 'E_C003_1'
                end
            elseif math.cmpf(saveBallPositionHeight, 1.5) < 0 then
                choice = 'E_C002_1'
            elseif math.cmpf(saveBallPositionHeight, 1.8) < 0 then
                choice = 'E_C002'
            else
                choice = 'E_C001'
            end
        else
            if math.cmpf(saveBallPositionHeight, 0.4) < 0 then
                if math.cmpf(xDis, 2.4) <= 0 then
                    if sign > 0 then
                        choice = 'E_C006_1' -- 1.5
                    else
                        choice = 'E_C006_3'
                    end
                else
                    if sign > 0 then
                        choice = 'E_C009' -- 3.4
                    else
                        choice = 'E_C009_1'
                    end
                end
            elseif math.cmpf(saveBallPositionHeight, 0.8) < 0 then
                if math.cmpf(xDis, 3) <= 0 then
                    if sign > 0 then
                        choice = 'E_C006' -- 2.3
                    else
                        choice = 'E_C006_2'
                    end
                else
                    if sign > 0 then
                        choice = 'E_C011' -- 3.8
                    else
                        choice = 'E_C011_1'
                    end
                end
            elseif math.cmpf(saveBallPositionHeight, 1.2) < 0 then
                if math.cmpf(xDis, 2.7) <= 0 then
                    if sign > 0 then
                        choice = 'E_C012' -- 1.8
                    else
                        choice = 'E_C012_1'
                    end
                else
                    if sign > 0 then
                        choice = 'E_C015' -- 3.6
                    else
                        choice = 'E_C015_1'
                    end
                end
            elseif math.cmpf(saveBallPositionHeight, 1.7) < 0 then
                if math.cmpf(xDis, 2.2) <= 0 then
                    if sign > 0 then
                        choice = 'E_C010' -- 1.5
                    else
                        choice = 'E_C010_1'
                    end
                else
                    if sign > 0 then
                        choice = 'E_C005' -- 2.8
                    else
                        choice = 'E_C005_1'
                    end
                end
            elseif math.cmpf(saveBallPositionHeight, 2.3) < 0 then
                if math.cmpf(xDis, 2) <= 0 then
                    if sign > 0 then
                        choice = 'E_C004_1' -- 1.8
                    else
                        choice = 'E_C004_3'
                    end
                elseif math.cmpf(xDis, 2.8) <= 0 then
                    if sign > 0 then
                        choice = 'E_C013' -- 2.3
                    else
                        choice = 'E_C013_1'
                    end
                else
                    if sign > 0 then
                        choice = 'E_C014' -- 3.2
                    else
                        choice = 'E_C014_1'
                    end
                end
            else
                if math.cmpf(xDis, 2.4) <= 0 then
                    if sign > 0 then
                        choice = 'E_C004_1' --E_C004 1.4
                    else
                        choice = 'E_C004_3' --E_C004_2
                    end
                else
                    if sign > 0 then
                        choice = 'E_C007' -- 3.4
                    else
                        choice = 'E_C007_1'
                    end
                end
            end
        end
    end
    return choice, offset
end

local function choosePreSaveAction(originSaveTime, saveFTBTime, offset)
    local moveTime = math.roundWithMinStep(originSaveTime - saveFTBTime, TIME_STEP)
    local moveAction = nil
    if math.sign(offset.x) > 0 then
        moveAction = 'E_R003_2'
    else
        moveAction = 'E_R004_2'
    end

    local animation = clone(Animations.RawData[moveAction])
    animation.time = moveTime
    animation.transition = math.round(moveTime / TIME_STEP)
    animation.totalFrame = animation.transition + 1

    return animation, moveTime
end

function Athlete.calculateTimePercentAtSavePosition(startBallPosition, controlBallPosition, targetBallPosition, gkPosition, gkForward)
    local percent = -1
    local a, b, c

    if math.sign(gkForward.y) ~= 0 then
        local _a = -gkForward.x / gkForward.y
        local _b = (gkForward.x * gkPosition.x + gkForward.y * gkPosition.y) / gkForward.y
        local k0 = startBallPosition.y - _a * startBallPosition.x
        local k1 = controlBallPosition.y - _a * controlBallPosition.x
        local k2 = targetBallPosition.y - _a * targetBallPosition.x
        a = k0 - 2 * k1 + k2
        b = 2 * (k1 - k0)
        c = k0 - _b
    else
        a = startBallPosition.x - 2 * controlBallPosition.x + targetBallPosition.x
        b = 2 * (controlBallPosition.x - startBallPosition.x)
        c = startBallPosition.x - gkPosition.x;
    end

    if math.sign(a) ~= 0 then
        local sqr = math.sqrt(b * b - 4 * a * c)
        local t1 = (-b + sqr) / (2 * a)
        local t2 = (-b - sqr) / (2 * a)
        if math.cmpf(t1, 0) >= 0 and math.cmpf(t1, 1) <= 0 then
            percent = t1
        end
        if math.cmpf(t2, 0) >= 0 and math.cmpf(t2, 1) <= 0 then
            percent = math.max(t2, percent)
        end
    elseif math.sign(b) ~= 0 then
        local t1 = - c / b
        if math.cmpf(t1, 0) >= 0 and math.cmpf(t1, 1) <= 0 then
            percent = t1
        end
    end
    return percent
end

function Athlete.adjustBodyDirectionBySaveBallPosition(saveBallPosition, gkPosition, originForward)
    local forward = originForward
    local saveOffset = vector2.sub(saveBallPosition, gkPosition)
    local sangle = vector2.sangle(originForward, saveOffset)
    local lowerThreshold = math.pi / 9
    local upperThreshold = math.pi - lowerThreshold
    if (math.cmpf(sangle, lowerThreshold) > 0 and math.cmpf(sangle, upperThreshold) < 0)
        or (math.cmpf(sangle, -lowerThreshold) < 0 and math.cmpf(sangle, -upperThreshold) > 0) then
        local cmpRe = math.cmpf(sangle, 0)
        local pivot = math.pi * 0.5
        if cmpRe > 0 then
            if math.cmpf(sangle, pivot) ~= 0 then
                forward = vector2.rotate(originForward, sangle - pivot)
            end
        elseif cmpRe < 0 then
            if math.cmpf(sangle, -pivot) ~= 0 then
                forward = vector2.rotate(originForward, sangle + pivot)
            end
        end
    end
    forward = vector2.norm(originForward)
    return forward
end

-- shoot result: 0-goal, 1-catch, 2-save out, 3-miss
function Athlete:selectSaveAnimation(startBallPosition, startBallPositionHeight, controlBallPosition, targetBallPosition, targetBallPositionHeight, flyDuration, shootResult)
    controlBallPosition = controlBallPosition or vector2.new((startBallPosition.x + targetBallPosition.x) / 2, (startBallPosition.y + targetBallPosition.y) / 2)
    targetBallPositionHeight = targetBallPositionHeight or math.randomInRange(0.1, 2)
    startBallPositionHeight = math.roundWithMinStep(startBallPositionHeight, 0.1)
    targetBallPositionHeight = math.roundWithMinStep(targetBallPositionHeight, 0.1)

    local gkPosition = self.position
    local forward = vector2.norm(vector2.sub(startBallPosition, gkPosition)) --default initial bodyDirection for save action
    local percent = Athlete.calculateTimePercentAtSavePosition(startBallPosition, controlBallPosition, targetBallPosition, gkPosition, forward)
    if math.cmpf(percent, 0) <= 0 then
        percent = 1
    end
    local percentCeiling = (shootResult == AIUtils.shootResult.catch or shootResult == AIUtils.shootResult.saveBounce) and 0.9 or 1
    percent = math.min(percent, percentCeiling)

    local saveBallPosition, saveBallPositionHeight = Athlete.predictBallPositionOnCertainTime(percent, flyDuration, startBallPosition, startBallPositionHeight, controlBallPosition, targetBallPosition, targetBallPositionHeight)
    forward = Athlete.adjustBodyDirectionBySaveBallPosition(saveBallPosition, gkPosition, forward)
    self.bodyDirection = forward
    self.direction = forward

    local choice, offset = Athlete.chooseSaveAction(shootResult, saveBallPosition, saveBallPositionHeight, gkPosition, forward)
    local saveAnimation = Animations.RawData[choice]

    local nextTask = self.match.ball.nextTask
    nextTask.saveAnimation = saveAnimation
    if shootResult == AIUtils.shootResult.shootWide then
        nextTask.outputFlyDuration = flyDuration
        nextTask.flyDuration = flyDuration
    else
        local saveFTBTime = saveAnimation.firstTouch * TIME_STEP
        local actualFlyDuration = saveFTBTime
        local originSaveTime = flyDuration * percent
        local needPreSave = false

        if shootResult == AIUtils.shootResult.catch or shootResult == AIUtils.shootResult.saveBounce then
            if math.cmpf(saveFTBTime + TIME_STEP, originSaveTime) > 0 then
                flyDuration = saveFTBTime / percent
                targetBallPositionHeight = Athlete.recalculateVerticalEndPoint(startBallPositionHeight, targetBallPositionHeight, saveBallPositionHeight, saveFTBTime, flyDuration)
            else
                local animation, moveTime = choosePreSaveAction(originSaveTime, saveFTBTime, offset)
                actualFlyDuration = actualFlyDuration + moveTime
                flyDuration = (saveFTBTime + moveTime) / percent
                targetBallPositionHeight = Athlete.recalculateVerticalEndPoint(startBallPositionHeight, targetBallPositionHeight, saveBallPositionHeight, actualFlyDuration, flyDuration)
                self:pushAnimation(animation)
            end
            saveBallPositionHeight = Athlete.predictBallPositionHeight(percent, flyDuration, startBallPositionHeight, targetBallPositionHeight)
            self.position = vector2.sub(saveBallPosition, vector2.vyrotate(saveAnimation.firstTouchBallPosition, self.bodyDirection))
        elseif shootResult == AIUtils.shootResult.goal then
            local saveStartPosition = vector2.sub(saveBallPosition, vector2.vyrotate(saveAnimation.firstTouchBallPosition, self.bodyDirection))
            if math.cmpf((gkPosition.x - saveStartPosition.x) * (gkPosition.x - saveBallPosition.x), 0) < 0 then
                self.position = saveStartPosition
            end
            if math.cmpf(originSaveTime, saveFTBTime) >= 0 then
                local animation, moveTime = choosePreSaveAction(originSaveTime + TIME_STEP, saveFTBTime, offset)
                actualFlyDuration = actualFlyDuration + moveTime
                self:pushAnimation(animation)
            end
        end

        local oldFlyduration = nextTask.flyDuration
        nextTask.outputFlyDuration = flyDuration
        nextTask.flyDuration = actualFlyDuration
        nextTask.saveTime = nextTask.saveTime - oldFlyduration + actualFlyDuration
    end

    nextTask.savePosition = saveBallPosition
    nextTask.savePositionHeight = saveBallPositionHeight
    nextTask.targetPositionHeight = targetBallPositionHeight
    nextTask.controlPosition = controlBallPosition
end
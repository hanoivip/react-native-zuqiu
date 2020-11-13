local MatchState = import("./MatchState")
local Field = import("../Field")
local vector2 = import("../libs/vector")
local Animations = import("../animations/Animations")
local selector = import("../libs/selector")
local Skills = import("../skills/Skills")

local ThrowIn = class(MatchState)

function ThrowIn:ctor(match)
    ThrowIn.super.ctor(self, match, "ThrowIn")
end

function ThrowIn:Enter()
    self.match.isFrozen = true
    self.match.frozenType = "ThrowIn"
    self.match.noNeedJudgeBallOutOfField = true
end

function ThrowIn:setAthleteStates()
    for i, athlete in ipairs(self.match.attackTeam.athletes) do
        athlete.bodyDirection = vector2.norm(self.match.ball.outOfFieldPoint - athlete.position)
    end

    for i, athlete in ipairs(self.match.defenseTeam.athletes) do
        local defenseSqrDist = vector2.sqrdist(self.match.ball.outOfFieldPoint, athlete.position)
        local defenseDirection = vector2.norm(self.match.ball.outOfFieldPoint - athlete.position)
        if math.cmpf(defenseSqrDist, 0) == 0 or not Field.isInside(athlete.position) then
            athlete.position = self.match.ball.outOfFieldPoint + vector2.mul(vector2.new(math.sign(self.match.ball.outOfFieldPoint.x), 0), -2)
            defenseDirection = vector2.norm(self.match.ball.outOfFieldPoint - athlete.position)
        elseif math.cmpf(defenseSqrDist, 4) < 0 then
            athlete.position = self.match.ball.outOfFieldPoint + vector2.mul(defenseDirection, -2)
        end

        athlete.bodyDirection = defenseDirection
    end
end

function ThrowIn:getThrowInAthlete()
    local sign = self.match.attackTeam:getSign()
    local throwInAthlete

    local hasPopeyeAthletes = { }
    for _, athlete in ipairs(self.match.attackTeam.athletes) do
        if athlete.role ~= 26 and athlete:getCooldownSkill(Skills.Popeye) then
            table.insert(hasPopeyeAthletes, athlete)
        end
    end

    throwInAthlete = selector.randomSelect(hasPopeyeAthletes)
    if not throwInAthlete then
        local leftSideThrowInAthlete = self.match.attackTeam.leftSideThrowInPlayer
        local leftSideThrowInAthletex = Field.formations[self.match.attackTeam.formation]["athletes"][leftSideThrowInAthlete.role].attack.kickOff.x
        if math.cmpf(sign * leftSideThrowInAthletex * self.match.ball.outOfFieldPoint.x, 0) > 0 then
            throwInAthlete = leftSideThrowInAthlete
        else
            throwInAthlete = self.match.attackTeam.rightSideThrowInPlayer
        end
    end

    return throwInAthlete
end

function ThrowIn:setThrowInAthleteState(throwInAthlete)
    self.match.throwInTarget = throwInAthlete:getThrowInTarget()

    local throwInSqrDist = vector2.sqrdist(self.match.throwInTarget.targetPosition, self.match.ball.outOfFieldPoint)
    local throwInAnimationType = math.cmpf(throwInSqrDist, 100) >= 0 and "ThrowInLong" or "ThrowInShort"
    local animationList = Animations.Tag[throwInAnimationType]
    local throwInPassAnimation = selector.randomSelect(animationList)

    throwInAthlete.bodyDirection = vector2.norm(self.match.throwInTarget.targetPosition - self.match.ball.outOfFieldPoint)
    throwInAthlete.position = self.match.ball.outOfFieldPoint - vector2.vyrotate(throwInPassAnimation.lastTouchBallPosition, throwInAthlete.bodyDirection)
    self.match.ball:setOwner(throwInAthlete)
    throwInAthlete:pushAnimation(throwInPassAnimation, true, throwInAthlete.bodyDirection)

    throwInAthlete.upComingAction = "ThrowIn"
end

function ThrowIn:Execute()
    self:setAthleteStates()

    local throwInAthlete = self:getThrowInAthlete()
    self:setThrowInAthleteState(throwInAthlete)

    self.super.Execute(self)

    self.match:changeState("NormalPlayOn")
end

function ThrowIn:Exit()

end

return ThrowIn

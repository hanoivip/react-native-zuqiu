local MatchState = import("./MatchState")
local Field = import("../Field")
local vector2 = import("../libs/vector")
local Animations = import("../animations/Animations")
local selector = import("../libs/selector")

local PenaltyShootOutKick = class(MatchState)

function PenaltyShootOutKick:ctor(match)
    PenaltyShootOutKick.super.ctor(self, match, "PenaltyShootOutKick")
end

function PenaltyShootOutKick:Enter()
    self.match.isFrozen = true
    self.match.frozenType = "PenaltyKick"

    self.match.attackTeam.shootOutAttempts = self.match.attackTeam.shootOutAttempts + 1
end

function PenaltyShootOutKick:setAthleteStates(sign)
    local penaltyKickPosition = self.match.attackTeam:getPenaltyKickPosition()

    local xDirection = vector2.new(1, 0)
    local yDirection = vector2.new(0, sign)

    for i, athlete in ipairs(self.match.attackTeam.athletes) do
        if athlete:isGoalkeeper() then
            local penaltyKickAttackPosition = Field.formations[athlete.team.formation]["athletes"][athlete.role].attack.penaltyKick
            athlete.position = vector2.new(Field.width, penaltyKickAttackPosition.y)
            athlete.bodyDirection = vector2.norm(penaltyKickPosition - athlete.position)
        else
            athlete.position = xDirection * i * athlete.team.penaltyShootOutXsign
            athlete.bodyDirection = yDirection
        end
    end

    for i, athlete in ipairs(self.match.defenseTeam.athletes) do
        if athlete:isGoalkeeper() then
            local penaltyKickDefensePosition = Field.formations[athlete.team.formation]["athletes"][athlete.role].defense.penaltyKick
            athlete.position = penaltyKickDefensePosition * sign
            athlete.bodyDirection = vector2.norm(penaltyKickPosition - athlete.position)
        else
            athlete.position = xDirection * i * athlete.team.penaltyShootOutXsign
            athlete.bodyDirection = yDirection
        end
    end
end

function PenaltyShootOutKick:setKickAthleteState(penaltyKickPosition)
    local shootAnimation = selector.randomSelect(Animations.Tag.PenaltyShoot)

    local penaltyKickPlayer = self.match.attackTeam.rankedPenaltyShootOutAthletes[(self.match.attackTeam.shootOutAttempts - 1) % 11 + 1]
    penaltyKickPlayer.bodyDirection = vector2.rotate(vector2.norm(penaltyKickPlayer.enemyTeam.goal.center - penaltyKickPosition), -Animations.RawData[shootAnimation.name].outAngle.Start)
    penaltyKickPlayer.position = penaltyKickPosition - vector2.vyrotate(shootAnimation.firstTouchBallPosition, penaltyKickPlayer.bodyDirection)
    self.match.ball:setOwner(penaltyKickPlayer)
    self.match.ball.position = penaltyKickPosition
    penaltyKickPlayer:pushAnimation(shootAnimation, true)

    penaltyKickPlayer.upComingAction = "PenaltyKick"
end

function PenaltyShootOutKick:Execute()
    local penaltyKickPosition = self.match.attackTeam:getPenaltyKickPosition()

    local sign = math.sign(penaltyKickPosition.y)

    self:setAthleteStates(sign)
    self:setKickAthleteState(penaltyKickPosition)

    self.match.lastPenaltyShootOutTeam = self.match.attackTeam

    self.super.Execute(self)

    self.match:changeState("NormalPlayOn")
end

function PenaltyShootOutKick:Exit()

end

return PenaltyShootOutKick

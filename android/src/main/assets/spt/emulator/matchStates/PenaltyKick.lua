local MatchState = import("./MatchState")
local Field = import("../Field")
local vector2 = import("../libs/vector")
local Animations = import("../animations/Animations")
local selector = import("../libs/selector")

local PenaltyKick = class(MatchState)

function PenaltyKick:ctor(match)
    PenaltyKick.super.ctor(self, match, "PenaltyKick")
end

function PenaltyKick:Enter()
    self.match.isFrozen = true
    self.match.frozenType = "PenaltyKick"
end

function PenaltyKick:setAthleteStates(sign)
    local penaltyKickPosition = self.match.attackTeam:getPenaltyKickPosition()

    for i, athlete in ipairs(self.match.attackTeam.athletes) do
        local penaltyKickAttackPosition = Field.formations[athlete.team.formation]["athletes"][athlete.role].attack.penaltyKick
        athlete.position = penaltyKickAttackPosition * sign
        athlete.bodyDirection = vector2.norm(penaltyKickPosition - athlete.position)
    end

    for i, athlete in ipairs(self.match.defenseTeam.athletes) do
        local penaltyKickDefensePosition = Field.formations[athlete.team.formation]["athletes"][athlete.role].defense.penaltyKick
        athlete.position = penaltyKickDefensePosition * sign
        athlete.bodyDirection = vector2.norm(penaltyKickPosition - athlete.position)
    end
end

function PenaltyKick:setKickAthleteState(penaltyKickPosition)
    local penaltyKickPlayer = self.match.attackTeam.penaltyKickPlayer
    local animationList = Animations.Tag.PenaltyShoot
    local shootAnimation = selector.randomSelect(animationList)
    penaltyKickPlayer.bodyDirection = vector2.rotate(vector2.norm(penaltyKickPlayer.enemyTeam.goal.center - penaltyKickPosition), -Animations.RawData[shootAnimation.name].outAngle.Start)
    penaltyKickPlayer.position = penaltyKickPosition - vector2.vyrotate(shootAnimation.firstTouchBallPosition, penaltyKickPlayer.bodyDirection)
    self.match.ball:setOwner(penaltyKickPlayer)
    self.match.ball.position = penaltyKickPosition
    penaltyKickPlayer:pushAnimation(shootAnimation, true)

    penaltyKickPlayer.upComingAction = "PenaltyKick"
end

function PenaltyKick:Execute()
    local penaltyKickPosition = self.match.attackTeam:getPenaltyKickPosition()

    local sign = math.sign(penaltyKickPosition.y)

    self:setAthleteStates(sign)
    self:setKickAthleteState(penaltyKickPosition)

    self.super.Execute(self)

    self.match:changeState("NormalPlayOn")
end

function PenaltyKick:Exit()

end

return PenaltyKick

local MatchState = import("./MatchState")
local Field = import("../Field")
local vector2 = import("../libs/vector")

local IndirectFreeKick = class(MatchState)

function IndirectFreeKick:ctor(match)
    IndirectFreeKick.super.ctor(self, match, "IndirectFreeKick")
end

function IndirectFreeKick:Enter()
    self.match.isFrozen = true
    self.match.frozenType = "IndirectFreeKick"
end

function IndirectFreeKick:setAthleteStates()
    local sign = math.sign(self.match.indirectFreeKickPosition.y)

    for i, athlete in ipairs(self.match.attackTeam.athletes) do
        local indirectFreeKickAttackPosition = Field.formations[athlete.team.formation]["athletes"][athlete.role].attack.indirectFreeKick
        athlete.position = indirectFreeKickAttackPosition * sign
        athlete.bodyDirection = vector2.norm(self.match.indirectFreeKickPosition - athlete.position)
    end

    for i, athlete in ipairs(self.match.defenseTeam.athletes) do
        local indirectFreeKickDefensePosition = Field.formations[athlete.team.formation]["athletes"][athlete.role].defense.indirectFreeKick
        athlete.position = indirectFreeKickDefensePosition * sign
        athlete.bodyDirection = vector2.norm(self.match.indirectFreeKickPosition - athlete.position)
    end
end

function IndirectFreeKick:setKickOffAthleteStates()
    local indirectFreeKickOffAthlete = self.match.indirectFreeKickOffAthlete
    indirectFreeKickOffAthlete.position = self.match.indirectFreeKickPosition
    indirectFreeKickOffAthlete.bodyDirection = indirectFreeKickOffAthlete.team.goal.normal
    self.match.ball:setOwner(indirectFreeKickOffAthlete)
    indirectFreeKickOffAthlete.upComingAction = "IndirectFreeKick"
end

function IndirectFreeKick:Execute()
    self:setAthleteStates()
    self:setKickOffAthleteStates()

    self.super.Execute(self)

    self.match:changeState("NormalPlayOn")
end

function IndirectFreeKick:Exit()

end

return IndirectFreeKick

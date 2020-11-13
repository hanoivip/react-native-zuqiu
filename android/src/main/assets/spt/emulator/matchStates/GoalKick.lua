local MatchState = import("./MatchState")
local Field = import("../Field")
local vector2 = import("../libs/vector")

local GoalKick = class(MatchState)

function GoalKick:ctor(match)
    GoalKick.super.ctor(self, match, "GoalKick")
end

function GoalKick:Enter()
end

function GoalKick:setAthleteStates()
    local sign = math.sign(self.match.ball.outOfFieldPoint.y)
    local goalKickPosition = Field.formations[self.match.attackTeam.athleteOfRole[26].team.formation]["athletes"][26].attack.goalKick * sign

    for i, athlete in ipairs(self.match.attackTeam.athletes) do
        local goalKickAttackPosition = Field.formations[athlete.team.formation]["athletes"][athlete.role].attack.goalKick
        athlete.position = goalKickAttackPosition * sign
        athlete.bodyDirection = vector2.norm(goalKickPosition - athlete.position)
    end

    for i, athlete in ipairs(self.match.defenseTeam.athletes) do
        local goalKickDefensePosition = Field.formations[athlete.team.formation]["athletes"][athlete.role].defense.goalKick
        athlete.position = goalKickDefensePosition * sign
        athlete.bodyDirection = vector2.norm(goalKickPosition - athlete.position)
    end
end

function GoalKick:setGkStates()
    local gk = self.match.attackTeam.athleteOfRole[26]
    gk.bodyDirection = gk.team.goal.normal
    self.match.ball:setOwner(gk)
    gk.upComingAction = "GoalKick"
end

function GoalKick:Execute()
    self:setAthleteStates()
    self:setGkStates()

    self.super.Execute(self)

    self.match:judgeAfterShootMissSkills()

    self.match:changeState("NormalPlayOn")
end

function GoalKick:Exit()

end

return GoalKick

local CoachSkill = import("./CoachSkill")

local RobTalent = class(CoachSkill, "RobTalent")
RobTalent.id = 514
RobTalent.alias = "抢攻天赋"

local attackConfig = 1.45
local defendConfig = 1.45
local durationConfig = 60

function RobTalent:ctor()
    CoachSkill.ctor(self)

    self.buff = {
        skill = self,
        duration = durationConfig,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.onfieldId == nil or math.cmpf(remainingTime, 0) <= 0
        end,
        abilitiesModifier = function(abilities)
            abilities.dribble = abilities.dribble * attackConfig
            abilities.pass = abilities.pass * attackConfig
            abilities.shoot = abilities.shoot * attackConfig
            abilities.steal = abilities.steal * defendConfig
            abilities.intercept = abilities.intercept * defendConfig
            abilities.goalkeeping = abilities.goalkeeping * defendConfig
        end,
        persistent = true
    }
end

function RobTalent:enterStage(team)
    if team.match.stage ~= team.match.FIRST_HALF_STAGE then
        return
    end
    for _, athlete in ipairs(team.athletes) do
        athlete:addBuff(self.buff, team)
    end
    team:castCoachSkill(self.id)
end

return RobTalent 

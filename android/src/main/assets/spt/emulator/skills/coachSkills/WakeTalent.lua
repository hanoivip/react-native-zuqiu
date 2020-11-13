local CoachSkill = import("./CoachSkill")

local WakeTalent = class(CoachSkill, "WakeTalent")
WakeTalent.id = 214
WakeTalent.alias = "觉醒天赋"

local attackConfig = 1.5
local defendConfig = 1.5

function WakeTalent:ctor()
    CoachSkill.ctor(self)

    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.onfieldId == nil or 
                receiver.match.PENALTY_SHOOTOUT_STAGE <= receiver.match.stage
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

function WakeTalent:enterStage(team)
    if team.match.stage ~= team.match.SECOND_HALF_STAGE or 
        team.score ~= 0 then
        return
    end
    for _, athlete in ipairs(team.athletes) do
        athlete:addBuff(self.buff, team)
    end
    team:castCoachSkill(self.id)
end

return WakeTalent 

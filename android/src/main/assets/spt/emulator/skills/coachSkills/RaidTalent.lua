local CoachSkill = import("./CoachSkill")

local RaidTalent = class(CoachSkill, "RaidTalent")
RaidTalent.id = 714
RaidTalent.alias = "偷袭天赋"

local attackConfig = 1.35
local defendConfig = 1.35

function RaidTalent:ctor()
    CoachSkill.ctor(self)

    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.onfieldId == nil or 
                self.scoreStatus == self.LEADER or
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

function RaidTalent:onBecomingLaggard(team)
    for _, athlete in ipairs(team.athletes) do
        athlete:addBuff(self.buff, team)
    end
    team:castCoachSkill(self.id)
end

return RaidTalent
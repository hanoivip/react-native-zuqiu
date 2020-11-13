local CoachSkill = import("./CoachSkill")

local BarrelTalent = class(CoachSkill, "BarrelTalent")
BarrelTalent.id = 114
BarrelTalent.alias = "铁桶天赋"

local defendConfig = 1.5
local attackConfig = 0.9

function BarrelTalent:ctor()
    CoachSkill.ctor(self)
    self.triggered = nil

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

function BarrelTalent:execute(team)
    if self.trigger or
        self.scoreStatus ~= self.LEADER or
        team.match.PENALTY_SHOOTOUT_STAGE <= team.match.stage then
        return
    end
    for _, athlete in ipairs(team.athletes) do
        athlete:addBuff(self.buff, team)
    end
    team:castCoachSkill(self.id)
    self.trigger = true
end

function BarrelTalent:enterStage(team)
    self:execute(team)
end

function BarrelTalent:onBecomingLeader(team)
    self:execute(team)
end

return BarrelTalent
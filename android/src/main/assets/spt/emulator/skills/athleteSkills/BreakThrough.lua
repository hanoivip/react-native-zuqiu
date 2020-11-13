local Skill = import("../Skill")

local BreakThrough = class(Skill, "BreakThrough")
BreakThrough.id = "B01"
BreakThrough.alias = "带球突破"

local cooldownConfig = 0
local minProbabilityConfig = 1
local maxProbabilityConfig = 1
BreakThrough.minAddDribbleConfig = 0.55
BreakThrough.maxAddDribbleConfig = 5.5
BreakThrough.minAddConfig = 0.22
BreakThrough.maxAddConfig = 2.2

function BreakThrough:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.cooldown = cooldownConfig
    self.remainingCooldown = 0
    self.probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
    self.addRatio = Skill.lerpLevel(self.minAddConfig, self.maxAddConfig, level)

    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return true
        end,
        abilitiesModifier = function(abilities, caster, receiver)
            abilities.dribble = abilities.dribble + receiver.initAbilities.dribble * Skill.lerpLevel(self.minAddDribbleConfig, self.maxAddDribbleConfig, level)
        end
    }

    self.afterSuccessBuff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.team:isDefendRole()
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end,
    }
end

return BreakThrough

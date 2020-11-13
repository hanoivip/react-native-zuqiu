local Skill = import("../Skill")

local AirDominator = class(Skill, "AirDominator")
AirDominator.id = "E06"
AirDominator.alias = "制空者"

local cooldownConfig = 0
local minProbabilityConfig = 1
local maxProbabilityConfig = 1
local minAddAbilityConfig = 0.55
local maxAddAbilityConfig = 5.5

function AirDominator:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.cooldown = cooldownConfig
    self.remainingCooldown = 0
    self.probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)

    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return true
        end,
        abilitiesModifier = function(abilities, caster, receiver)
            abilities.intercept = abilities.intercept + receiver.initAbilities.anticipation * Skill.lerpLevel(minAddAbilityConfig, maxAddAbilityConfig, level)
        end
    }
end

return AirDominator
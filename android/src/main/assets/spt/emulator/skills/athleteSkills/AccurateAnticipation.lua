local Skill = import("../Skill")

local AccurateAnticipation = class(Skill, "AccurateAnticipation")
AccurateAnticipation.id = "A04"
AccurateAnticipation.alias = "精准预判"

local cooldownConfig = 0
local minProbabilityConfig = 1
local maxProbabilityConfig = 1
local minAddAbilityConfig = 0.55
local maxAddAbilityConfig = 5.5

function AccurateAnticipation:ctor(level)
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
            abilities.intercept = abilities.intercept + receiver.initAbilities.intercept * Skill.lerpLevel(minAddAbilityConfig, maxAddAbilityConfig, level)
        end
    }
end

return AccurateAnticipation

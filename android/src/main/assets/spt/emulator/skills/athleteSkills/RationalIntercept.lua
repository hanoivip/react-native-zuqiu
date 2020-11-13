local Skill = import("../Skill")

local RationalIntercept = class(Skill, "RationalIntercept")
RationalIntercept.id = "M09"
RationalIntercept.alias = "合理选位"

local cooldownConfig = 0
local minProbabilityConfig = 0.7
local maxProbabilityConfig = 0.7
local minInterceptConfig = 0.18
local maxInterceptConfig = 18

function RationalIntercept:ctor(level)
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
            abilities.intercept = abilities.intercept + receiver.initAbilities.intercept * Skill.lerpLevel(minInterceptConfig, maxInterceptConfig, level)
        end
    }
end

return RationalIntercept

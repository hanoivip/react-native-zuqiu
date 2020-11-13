local Skill = import("../Skill")

local RationalSteal = class(Skill, "RationalSteal")
RationalSteal.id = "M08"
RationalSteal.alias = "合理上抢"

local cooldownConfig = 0
local minProbabilityConfig = 0.7
local maxProbabilityConfig = 0.7
local minStealConfig = 0.18
local maxStealConfig = 18

function RationalSteal:ctor(level)
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
            abilities.steal = abilities.steal + receiver.initAbilities.steal * Skill.lerpLevel(minStealConfig, maxStealConfig, level)
        end
    }
end

return RationalSteal

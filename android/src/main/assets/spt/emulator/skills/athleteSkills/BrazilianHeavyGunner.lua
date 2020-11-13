local Skill = import("../Skill")

local BrazilianHeavyGunner = class(Skill, "BrazilianHeavyGunner")
BrazilianHeavyGunner.id = "LR_ROBERTOCARLOS2"
BrazilianHeavyGunner.alias = "巴西重炮"

local cooldownConfig = 0
local minProbabilityConfig = 1
local maxProbabilityConfig = 1
local minAddAbilityConfig = 0.6
local maxAddAbilityConfig = 0.6

function BrazilianHeavyGunner:ctor(level)
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
        abilitiesModifier = function(abilities, caster, receiver) -- caster.maxInitAbility
            abilities.shoot = abilities.shoot + caster:getMaxAbility() * Skill.lerpLevel(minAddAbilityConfig, maxAddAbilityConfig, level)
        end
    }
end

return BrazilianHeavyGunner

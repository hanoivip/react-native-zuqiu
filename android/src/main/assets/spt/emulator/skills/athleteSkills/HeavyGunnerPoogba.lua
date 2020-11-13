local Skill = import("../Skill")
local HeavyGunner = import("./HeavyGunner")

local HeavyGunnerPoogba = class(HeavyGunner, "HeavyGunnerPoogba")
HeavyGunnerPoogba.id = "LR_PPOGBA2"
HeavyGunnerPoogba.alias = "远程火炮"

local cooldownConfig = 0
local durationConfig = 60
local minProbabilityConfig = 1
local maxProbabilityConfig = 1
local minAddAbilityConfig = 1.5
local maxAddAbilityConfig = 1.5
local minAddRatio = 0.2
local maxAddRatio = 0.2

function HeavyGunnerPoogba:ctor(level)
    HeavyGunner.ctor(self, level)
    self.probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
    self.abilityAddConfig = Skill.lerpLevel(minAddAbilityConfig, maxAddAbilityConfig, level)
    self.subRatio = -Skill.lerpLevel(minAddRatio, maxAddRatio, level)

    self.buff = {
        skill = self,
        remark = "baseBuff",
        removalCondition = function(remainingTime, caster, receiver)
            return not receiver:hasBall()
        end,
        abilitiesModifier = function(abilities, caster, receiver)
            abilities.shoot = abilities.shoot + caster:getAbilitiesSum() * self.abilityAddConfig
        end
    }

    self.debuff = {
        skill = self,
        duration = durationConfig,
        removalCondition = function(remainingTime, caster, receiver)
            return math.cmpf(remainingTime, 0) <= 0
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.subRatio
        end,
    }
end

return HeavyGunnerPoogba

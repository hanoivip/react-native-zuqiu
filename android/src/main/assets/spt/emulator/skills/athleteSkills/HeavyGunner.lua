local Skill = import("../Skill")

local HeavyGunner = class(Skill, "HeavyGunner")
HeavyGunner.id = "D07"
HeavyGunner.alias = "重炮手"

local cooldownConfig = 0
local minProbabilityConfig = 1
local maxProbabilityConfig = 1
HeavyGunner.minAbilitiesSumMultiply = 0.33
HeavyGunner.maxAbilitiesSumMultiply = 3.3

function HeavyGunner:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.cooldown = cooldownConfig
    self.remainingCooldown = 0
    self.probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
    self.abilitiesSumMultiply = Skill.lerpLevel(self.minAbilitiesSumMultiply, self.maxAbilitiesSumMultiply, level)

    self.buff = {
        skill = self,
        remark = "baseBuff",
        removalCondition = function(remainingTime, caster, receiver)
            return not receiver:hasBall()
        end,
    }
end

return HeavyGunner

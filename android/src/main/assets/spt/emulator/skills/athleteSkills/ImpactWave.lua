local Skill = import("../Skill")

local ImpactWave = class(Skill, "ImpactWave")
ImpactWave.id = "D05"
ImpactWave.alias = "冲击波"

local cooldownConfig = 0
local minProbabilityConfig = 1
local maxProbabilityConfig = 1
ImpactWave.minDecreaseConfig = 0.22
ImpactWave.maxDecreaseConfig = 2.2

function ImpactWave:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.cooldown = cooldownConfig
    self.remainingCooldown = 0
    self.probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
    self.addRatio = -Skill.lerpLevel(self.minDecreaseConfig, self.maxDecreaseConfig, level)

    self.buff = {
        skill = self,
        remark = "base",
        removalCondition = function(remainingTime, caster, receiver)
            return false
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end,
        persistent = true
    }

    self.blockBuff = {
        skill = self,
        remark = "base",
        removalCondition = function(remainingTime, caster, receiver)
            return false
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio / 2
        end,
        persistent = true
    }
end

return ImpactWave

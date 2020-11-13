local Skill = import("../Skill")
local ImpactWave = import("./ImpactWave")

local ImpactWaveEx1 = class(ImpactWave, "ImpactWaveEx1")
ImpactWaveEx1.id = "D05_1"
ImpactWaveEx1.alias = "冲击波"

local minProbabilityConfig = 1
local maxProbabilityConfig = 1

function ImpactWaveEx1:ctor(level)
    ImpactWave.ctor(self, level)
    self.ex1Probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)

    self.ex1Debuff = {
        skill = self,
        remark = "mark",
        removalCondition = function(remainingTime, caster, receiver)
            return false
        end,
        abilitiesAddRatio = function(caster, receiver)
            return 0
        end,
        persistent = true
    }
end

return ImpactWaveEx1

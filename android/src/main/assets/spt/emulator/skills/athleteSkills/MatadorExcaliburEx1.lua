local Skill = import("../Skill")
local MatadorExcalibur = import("./MatadorExcalibur")

local MatadorExcaliburEx1 = class(MatadorExcalibur, "MatadorExcaliburEx1")
MatadorExcaliburEx1.id = "D02_A_1"
MatadorExcaliburEx1.alias = "斗牛士神剑ex"

-- debuff持续时间,除以2为游戏内显示时间
local durationConfig = 60
-- 减全属性发动概率
local minProbabilityConfig = 1
local maxProbabilityConfig = 1
-- 全属性减少配置
local minSubAbilityConfig = 0.4
local maxSubAbilityConfig = 0.4

function MatadorExcaliburEx1:ctor(level)
    MatadorExcalibur.ctor(self, level)
    self.exa1Probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
    self.exa1SubRatio = -Skill.lerpLevel(minSubAbilityConfig, maxSubAbilityConfig, level)

    self.exa1Debuff = {
        skill = self,
        duration = durationConfig,
        removalCondition = function(remainingTime, caster, receiver)
            return math.cmpf(remainingTime, 0) <= 0
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.exa1SubRatio
        end
    }
end

return MatadorExcaliburEx1

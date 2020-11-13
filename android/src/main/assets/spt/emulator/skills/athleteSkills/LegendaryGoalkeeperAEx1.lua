local Skill = import("../Skill")
local LegendaryGoalkeeperA = import("./LegendaryGoalkeeperA")

local LegendaryGoalkeeperAEx1 = class(LegendaryGoalkeeperA, "LegendaryGoalkeeperAEx1")
LegendaryGoalkeeperAEx1.id = "E03_A_1"
LegendaryGoalkeeperAEx1.alias = "EX伯纳乌天神"

-- debuff持续时间,除以2为游戏内显示时间
local durationConfig = 40
-- 减全属性发动概率
local minProbabilityConfig = 1
local maxProbabilityConfig = 1
-- 全属性减少配置
local minSubAbilityConfig = 0.25
local maxSubAbilityConfig = 0.25

function LegendaryGoalkeeperAEx1:ctor(level)
    LegendaryGoalkeeperA.ctor(self, level)
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

return LegendaryGoalkeeperAEx1
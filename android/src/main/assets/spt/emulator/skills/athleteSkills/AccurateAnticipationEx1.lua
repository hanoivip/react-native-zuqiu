local Skill = import("../Skill")
local AccurateAnticipation = import("./AccurateAnticipation")

local AccurateAnticipationEx1 = class(AccurateAnticipation, "AccurateAnticipationEx1")
AccurateAnticipationEx1.id = "A04_1"
AccurateAnticipationEx1.alias = "精准预判"

-- 盯人发动概率
local minBlockProbabilityConfig = 0.1
local maxBlockProbabilityConfig = 0.1
-- 减全属性发动概率
local minProbabilityConfig = 0.2
local maxProbabilityConfig = 0.2
-- 全属性减少配置
local minSubAbilityConfig = 0.501
local maxSubAbilityConfig = 0.6
-- debuff持续时间,除以2为游戏内显示时间
local durationConfig = 8

function AccurateAnticipationEx1:ctor(level)
    AccurateAnticipation.ctor(self, level)

    self.ex1BlockProbability = Skill.lerpLevel(minBlockProbabilityConfig, maxBlockProbabilityConfig, level)
    self.ex1Probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
    self.ex1SubRatio = -Skill.lerpLevel(minSubAbilityConfig, maxSubAbilityConfig, level)

    self.ex1MarkedDebuff = {
        skill = self,
        duration = durationConfig,
        removalCondition = function(remainingTime, caster, receiver)
            return math.cmpf(remainingTime, 0) <= 0
        end,
        abilitiesAddRatio = function(caster, receiver)
            return 0
        end,
    }

    self.ex1Debuff = {
        skill = self,
        duration = durationConfig,
        removalCondition = function(remainingTime, caster, receiver)
            return math.cmpf(remainingTime, 0) <= 0
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.ex1SubRatio
        end,
    }
end

return AccurateAnticipationEx1

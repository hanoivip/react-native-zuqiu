local Skill = import("../Skill")
local ChargeTrumpet = import("./ChargeTrumpet")

local ChargeTrumpetEx1 = class(ChargeTrumpet, "ChargeTrumpetEx1")
ChargeTrumpetEx1.id = "G02_1"
ChargeTrumpetEx1.alias = "冲锋号角"

-- Ex技能触发概率
local minProbabilityConfig = 1
local maxProbabilityConfig = 1
-- 技能自身增强配置 计算：下文 self.addRatio
local minExtraAddConfig = 0.15
local maxExtraAddConfig = 0.15
-- 敌方属性减少配置 计算：下文self.ex1SubRatio
local minSubConfig = 0.15
local maxSubConfig = 0.348

function ChargeTrumpetEx1:ctor(level)
    ChargeTrumpet.ctor(self, level)

    self.ex1Probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
    self.addRatio = self.addRatio * (1 + Skill.lerpLevel(minExtraAddConfig, maxExtraAddConfig, level))
    self.ex1SubRatio = -Skill.lerpLevel(minSubConfig, maxSubConfig, level)

    self.ex1Debuff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.team:isAttackRole()
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.ex1SubRatio
        end,
    }
end

return ChargeTrumpetEx1

local Skill = import("../Skill")
local Catenaccio = import("./Catenaccio")

local CatenaccioEx1 = class(Catenaccio, "CatenaccioEx1")
CatenaccioEx1.id = "A07_1"
CatenaccioEx1.alias = "链式防守"

-- 技能自身增强配置 计算：下文 self.addRatio（如不需要再额外增强基础技能，这两个值设为0即可）
local minExtraAddConfig = 0
local maxExtraAddConfig = 0
-- 敌方属性减少配置 计算：下文self.ex1SubRatio
local minSubConfig = 0.025
local maxSubConfig = 0.025
-- 我方多个链式Ex技能时、敌方属性减少配置 计算：下文self.ex1ExtraSubRatio
local minExtraSubConfig = 0
local maxExtraSubConfig = 0

function CatenaccioEx1:ctor(level)
    Catenaccio.ctor(self, level)

    self.addRatio = self.addRatio * (1 + Skill.lerpLevel(minExtraAddConfig, maxExtraAddConfig, level))
    self.ex1SubRatio = -Skill.lerpLevel(minSubConfig, maxSubConfig, level)
    self.ex1ExtraSubRatio = -Skill.lerpLevel(minExtraSubConfig, maxExtraSubConfig, level)

    self.ex1Debuff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return caster.team:isAttackRole()
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.ex1SubRatio + (caster.team.catenaccioEx1Count - 1) * self.ex1ExtraSubRatio
        end,
    }
end

return CatenaccioEx1

local Skill = import("../Skill")
local Handing = import("./Handing")

local HandingEx1 = class(Handing, "HandingEx1")
HandingEx1.id = "E05_1"
HandingEx1.alias = "手控球"

-- 不能获得增益buff的时间
local durationConfig = 20
-- ex1技能效果的触发概率
local minProbabilityConfig = 1
local maxProbabilityConfig = 1
-- 门将自身加全属性
local minBaseAddConfig = 0.22
local maxBaseAddConfig = 2.2

function HandingEx1:ctor(level)
    Handing.ctor(self, level)

    self.ex1Probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
    self.ex1BaseAddRatio = Skill.lerpLevel(minBaseAddConfig, maxBaseAddConfig, level)

    self.ex1Debuff = {
        skill = self,
        remark = "cannotAddBuff",
        duration = durationConfig,
        removalCondition = function(remainingTime, caster, receiver)
            return math.cmpf(remainingTime, 0) <= 0
        end,
        abilitiesAddRatio = function(caster, receiver)
            return 0
        end,
    }

    self.ex1BaseBuff = {
        skill = self,
        remark = "ignoreCannotAddBuffDebuff",
        removalCondition = function(remainingTime, caster, receiver)
            return false
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.ex1BaseAddRatio
        end,
        persistent = true
    }
end

function HandingEx1:enterField(athlete)
    athlete:castSkill(self)
    athlete:addBuff(self.ex1BaseBuff, athlete)
end

return HandingEx1
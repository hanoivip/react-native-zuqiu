local Skill = import("../Skill")
local PuntKick = import("./PuntKick")

local PuntKickEx1 = class(PuntKick, "PuntKickEx1")
PuntKickEx1.id = "E09_1"
PuntKickEx1.alias = "大脚开球"

local minAddConfig = 0.66
local maxAddConfig = 6.6
-- 门将自身加全属性
local minBaseAddConfig = 0.05
local maxBaseAddConfig = 0.15
local minProbabilityConfig = 1
local maxProbabilityConfig = 1

function PuntKickEx1:ctor(level)
    PuntKick.ctor(self, level)
    self.ex1AddRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)
    self.ex1BaseAddRatio = Skill.lerpLevel(minBaseAddConfig, maxBaseAddConfig, level)
    self.ex1Probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)

    self.ex1Buff = {
        skill = self,
        remark = "ignoreCannotAddBuffDebuff",
        removalCondition = function(remainingTime, caster, receiver)
            return false
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.ex1AddRatio
        end,
        persistent = true,
    }

    self.ex1BaseBuff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return false
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.ex1BaseAddRatio
        end,
        persistent = true
    }
end

function PuntKickEx1:enterField(athlete)
    athlete:castSkill(self)
    athlete:addBuff(self.ex1BaseBuff, athlete)
end

return PuntKickEx1
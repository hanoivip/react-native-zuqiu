local Skill = import("../Skill")
local AirDominator = import("./AirDominator")

local AirDominatorEx1 = class(AirDominator, "AirDominatorEx1")
AirDominatorEx1.id = "E06_1"
AirDominatorEx1.alias = "制空者"

-- 全属性加成配置
local minAddAbilityConfig = 0.11
local maxAddAbilityConfig = 1.1
-- 门将摘球概率
local minInterceptProbability = 0.18
local maxInterceptProbability = 0.18

function AirDominatorEx1:ctor(level)
    AirDominator.ctor(self, level)
   
    self.ex1AddRatio = Skill.lerpLevel(minAddAbilityConfig, maxAddAbilityConfig, level)
    self.ex1Probability = Skill.lerpLevel(minInterceptProbability, maxInterceptProbability, level)
    self.ex1Buff = {
        skill = self,
        remark = "ignoreCannotAddBuffDebuff",
        removalCondition = function(remainingTime, caster, receiver)
            return false
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.ex1AddRatio
        end,
        persistent = true
    }
end

function AirDominatorEx1:enterField(athlete)
    athlete:castSkill(self)
    athlete:addBuff(self.ex1Buff, athlete)
end

return AirDominatorEx1
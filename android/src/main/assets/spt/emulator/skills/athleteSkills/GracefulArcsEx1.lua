local Skill = import("../Skill")
local CrossLowEx1 = import("./CrossLowEx1")
local GracefulArcs = import("./GracefulArcs")

local GracefulArcsEx1 = class(CrossLowEx1, "GracefulArcsEx1")
GracefulArcsEx1.id = "C03_A_1"
GracefulArcsEx1.alias = "曼妙弧线"

-- 接球提升属性概率
local minAddProbability = 0.15
local maxAddProbability = 0.15
-- 接球提升属性配置
local minCatchAddConfig = 0.3
local maxCatchAddConfig = 0.3
-- 传球成功后属性提升配置
local minPassAddConfig = 0.08
local maxPassAddConfig = 0.08

function GracefulArcsEx1:ctor(level)
    if GracefulArcs.initConfig then
        GracefulArcs:initConfig(self)
    end
    CrossLowEx1.ctor(self, level)
    
    self.exa1AddProbability = Skill.lerpLevel(minAddProbability, maxAddProbability, level)
    self.exa1CatchAddRatio = Skill.lerpLevel(minCatchAddConfig, maxCatchAddConfig, level)
    self.exa1PassAddRatio = Skill.lerpLevel(minPassAddConfig, maxPassAddConfig, level)

    self.exa1CatchBuff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return not receiver.team:isAttackRole()
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.exa1CatchAddRatio
        end,
    }

    self.exa1PassBuff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return false
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.exa1PassAddRatio
        end,
        persistent = true
    }
end

function GracefulArcsEx1:enterField(athlete)
    CrossLowEx1.enterField(self, athlete)
end

return GracefulArcsEx1

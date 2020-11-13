local Skill = import("../Skill")
local AttackCore = import("./AttackCore")

local AttackCoreEx1 = class(AttackCore, "AttackCoreEx1")
AttackCoreEx1.id = "F07_1"
AttackCoreEx1.alias = "进攻核心"

-- 全属性加成配置
local minAddAbilityConfig = 0.2
local maxAddAbilityConfig = 0.2
-- 技能发动概率
local minProbability = 0.2
local maxProbability = 0.2

function AttackCoreEx1:ctor(level)    
    AttackCore.ctor(self, level)

    self.ex1AddRatio = Skill.lerpLevel(minAddAbilityConfig, maxAddAbilityConfig, level)
    self.ex1Probability = Skill.lerpLevel(minProbability, maxProbability, level)
    self.ex1AttackBuff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.team:isDefendRole()
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.ex1AddRatio
        end,
    }
    self.ex1DefendBuff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.team:isAttackRole()
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.ex1AddRatio
        end,
    }

end

function AttackCoreEx1:enterField(athlete)
    AttackCore.enterField(self, athlete)
end

return AttackCoreEx1
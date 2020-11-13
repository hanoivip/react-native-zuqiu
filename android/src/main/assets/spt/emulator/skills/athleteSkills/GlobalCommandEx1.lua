local Skill = import("../Skill")
local GlobalCommand = import("./GlobalCommand")

local GlobalCommandEx1 = class(GlobalCommand, "GlobalCommandEx1")
GlobalCommandEx1.id = "F08_1"
GlobalCommandEx1.alias = "统领指挥"

-- 全属性加成配置
local minAddAbilityConfig = 0.2
local maxAddAbilityConfig = 0.2
-- 技能发动概率
local minProbability = 0.2
local maxProbability = 0.2

function GlobalCommandEx1:ctor(level)
    GlobalCommand.ctor(self, level)

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

function GlobalCommandEx1:enterField(athlete)
    GlobalCommand.enterField(self, athlete)
end

return GlobalCommandEx1
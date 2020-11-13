local Skill = import("../Skill")
local BreakThroughEx1 = import("./BreakThroughEx1")
local GreatSpeed = import("./GreatSpeed")

local GreatSpeedEx1 = class(BreakThroughEx1, "GreatSpeedEx1")
GreatSpeedEx1.id = "B01_A_1"
GreatSpeedEx1.alias = "EX风驰电掣"

-- 进球后全属性加成
local minGoalAddConfig = 0.22
local maxGoalAddConfig = 2.2
-- 犯规后全属性加成
local minFoulAddConfig = 0.22
local maxFoulAddConfig = 2.2

function GreatSpeedEx1:ctor(level)
    if GreatSpeed.initConfig then
        GreatSpeed:initConfig(self)
    end
    BreakThroughEx1.ctor(self, level)

    self.goalSuccessAddRatio = Skill.lerpLevel(minGoalAddConfig, maxGoalAddConfig, level)
    self.foulSuccessAddRatio = Skill.lerpLevel(minFoulAddConfig, maxFoulAddConfig, level)

    self.exa1GoalBuff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return false
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.goalSuccessAddRatio
        end,
        persistent = true
    }
    self.exa1FoulBuff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return false
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.foulSuccessAddRatio
        end,
        persistent = true
    }
end

return GreatSpeedEx1

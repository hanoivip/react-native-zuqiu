local Skill = import("../Skill")
local TigerShoot = import("./TigerShoot")
local Ball = import("../../Ball")

local TigerShootEx1 = class(TigerShoot, "TigerShootEx1")
TigerShootEx1.id = "D06_1"
TigerShootEx1.alias = "猛虎射门"

-- 进球后Ex效果触发概率
TigerShoot.minGoalProbabilityConfig = 0.2
TigerShoot.maxGoalProbabilityConfig = 0.2
-- 进球后Ex效果持续时间
TigerShoot.goalDurationConfig = 30
-- 被扑后Ex效果触发概率
TigerShoot.minSaveProbabilityConfig = 0.35
TigerShoot.maxSavelProbabilityConfig = 0.35
-- 被扑后Ex效果持续时间
TigerShoot.saveDurationConfig = 30

function TigerShootEx1:ctor(level)
    TigerShoot.ctor(self, level)

    self.ex1ProbabilityGoal = Skill.lerpLevel(TigerShoot.minGoalProbabilityConfig, TigerShoot.maxGoalProbabilityConfig, level)
    self.ex1ProbabilitySave = Skill.lerpLevel(TigerShoot.minSaveProbabilityConfig, TigerShoot.maxSavelProbabilityConfig, level)

    self.ex1BuffGoal = {
        skill = self,
        remark = "mark",
        duration = TigerShoot.goalDurationConfig,
        removalCondition = function(remainingTime, caster, receiver)
            return math.cmpf(remainingTime, 0) <= 0 
        end,
        abilitiesAddRatio = function(caster, receiver)
            return 0
        end,
        persistent = true
    }

    self.ex1BuffSave = {
        skill = self,
        remark = "mark",
        duration = TigerShoot.saveDurationConfig,
        removalCondition = function(remainingTime, caster, receiver)
            return math.cmpf(remainingTime, 0) <= 0
        end,
        abilitiesAddRatio = function(caster, receiver)
            return 0
        end,
        persistent = true
    }
end

return TigerShootEx1

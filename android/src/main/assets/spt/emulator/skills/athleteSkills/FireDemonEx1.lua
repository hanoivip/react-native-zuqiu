local Skill = import("../Skill")
local FireDemon = import("./FireDemon")
local TigerShootEx1 = import("./TigerShootEx1")

local FireDemonEx1 = class(TigerShootEx1, "FireDemonEx1")
FireDemonEx1.id = "D06_A_1"
FireDemonEx1.alias = "飞火流星"

-- 进球后Ex效果触发概率
FireDemonEx1.minGoalProbabilityConfig = 0.2
FireDemonEx1.maxGoalProbabilityConfig = 0.2
-- 进球后Ex效果持续时间
FireDemonEx1.goalDurationConfig = 30
-- 被扑后Ex效果触发概率
FireDemonEx1.minSaveProbabilityConfig = 0.35
FireDemonEx1.maxSavelProbabilityConfig = 0.35
-- 被扑后Ex效果持续时间
FireDemonEx1.saveDurationConfig = 30

function FireDemonEx1:ctor(level)
    if FireDemon.initConfig then
        FireDemon:initConfig(self)
    end
    TigerShootEx1.ctor(self, level)

    self.ex1BuffGoal.duration = FireDemonEx1.goalDurationConfig
    self.ex1BuffSave.duration = FireDemonEx1.saveDurationConfig
    self.ex1ProbabilityGoal = Skill.lerpLevel(FireDemonEx1.minGoalProbabilityConfig, FireDemonEx1.maxGoalProbabilityConfig, level)
    self.ex1ProbabilitySave = Skill.lerpLevel(FireDemonEx1.minSaveProbabilityConfig, FireDemonEx1.maxSavelProbabilityConfig, level)
end

return FireDemonEx1

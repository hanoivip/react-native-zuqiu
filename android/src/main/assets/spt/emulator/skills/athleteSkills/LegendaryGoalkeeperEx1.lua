local Skill = import("../Skill")
local LegendaryGoalkeeper = import("./LegendaryGoalkeeper")

local LegendaryGoalkeeperEx1 = class(LegendaryGoalkeeper, "LegendaryGoalkeeperEx1")
LegendaryGoalkeeperEx1.id = "E03_1"
LegendaryGoalkeeperEx1.alias = "门神下凡"

-- 无视凌空抽射技能加成的概率
local minProbability = 0.4
local maxProbability = 0.4

function LegendaryGoalkeeperEx1:ctor(level)
    LegendaryGoalkeeper.ctor(self, level)
    self.ex1Probability = Skill.lerpLevel(minProbability, maxProbability, level)
end

function LegendaryGoalkeeperEx1:enterField(athlete)
    LegendaryGoalkeeper.enterField(self, athlete)
end

return LegendaryGoalkeeperEx1
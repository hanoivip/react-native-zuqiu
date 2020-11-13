local Skill = import("../Skill")
local LegendaryGoalkeeper = import("./LegendaryGoalkeeper")

local LegendaryGoalkeeperA = class(LegendaryGoalkeeper, "LegendaryGoalkeeperA")
LegendaryGoalkeeperA.id = "E03_A"
LegendaryGoalkeeperA.alias = "伯纳乌天神"

local minAddConfig = 0.132
local maxAddConfig = 1.32
local minAddComposureMultiply = 1.056
local maxAddComposureMultiply = 10.56

function LegendaryGoalkeeperA:ctor(level)
    LegendaryGoalkeeper.ctor(self, level)
    self.addComposureMultiply = Skill.lerpLevel(minAddComposureMultiply, maxAddComposureMultiply, level)
    self.addRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)
end

function LegendaryGoalkeeperA:enterField(athlete)
    LegendaryGoalkeeper.enterField(self, athlete)
end

return LegendaryGoalkeeperA
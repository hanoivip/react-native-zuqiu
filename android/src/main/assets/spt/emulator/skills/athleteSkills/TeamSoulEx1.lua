local Skill = import("../Skill")
local TeamSoul = import("./TeamSoul")

local TeamSoulEx1 = class(TeamSoul, "TeamSoulEx1")
TeamSoulEx1.id = "F09_1"
TeamSoulEx1.alias = "球队灵魂"

-- 技能发动概率
local minProbability = 0.4
local maxProbability = 0.4

function TeamSoulEx1:ctor(level)
    TeamSoul.ctor(self, level)
    self.ex1Probability = Skill.lerpLevel(minProbability, maxProbability, level)
end

function TeamSoulEx1:enterField(athlete)
    TeamSoul.enterField(self, athlete)
end

return TeamSoulEx1
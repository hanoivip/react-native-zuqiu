local Skill = import("../Skill")
local GodReaction = import("./GodReaction")

local GodReactionEx1 = class(GodReaction, "GodReactionEx1")
GodReactionEx1.id = "E02_1"
GodReactionEx1.alias = "神级反应"

-- 无视大力头槌技能加成的概率
local minProbability = 0.4
local maxProbability = 0.4

function GodReactionEx1:ctor(level)
    GodReaction.ctor(self, level)
    self.ex1Probability = Skill.lerpLevel(minProbability, maxProbability, level)
end

function GodReactionEx1:enterField(athlete)
    GodReaction.enterField(self, athlete)
end

return GodReactionEx1
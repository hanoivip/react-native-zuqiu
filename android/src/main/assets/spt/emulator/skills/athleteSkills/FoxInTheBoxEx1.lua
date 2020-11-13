local Skill = import("../Skill")
local FoxInTheBox = import("./FoxInTheBox")

local FoxInTheBoxEx1 = class(FoxInTheBox, "FoxInTheBoxEx1")
FoxInTheBoxEx1.id = "D02_1"
FoxInTheBoxEx1.alias = "禁区之狐"

local minProbabilityConfig = 0.3
local maxProbabilityConfig = 0.3

function FoxInTheBoxEx1:ctor(level)
    FoxInTheBox.ctor(self, level)
    self.ex1Probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
end

return FoxInTheBoxEx1

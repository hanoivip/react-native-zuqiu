local Skill = import("../Skill")
local PowerfulHeader = import("./PowerfulHeader")

local PowerfulHeaderEx1 = class(PowerfulHeader, "PowerfulHeaderEx1")
PowerfulHeaderEx1.id = "D03_1"
PowerfulHeaderEx1.alias = "大力头槌"

local minProbabilityConfig = 0.35
local maxProbabilityConfig = 0.35

function PowerfulHeaderEx1:ctor(level)
    PowerfulHeader.ctor(self, level)
    self.ex1Probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
end

return PowerfulHeaderEx1

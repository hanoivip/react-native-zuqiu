local Skill = import("../Skill")
local ZeroError = import("./ZeroError")

local ZeroErrorEx1 = class(ZeroError, "ZeroErrorEx1")
ZeroErrorEx1.id = "E01_1"
ZeroErrorEx1.alias = "零失误"

local minProbabilityConfig = 0.35
local maxProbabilityConfig = 0.35

function ZeroErrorEx1:ctor(level)
    ZeroError.ctor(self, level)
    self.ex1Probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
end

function ZeroErrorEx1:enterField(athlete)
    ZeroError.enterField(self, athlete)
end

return ZeroErrorEx1
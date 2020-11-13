local Skill = import("../Skill")
local CalmShoot = import("./CalmShoot")

local CalmShootEx1 = class(CalmShoot, "CalmShootEx1")
CalmShootEx1.id = "D01_1"
CalmShootEx1.alias = "冷静推射"

local minProbabilityConfig = 0.6
local maxProbabilityConfig = 0.6
local minDecreaseConfig = 0.7
local maxDecreaseConfig = 0.7

function CalmShootEx1:ctor(level)
    CalmShoot.ctor(self, level)
    self.ex1Probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
    self.ex1EffectRatio = Skill.lerpLevel(minDecreaseConfig, maxDecreaseConfig, level)
end

return CalmShootEx1
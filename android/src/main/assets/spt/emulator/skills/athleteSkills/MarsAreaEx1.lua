local Skill = import("../Skill")
local MarsArea = import("./MarsArea")
local HeavyGunnerEx1 = import("./HeavyGunnerEx1")

local MarsAreaEx1 = class(HeavyGunnerEx1, "MarsAreaEx1")
MarsAreaEx1.id = "D07_A_1"
MarsAreaEx1.alias = "EX战神区域"

-- 干扰下降百分比
local minProbabilityConfig = 0.2
local maxProbabilityConfig = 0.2

function MarsAreaEx1:ctor(level)
    if MarsArea.initConfig then
        MarsArea:initConfig(self)
    end
    HeavyGunnerEx1.ctor(self, level)
    self.exa1InfluenceDecreaseRate = -Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
end

return MarsAreaEx1

local Skill = import("../Skill")
local VolleyShoot = import("./VolleyShoot")

local VolleyShootEx1 = class(VolleyShoot, "VolleyShootEx1")
VolleyShootEx1.id = "D04_1"
VolleyShootEx1.alias = "凌空抽射"

local minProbabilityConfig = 0.3
local maxProbabilityConfig = 0.3

function VolleyShootEx1:ctor(level)
    VolleyShoot.ctor(self, level)
    self.ex1Probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
end

return VolleyShootEx1

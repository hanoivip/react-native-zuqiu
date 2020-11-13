local Skill = import("../Skill")
local FreeKickMaster = import("./FreeKickMaster")

local FreeKickMasterEx1 = class(FreeKickMaster, "FreeKickMasterEx1")
FreeKickMasterEx1.id = "F02_1"
FreeKickMasterEx1.alias = "任意球大师"

local minCornerKickProbility = 0.4
local maxCornerKickProbility = 0.598

function FreeKickMasterEx1:ctor(level)
    FreeKickMaster.ctor(self, level)
    self.ex1Probability = Skill.lerpLevel(minCornerKickProbility, maxCornerKickProbility, level)
end

return FreeKickMasterEx1

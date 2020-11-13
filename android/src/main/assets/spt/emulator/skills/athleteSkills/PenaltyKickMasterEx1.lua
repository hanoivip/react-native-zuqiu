local Skill = import("../Skill")
local PenaltyKickMaster = import("./PenaltyKickMaster")

local PenaltyKickMasterEx1 = class(PenaltyKickMaster, "PenaltyKickMasterEx1")
PenaltyKickMasterEx1.id = "F03_1"
PenaltyKickMasterEx1.alias = "点球大师"

local minTrickProbility = 0.25
local maxTrickProbility = 0.25

function PenaltyKickMasterEx1:ctor(level)
    PenaltyKickMasterEx1.super.ctor(self, level)
    self.ex1Probability = Skill.lerpLevel(minTrickProbility, maxTrickProbility, level)
end

return PenaltyKickMasterEx1

local Skill = import("../Skill")
local CornerKickMaster = import("./CornerKickMaster")

local CornerKickMasterEx1 = class(CornerKickMaster, "CornerKickMasterEx1")
CornerKickMasterEx1.id = "F04_1"
CornerKickMasterEx1.alias = "角球大师"

local cooldownConfig = 0
local minMaxAbilityMultiplies = 1.55
local maxMaxAbilityMultiplies = 6.5
local minAddConfig = 0.15
local maxAddConfig = 0.15

function CornerKickMasterEx1:ctor(level)
    CornerKickMaster.ctor(self, level)

    self.ex1AddRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)

    self.ex1Buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return false
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.ex1AddRatio
        end,
        persistent = true
    }
end

return CornerKickMasterEx1

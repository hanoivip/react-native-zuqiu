local Skill = import("../Skill")
local Tireless = import("./Tireless")
local PerpetualMotionMachineEx1 = import("./PerpetualMotionMachineEx1")

local TirelessEx1 = class(PerpetualMotionMachineEx1, "TirelessEx1")
TirelessEx1.id = "G01_A_1"
TirelessEx1.alias = "永不疲倦"

local minAddConfig = 0.08
local maxAddConfig = 0.08

function TirelessEx1:ctor(level)
    if Tireless.initConfig then
        Tireless:initConfig(self)
    end
    PerpetualMotionMachineEx1.ctor(self, level)
    self.exa1AddRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)

    self.exa1Buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return false
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.exa1AddRatio
        end,
        persistent = true
    }
end

return TirelessEx1

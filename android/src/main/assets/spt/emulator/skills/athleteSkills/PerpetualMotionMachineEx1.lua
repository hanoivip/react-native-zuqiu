local Skill = import("../Skill")
local PerpetualMotionMachine = import("./PerpetualMotionMachine")

local PerpetualMotionMachineEx1 = class(PerpetualMotionMachine, "PerpetualMotionMachineEx1")
PerpetualMotionMachineEx1.id = "G01_1"
PerpetualMotionMachineEx1.alias = "永动机"
local durationConfig = 20

function PerpetualMotionMachineEx1:ctor(level)
    PerpetualMotionMachine.ctor(self, level)
    self.ex1Buff = {
        skill = self,
        remark = "debuffBlocked",
        duration = durationConfig,
        removalCondition = function(remainingTime, caster, receiver)
            return math.cmpf(remainingTime, 0) <= 0
        end,
    }
end

function PerpetualMotionMachineEx1:enterField(athlete)
    PerpetualMotionMachine.enterField(self, athlete)
end

function PerpetualMotionMachineEx1:update(athlete)
    local updateResult = PerpetualMotionMachine.update(self, athlete)
    if updateResult then
        athlete:judgePerpetualMotionMachineEx1()
    end
end

return PerpetualMotionMachineEx1

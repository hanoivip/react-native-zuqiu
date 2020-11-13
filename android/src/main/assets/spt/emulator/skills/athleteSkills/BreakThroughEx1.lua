local Skill = import("../Skill")
local BreakThrough = import("./BreakThrough")

local BreakThroughEx1 = class(BreakThrough, "BreakThroughEx1")
BreakThroughEx1.id = "B01_1"
BreakThroughEx1.alias = "带球突破"

local durationConfig = 6

function BreakThroughEx1:ctor(level)
    BreakThrough.ctor(self, level)

    self.ex1Buff = {
        skill = self,
        remark = "debuffBlocked",
        duration = durationConfig,
        removalCondition = function(remainingTime, caster, receiver)
            return math.cmpf(remainingTime, 0) <= 0
        end,
    }
end

return BreakThroughEx1

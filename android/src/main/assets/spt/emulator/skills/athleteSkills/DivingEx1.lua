local Skill = import("../Skill")
local Diving = import("./Diving")

local DivingEx1 = class(Diving, "DivingEx1")
DivingEx1.id = "B02_1"
DivingEx1.alias = "跳水"

local minProbabilityConfig = 0.6
local maxProbabilityConfig = 0.6
local durationConfig = 20

function DivingEx1:ctor(level)
    Diving.ctor(self, level)
    self.ex1Probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)

    self.ex1Debuff = {
        skill = self,
        remark = "canNotDefend",
        duration = durationConfig,
        removalCondition = function(remainingTime, caster, receiver)
            return math.cmpf(remainingTime, 0) <= 0
        end,
        abilitiesAddRatio = function(caster, receiver)
            return 0
        end,
    }
end

return DivingEx1

local Skill = import("../Skill")
local SlidingTackle = import("./SlidingTackle")

local SlidingTackleEx1 = class(SlidingTackle, "SlidingTackleEx1")
SlidingTackleEx1.id = "A01_1"
SlidingTackleEx1.alias = "飞铲"

local durationConfig = 30
local minProbabilityConfig = 0.6
local maxProbabilityConfig = 0.6
local minSubConfig = 0.6
local maxSubConfig = 0.6

function SlidingTackleEx1:ctor(level)
    SlidingTackle.ctor(self, level)

    self.ex1Probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
    self.ex1SubRatio = -Skill.lerpLevel(minSubConfig, maxSubConfig, level)

    self.ex1Debuff = {
        skill = self,
        duration = durationConfig,
        removalCondition = function(remainingTime, caster, receiver)
            return math.cmpf(remainingTime, 0) <= 0
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.ex1SubRatio
        end,
    }
end

return SlidingTackleEx1

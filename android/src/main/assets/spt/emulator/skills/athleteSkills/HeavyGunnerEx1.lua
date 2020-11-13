local Skill = import("../Skill")
local HeavyGunner = import("./HeavyGunner")

local HeavyGunnerEx1 = class(HeavyGunner, "HeavyGunnerEx1")
HeavyGunnerEx1.id = "D07_1"
HeavyGunnerEx1.alias = "重炮手"

local minAbilitiesSumMultiply = 0.05
local maxAbilitiesSumMultiply = 0.105
local minProbabilityConfig = 1
local maxProbabilityConfig = 1

function HeavyGunnerEx1:ctor(level)
    HeavyGunner.ctor(self, level)
    self.ex1Probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
    self.extraAbilitiesSumAddRatio = Skill.lerpLevel(minAbilitiesSumMultiply, maxAbilitiesSumMultiply, level)

    self.ex1MarkedBuff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return caster.team:isDefendRole()
        end,
        abilitiesAddRatio = function(caster, receiver)
            return 0
        end,
    }
end

return HeavyGunnerEx1

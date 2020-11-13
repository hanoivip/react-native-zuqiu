local Skill = import("../Skill")

local TheKingOfTheSamba = class(Skill, "TheKingOfTheSamba")
TheKingOfTheSamba.id = "LR_NEYMARJR2"
TheKingOfTheSamba.alias = "桑巴之王"

local minAddConfig = 0.2
local maxAddConfig = 0.2
local minSubConfig = 0.15
local maxSubConfig = 0.15
local minProbabilityConfig = 0.5
local maxProbabilityConfig = 0.5
local durationConfig = 30

function TheKingOfTheSamba:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.remainingCooldown = 0
    self.level = level
    self.addRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)
    self.subRatio = -Skill.lerpLevel(minSubConfig, maxSubConfig, level)
    self.probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)

    self.buff = {
        skill = self,
        duration = durationConfig,
        removalCondition = function(remainingTime, caster, receiver)
            return math.cmpf(remainingTime, 0) <= 0
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end
    }

    self.debuff = {
        skill = self,
        duration = durationConfig,
        removalCondition = function(remainingTime, caster, receiver)
            return math.cmpf(remainingTime, 0) <= 0
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.subRatio
        end
    }

end

return TheKingOfTheSamba
local Skill = import("../Skill")

local InterceptMasterEx1 = class(Skill, "InterceptMasterEx1")
InterceptMasterEx1.id = "Z04_1"
InterceptMasterEx1.alias = "拦截大师"

local cooldownConfig = 0
local minProbabilityConfig = 0.2
local maxProbabilityConfig = 0.2
local minAddSuccessProbabilityConfig = 0.2
local maxAddSuccessProbabilityConfig = 0.2

function InterceptMasterEx1:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.cooldown = cooldownConfig
    self.remainingCooldown = 0
    self.probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
    self.addSuccessProbability = Skill.lerpLevel(minAddSuccessProbabilityConfig, maxAddSuccessProbabilityConfig, level)

    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return true
        end,
        successProbilityModifier = function(probability, caster, receiver)
            return math.clamp(probability + self.addSuccessProbability, 0.01, 0.99)
        end
    }
end

return InterceptMasterEx1

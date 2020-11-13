local Skill = import("../Skill")

local DribbleMasterEx1 = class(Skill, "DribbleMasterEx1")
DribbleMasterEx1.id = "Z02_1"
DribbleMasterEx1.alias = "带球大师"

local cooldownConfig = 0
local minProbabilityConfig = 0.1
local maxProbabilityConfig = 0.1
local minAddSuccessProbabilityConfig = 0.15
local maxAddSuccessProbabilityConfig = 0.15

function DribbleMasterEx1:ctor(level)
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

return DribbleMasterEx1

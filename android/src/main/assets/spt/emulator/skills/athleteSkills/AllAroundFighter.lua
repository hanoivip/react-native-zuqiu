local Skill = import("../Skill")

local AllAroundFighter = class(Skill, "AllAroundFighter")
AllAroundFighter.id = "LR_WROONEY2"
AllAroundFighter.alias = "全能斗士"

local minProbabilityConfig = 1
local maxProbabilityConfig = 1
local minAddRatio = 0.08
local maxAddRatio = 0.08
local minSubRatio = 0.1
local maxSubRatio = 0.1

function AllAroundFighter:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    self.probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
    self.addRatio = Skill.lerpLevel(minAddRatio, maxAddRatio, level)
    self.subRatio = -Skill.lerpLevel(minSubRatio, maxSubRatio, level)

    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return false
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end,
        persistent = true
    }

    self.debuff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return false
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.subRatio
        end,
        persistent = true
    }
end

return AllAroundFighter

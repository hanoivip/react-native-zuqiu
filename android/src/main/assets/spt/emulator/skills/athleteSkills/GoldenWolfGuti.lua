local Skill = import("../Skill")

local GoldenWolfGuti = class(Skill, "GoldenWolfGuti")
GoldenWolfGuti.id = "LR_GUTI2"
GoldenWolfGuti.alias = "金狼古蒂"

local minAddConfig = 0.25
local maxAddConfig = 0.25
local minSubConfig = 0.25
local maxSubConfig = 0.25
local minProbabilityConfig = 1
local maxProbabilityConfig = 1

function GoldenWolfGuti:ctor(level)
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
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.onfieldId == nil
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end,
        persistent = true
    }

    self.debuff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.onfieldId == nil
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.subRatio
        end,
        persistent = true
    }

end

return GoldenWolfGuti
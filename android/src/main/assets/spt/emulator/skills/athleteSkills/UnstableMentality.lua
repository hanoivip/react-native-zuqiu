local Skill = import("../Skill")

local UnstableMentality = class(Skill, "UnstableMentality")
UnstableMentality.id = "LR_MOZIL2"
UnstableMentality.alias = "不稳定心态"

local cooldownConfig = 0
local minAddConfig = 0.25
local maxAddConfig = 0.25
local minSubConfig = 0.1
local maxSubConfig = 0.1

function UnstableMentality:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    self.addRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)
    self.subRatio = -Skill.lerpLevel(minSubConfig, maxSubConfig, level)

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

return UnstableMentality
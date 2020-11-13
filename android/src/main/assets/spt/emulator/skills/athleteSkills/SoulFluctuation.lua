local Skill = import("../Skill")

local SoulFluctuation = class(Skill, "SoulFluctuation")
SoulFluctuation.id = "M02"
SoulFluctuation.alias = "心灵波动"

local cooldownConfig = 0
local minAddConfig = 0.08
local maxAddConfig = 8
local minSubConfig = 0.04
local maxSubConfig = 4

function SoulFluctuation:ctor(level)
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

return SoulFluctuation
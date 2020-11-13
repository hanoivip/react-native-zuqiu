local Skill = import("../Skill")

local Battery = class(Skill, "Battery")
Battery.id = "M05"
Battery.alias = "炮台"

local cooldownConfig = 0
local minAddConfig = 0.06
local maxAddConfig = 6

function Battery:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    self.addRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)

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
end

return Battery
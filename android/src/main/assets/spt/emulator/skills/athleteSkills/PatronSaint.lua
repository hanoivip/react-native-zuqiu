local Skill = import("../Skill")

local PatronSaint = class(Skill, "PatronSaint")
PatronSaint.id = "M10"
PatronSaint.alias = "守护神"

local cooldownConfig = 0
local minAddConfig = 0.05
local maxAddConfig = 5

function PatronSaint:ctor(level)
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

return PatronSaint
local Skill = import("../Skill")

local ToughGetGoing = class(Skill, "ToughGetGoing")
ToughGetGoing.id = "M07"
ToughGetGoing.alias = "越挫越勇"

local cooldownConfig = 0
local minAddConfig = 0.08
local maxAddConfig = 8

function ToughGetGoing:ctor(level)
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

return ToughGetGoing
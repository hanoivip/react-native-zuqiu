local Skill = import("../Skill")
local AIConstants = import("../../AIConstants")

local DefendTactics = class(Skill, "DefendTactics")
DefendTactics.id = "M06"
DefendTactics.alias = "坚守策略"

local cooldownConfig = 0
local minAddConfig = 0.13
local maxAddConfig = 13

function DefendTactics:ctor(level)
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

return DefendTactics
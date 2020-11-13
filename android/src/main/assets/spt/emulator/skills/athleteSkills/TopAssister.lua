local Skill = import("../Skill")

local TopAssister = class(Skill, "TopAssister")
TopAssister.id = "M04"
TopAssister.alias = "助攻王"

local cooldownConfig = 0
local minAddConfig = 0.06
local maxAddConfig = 6

function TopAssister:ctor(level)
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

return TopAssister
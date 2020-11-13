local Skill = import("../Skill")

local Leadership = class(Skill, "Leadership")
Leadership.id = "M11"
Leadership.alias = "领导力"

local cooldownConfig = 0
local minAddConfig = 0.08
local maxAddConfig = 8

function Leadership:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    self.addRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)

    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.team:isAttackRole()
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end,
      }
end

return Leadership
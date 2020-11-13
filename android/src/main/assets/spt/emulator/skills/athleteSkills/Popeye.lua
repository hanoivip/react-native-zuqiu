local Skill = import("../Skill")

local Popeye = class(Skill, "Popeye")
Popeye.id = "F05"
Popeye.alias = "大力水手"

local minMaxAbilityMultiplies = 1.33
local maxMaxAbilityMultiplies = 4.3

function Popeye:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.cooldown = 0
    self.remainingCooldown = 0

    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return not receiver:hasBall()
        end,
        abilitiesModifier = function(abilities, caster, receiver)
            abilities.pass = receiver.maxInitAbility * Skill.lerpLevel(minMaxAbilityMultiplies, maxMaxAbilityMultiplies, level)
        end
    }
end

return Popeye

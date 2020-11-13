local Skill = import("../Skill")

local CornerKickMaster = class(Skill, "CornerKickMaster")
CornerKickMaster.id = "F04"
CornerKickMaster.alias = "角球大师"

local minMaxAbilityMultiplies = 1.55
local maxMaxAbilityMultiplies = 6.5

function CornerKickMaster:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.cooldown = 0
    self.remainingCooldown = 0

    self.buff = {
        skill = self,
        remark = "base",
        removalCondition = function(remainingTime, caster, receiver)
            return not receiver:hasBall()
        end,
        abilitiesModifier = function(abilities, caster, receiver)
            abilities.pass = abilities.pass + receiver.maxInitAbility * Skill.lerpLevel(minMaxAbilityMultiplies, maxMaxAbilityMultiplies, level) - receiver.initAbilities.pass               
        end
    }
end

return CornerKickMaster

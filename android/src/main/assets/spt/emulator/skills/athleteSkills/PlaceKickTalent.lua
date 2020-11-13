local Skill = import("../Skill")
local Field = import("../../Field")

local PlaceKickTalent = class(Skill, "PlaceKickTalent")
PlaceKickTalent.id = "M03"
PlaceKickTalent.alias = "定位球天赋"

local cooldownConfig = 0
local minMaxAbilityMultiply = 0.15
local maxMaxAbilityMultiply = 15

function PlaceKickTalent:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    self.maxAbilityMultiply = Skill.lerpLevel(minMaxAbilityMultiply, maxMaxAbilityMultiply, level)

    self.passBuff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return not receiver:hasBall()
        end,
        abilitiesModifier = function(abilities, caster, receiver)
            abilities.pass = abilities.pass +  receiver.initAbilities.pass * Skill.lerpLevel(minMaxAbilityMultiply, maxMaxAbilityMultiply, level)
        end
    }

    self.shootBuff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return not receiver:hasBall()
        end,
        abilitiesModifier = function(abilities, caster, receiver)
            abilities.shoot = abilities.shoot +  receiver.initAbilities.shoot * Skill.lerpLevel(minMaxAbilityMultiply, maxMaxAbilityMultiply, level)
        end
    }
end

return PlaceKickTalent
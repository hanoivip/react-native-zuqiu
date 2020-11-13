local Skill = import("../Skill")
local Field = import("../../Field")

local FreeKickMaster = class(Skill, "FreeKickMaster")
FreeKickMaster.id = "F02"
FreeKickMaster.alias = "任意球大师"

local minMaxAbilityMultiply = 1.55
local maxMaxAbilityMultiply = 6.5

function FreeKickMaster:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    self.maxAbilityMultiply = Skill.lerpLevel(minMaxAbilityMultiply, maxMaxAbilityMultiply, level)

    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return not receiver:hasBall()
        end,
        abilitiesModifier = function(abilities, caster, receiver)
            if Field.isInWingDirectFreeKickArea(receiver.match.ball.position, receiver.team:getSign()) then
                abilities.pass = abilities.pass + receiver.maxInitAbility * Skill.lerpLevel(minMaxAbilityMultiply, maxMaxAbilityMultiply, level) - receiver.initAbilities.pass               
            end
        end
    }
end

return FreeKickMaster

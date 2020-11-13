local Skill = import("../Skill")

local PenaltyKickMaster = class(Skill, "PenaltyKickMaster")
PenaltyKickMaster.id = "F03"
PenaltyKickMaster.alias = "点球大师"

local minMaxAbilityMultiply = 1.55
local maxMaxAbilityMultiply = 6.5

function PenaltyKickMaster:ctor(level)
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
    }
end

return PenaltyKickMaster

local Skill = import("../Skill")

local AdaptionMaster = class(Skill, "AdaptionMaster")
AdaptionMaster.id = "M15"
AdaptionMaster.alias = "适应家"

local cooldownConfig = 0
local minImmunityConfig = 0.33
local maxImmunityConfig = 33

function AdaptionMaster:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    self.immunityRatio = math.max(1 - Skill.lerpLevel(minImmunityConfig, maxImmunityConfig, level), 0)

    self.buff = {
        skill = self,
        remark = "ignoreCannotAddBuffDebuff",
        removalCondition = function(remainingTime, caster, receiver)
            return false
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.immunityRatio
        end,
        persistent = true
    }
end

function AdaptionMaster:enterField(athlete)
    athlete:castSkill(AdaptionMaster)
end

return AdaptionMaster
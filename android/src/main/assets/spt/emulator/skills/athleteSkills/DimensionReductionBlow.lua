local Skill = import("../Skill")

local DimensionReductionBlow = class(Skill, "DimensionReductionBlow")
DimensionReductionBlow.id = "LR_SERGIORAMOS2"
DimensionReductionBlow.alias = "降维打击"

local cooldownConfig = 20
local minSubConfig = 0.4
local maxSubConfig = 0.4
local durationConfig = 30

function DimensionReductionBlow:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.cooldown = cooldownConfig
    self.remainingCooldown = 0
    self.subRatio = -Skill.lerpLevel(minSubConfig, maxSubConfig, level)

    self.debuff = {
        skill = self,
        duration = durationConfig,
        removalCondition = function(remainingTime, caster, receiver)
            return math.cmpf(remainingTime, 0) <= 0
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.subRatio
        end,
    }
end

return DimensionReductionBlow
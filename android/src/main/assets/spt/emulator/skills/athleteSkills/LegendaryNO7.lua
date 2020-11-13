local Skill = import("../Skill")

local LegendaryNO7 = class(Skill, "LegendaryNO7")
LegendaryNO7.id = "LR_CRONALDO2"
LegendaryNO7.alias = "7号传奇"

local durationConfig = 60
local minSubConfig = 0.5
local maxSubConfig = 0.5

function LegendaryNO7:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
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

return LegendaryNO7
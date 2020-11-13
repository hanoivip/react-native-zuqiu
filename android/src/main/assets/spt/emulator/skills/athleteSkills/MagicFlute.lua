local Skill = import("../Skill")

local MagicFlute = class(Skill, "MagicFlute")
MagicFlute.id = "LR_LMODRIC2"
MagicFlute.alias = "魔笛"

local cooldownConfig = 0
local minAddConfig = 0.15
local maxAddConfig = 0.15
local minSubConfig = 0.15
local maxSubConfig = 0.15
local buffDurationConfig = 60
local deBuffDurationConfig = 60

function MagicFlute:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    self.addRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)
    self.subRatio = -Skill.lerpLevel(minSubConfig, maxSubConfig, level)

    self.buff = {
        skill = self,
        duration = buffDurationConfig,
        removalCondition = function(remainingTime, caster, receiver)
            return math.cmpf(remainingTime, 0) <= 0
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end,
    }

    self.debuff = {
        skill = self,
        duration = deBuffDurationConfig,
        removalCondition = function(remainingTime, caster, receiver)
            return math.cmpf(remainingTime, 0) <= 0
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.subRatio
        end,
    }

end

return MagicFlute
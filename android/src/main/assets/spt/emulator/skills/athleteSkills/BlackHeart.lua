local Skill = import("../Skill")

local BlackHeart = class(Skill, "BlackHeart")
BlackHeart.id = "LR_NKANTE2"
BlackHeart.alias = "黑色心脏"

local cooldownConfig = 0
local minAddConfig = 0.1
local maxAddConfig = 0.1
local durationConfig = 50

function BlackHeart:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    self.addRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)

    self.buff = {
        skill = self,
        remark = "self",
        removalCondition = function(remainingTime, caster, receiver)
            return false
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end,
        persistent = true
    }

    self.debuff = {
        skill = self,
        remark = "enemy",
        duration = durationConfig,
        removalCondition = function(remainingTime, caster, receiver)
            return math.cmpf(remainingTime, 0) <= 0
        end,
        abilitiesAddRatio = function(caster, receiver)
            return -self.addRatio
        end
    }
end

return BlackHeart
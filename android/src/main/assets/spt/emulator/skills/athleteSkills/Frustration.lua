local Skill = import("../Skill")

local Frustration = class(Skill, "Frustration")
Frustration.id = "M12"
Frustration.alias = "受挫心理"

local cooldownConfig = 0
local minAddConfig = 0.15
local maxAddConfig = 15
local minSubConfig = 0.1
local maxSubConfig = 10

function Frustration:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    self.addRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)

    self.buff = {
        skill = self,
        remark = "ignoreCannotAddBuffDebuff",
        removalCondition = function(remainingTime, caster, receiver)
            return false
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end,
        persistent = true
    }

    self.subRatio = -Skill.lerpLevel(minSubConfig, maxSubConfig, level)
    self.debuff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return false
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.subRatio
        end,
        persistent = true
    }
end

function Frustration:enterField(athlete)
    athlete:castSkill(Frustration)
    athlete:addBuff(self.buff, athlete)
end

return Frustration
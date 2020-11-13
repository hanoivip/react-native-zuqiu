local Skill = import("../Skill")

local DefendDeterrent = class(Skill, "DefendDeterrent")
DefendDeterrent.id = "G05"
DefendDeterrent.alias = "防守威慑"

local minProbabilityConfig = 0.18
local maxProbabilityConfig = 0.18
local minSubConfig = 0.15
local maxSubConfig = 1.14

function DefendDeterrent:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.cooldown = cooldownConfig
    self.remainingCooldown = 0
    self.probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
    self.subRatio = -Skill.lerpLevel(minSubConfig, maxSubConfig, level)

    self.debuff = {
        skill = self,
        remark = "cannotAddBuff",
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.team:isDefendRole()
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.subRatio
        end,
    }
end

return DefendDeterrent

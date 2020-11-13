local Skill = import("../Skill")

local AttackDeterrent = class(Skill, "AttackDeterrent")
AttackDeterrent.id = "G04"
AttackDeterrent.alias = "进攻威慑"

local minProbabilityConfig = 0.18
local maxProbabilityConfig = 0.18
local minSubConfig = 0.15
local maxSubConfig = 1.14

function AttackDeterrent:ctor(level)
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
            return receiver.team:isAttackRole()
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.subRatio
        end,
    }
end

return AttackDeterrent

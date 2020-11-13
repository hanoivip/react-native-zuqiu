local Skill = import("../Skill")

local LegendaryBloodEx1 = class(Skill, "LegendaryBloodEx1")
LegendaryBloodEx1.id = "Z26_1"
LegendaryBloodEx1.alias = "传奇血液"

local cooldownConfig = 0
local minProbabilityConfig = 0.15
local maxProbabilityConfig = 0.15
local minSubConfig = 0.25
local maxSubConfig = 0.25

function LegendaryBloodEx1:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.cooldown = cooldownConfig
    self.remainingCooldown = 0
    self.probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
    self.subRatio = -Skill.lerpLevel(minSubConfig, maxSubConfig, level)

    self.attackBuff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return caster.team:isDefendRole()
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.subRatio
        end,
    }

    self.defendBuff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return caster.team:isAttackRole()
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.subRatio
        end,
    }

end

return LegendaryBloodEx1

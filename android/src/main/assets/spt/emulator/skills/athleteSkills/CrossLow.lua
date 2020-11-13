local Skill = import("../Skill")

local CrossLow = class(Skill, "CrossLow")
CrossLow.id = "C03"
CrossLow.alias = "下底传中"

local cooldownConfig = 0
local minProbabilityConfig = 1
local maxProbabilityConfig = 1
CrossLow.minPassConfig = 0.55
CrossLow.maxPassConfig = 5.5

function CrossLow:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.cooldown = cooldownConfig
    self.remainingCooldown = 0
    self.probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
    self.passAddConfig = Skill.lerpLevel(self.minPassConfig, self.maxPassConfig, level)

    self.buff = {
        skill = self,
        remark = "base",
        removalCondition = function(remainingTime, caster, receiver)
            return not receiver:hasBall()
        end,
        abilitiesModifier = function(abilities, caster, receiver)
             abilities.pass = abilities.pass + receiver.initAbilities.pass * self.passAddConfig
        end
    }
end

return CrossLow

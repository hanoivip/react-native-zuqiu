local Skill = import("../Skill")

local ThroughBall = class(Skill, "ThroughBall")
ThroughBall.id = "C01"
ThroughBall.alias = "手术刀直塞"

local cooldownConfig = 0
local minProbabilityConfig = 1
local maxProbabilityConfig = 1
ThroughBall.minPassConfig = 0.55
ThroughBall.maxPassConfig = 5.5

function ThroughBall:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.cooldown = cooldownConfig
    self.remainingCooldown = 0
    self.probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)

    self.buff = {
        skill = self,
        remark = "base",
        removalCondition = function(remainingTime, caster, receiver)
            return not receiver:hasBall()
        end,
        abilitiesModifier = function(abilities, caster, receiver)
            abilities.pass = abilities.pass + receiver.initAbilities.pass * Skill.lerpLevel(self.minPassConfig, self.maxPassConfig, level)
        end
    }
end

return ThroughBall

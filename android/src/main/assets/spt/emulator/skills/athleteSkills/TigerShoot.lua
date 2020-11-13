local Skill = import("../Skill")
local Ball = import("../../Ball")

local TigerShoot = class(Skill, "TigerShoot")
TigerShoot.id = "D06"
TigerShoot.alias = "猛虎射门"

local cooldownConfig = 0
local minProbabilityConfig = 1
local maxProbabilityConfig = 1
TigerShoot.minBounceShootMuliply = 0.66
TigerShoot.maxBounceShootMuliply = 6.6

function TigerShoot:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.cooldown = cooldownConfig
    self.remainingCooldown = 0
    self.probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
    self.bounceShootMuliply = Skill.lerpLevel(self.minBounceShootMuliply, self.maxBounceShootMuliply, level)

    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return (receiver.match.ball.nextTask and receiver.match.ball.nextTask.class == Ball.ShootAndSave)
                or receiver.team:isDefendRole()
        end,
    }
end

return TigerShoot

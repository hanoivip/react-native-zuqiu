local Skill = import("../Skill")

local CalmShoot = class(Skill, "CalmShoot")
CalmShoot.id = "D01"
CalmShoot.alias = "冷静推射"

local cooldownConfig = 0
local minProbabilityConfig = 1
local maxProbabilityConfig = 1
local minAddShootMultiply = 0.66
local maxAddShootMultiply = 6.6

function CalmShoot:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.cooldown = cooldownConfig
    self.remainingCooldown = 0
    self.probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
    self.addShootMultiply = Skill.lerpLevel(minAddShootMultiply, maxAddShootMultiply, level)

    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return not receiver:hasBall()
        end,
    }
end

return CalmShoot
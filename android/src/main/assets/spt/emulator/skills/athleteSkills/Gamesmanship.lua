local Skill = import("../Skill")

local Gamesmanship = class(Skill, "Gamesmanship")
Gamesmanship.id = "A02"
Gamesmanship.alias = "小动作"

local cooldownConfig = 0
Gamesmanship.minProbabilityConfig = 1
Gamesmanship.maxProbabilityConfig = 1
Gamesmanship.minDecreaseConfig = 0.22
Gamesmanship.maxDecreaseConfig = 2.2

function Gamesmanship:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.cooldown = cooldownConfig
    self.remainingCooldown = 0
    self.probability = Skill.lerpLevel(self.minProbabilityConfig, self.maxProbabilityConfig, level)
    self.addRatio = -Skill.lerpLevel(self.minDecreaseConfig, self.maxDecreaseConfig, level)

    self.buff = {
        skill = self,
        remark = "base",
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.team:isDefendRole()
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end,
    }
end

return Gamesmanship
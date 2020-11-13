local Skill = import("../Skill")

local ScarWarrior = class(Skill, "ScarWarrior")
ScarWarrior.id = "LR_FRIBERY2"
ScarWarrior.alias = "刀疤战士"

local minProbabilityConfig = 1
local maxProbabilityConfig = 1
local minAddRatio = 0.7
local maxAddRatio = 0.7
local minAddRatio1 = 0.08
local maxAddRatio1 = 0.08

function ScarWarrior:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    self.probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
    self.addRatio = Skill.lerpLevel(minAddRatio, maxAddRatio, level)
    self.addRatio1 = Skill.lerpLevel(minAddRatio1, maxAddRatio1, level)

    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.team:isDefendRole()
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end
    }

    self.buff1 = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return false
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio1
        end,
        persistent = true
    }
end

return ScarWarrior

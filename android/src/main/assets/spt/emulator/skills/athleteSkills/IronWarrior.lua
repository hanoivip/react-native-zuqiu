local Skill = import("../Skill")
local AIConstants = import("../../AIConstants")

local IronWarrior = class(Skill, "IronWarrior")
IronWarrior.id = "LR_DGODIN2"
IronWarrior.alias = "铁血战士"

local minProbabilityConfig = 1
local maxProbabilityConfig = 1
local minAddRatio = 0.25
local maxAddRatio = 0.25
local minSubRatio = 0.25
local maxSubRatio = 0.25

function IronWarrior:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    self.probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
    self.addRatio = Skill.lerpLevel(minAddRatio, maxAddRatio, level)
    self.subRatio = -Skill.lerpLevel(minSubRatio, maxSubRatio, level)

    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return caster.team.scoreState ~= AIConstants.teamScoreState.DRAW
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end,
    }

    self.debuff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return caster.team.scoreState ~= AIConstants.teamScoreState.DRAW
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.subRatio
        end,
    }
end

function IronWarrior:enterField(athlete)
    if athlete.team.scoreState == AIConstants.teamScoreState.DRAW then
        athlete:judgeIronWarrior()
    end
end

return IronWarrior

local Skill = import("../Skill")
local AIConstants = import("../../AIConstants")

local DeviseStrategies = class(Skill, "DeviseStrategies")
DeviseStrategies.id = "LR_GBUFFON2"
DeviseStrategies.alias = "运筹帷幄"

local minAddConfig = 0.25
local maxAddConfig = 0.25
local minSubConfig = 0.25
local maxSubConfig = 0.25

function DeviseStrategies:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    self.addRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)
    self.subRatio = -Skill.lerpLevel(minSubConfig, maxSubConfig, level)

    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.team.scoreState ~= AIConstants.teamScoreState.LEAD
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end,
        persistent = true
    }

    self.debuff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return caster.team.scoreState ~= AIConstants.teamScoreState.LEAD
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.subRatio
        end,
        persistent = true
    }
end

return DeviseStrategies

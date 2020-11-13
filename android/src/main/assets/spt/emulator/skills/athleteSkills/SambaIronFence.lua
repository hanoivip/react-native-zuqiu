local Skill = import("../Skill")

local SambaIronFence = class(Skill, "SambaIronFence")
SambaIronFence.id = "LR_THIAGOSILVA2"
SambaIronFence.alias = "桑巴铁栅"

local minAddConfig = 0.08
local maxAddConfig = 0.08
local minProbabilityConfig = 1
local maxProbabilityConfig = 1
local durationConfig = 40

function SambaIronFence:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.remainingCooldown = 0
    self.level = level
    self.addRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)
    self.probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)

    self.buff = {
        skill = self,
        remark = "self",
        removalCondition = function(remainingTime, caster, receiver)
            return false
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end,
        persistent = true
    }

    self.extraBuff = {
        skill = self,
        remark = "friend",
        duration = durationConfig,
        removalCondition = function(remainingTime, caster, receiver)
            return math.cmpf(remainingTime, 0) <= 0
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end
    }
end

return SambaIronFence
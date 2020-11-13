local Skill = import("../Skill")

local SelfConfidence = class(Skill, "SelfConfidence")
SelfConfidence.id = "M01"
SelfConfidence.alias = "自信心"

local cooldownConfig = 0
local minAddConfig = 0.05
local maxAddConfig = 5

function SelfConfidence:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    self.addRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)

    self.buff = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return false
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end,
        persistent = true
    }
end

return SelfConfidence
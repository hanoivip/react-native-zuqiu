local Skill = import("../Skill")

local GpiquePenetrateEverything = class(Skill, "GpiquePenetrateEverything")
GpiquePenetrateEverything.id = "LR_GPIQUE2"
GpiquePenetrateEverything.alias = "皮看穿"

local minProbabilityConfig = 0.18
local maxProbabilityConfig = 0.18

function GpiquePenetrateEverything:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.remainingCooldown = 0
    self.probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)

    self.markedBuff = {
        skill = self,
        remark = "mark",
        removalCondition = function(remainingTime, caster, receiver)
            return caster.team:isAttackRole()
        end,
        abilitiesAddRatio = function(caster, receiver)
            return 0
        end,
    }
end

return GpiquePenetrateEverything

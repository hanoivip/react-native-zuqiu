local Skill = import("../Skill")

local WindChasingBoy = class(Skill, "WindChasingBoy")
WindChasingBoy.id = "LR_MOWEN2"
WindChasingBoy.alias = "追风少年"

local minStealFailedProbabilityConfig = 0.3
local maxStealFailedProbabilityConfig = 0.3

function WindChasingBoy:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    self.stealFailedProbabilityConfig = Skill.lerpLevel(minStealFailedProbabilityConfig, maxStealFailedProbabilityConfig, level)
end

return WindChasingBoy

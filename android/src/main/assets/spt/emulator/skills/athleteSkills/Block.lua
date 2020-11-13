local Skill = import("../Skill")

local Block = class(Skill, "Block")
Block.id = "A06"
Block.alias = "封堵"

local minInterceptAndStealAddConfig = 0.55
local maxInterceptAndStealAddConfig = 5.5

function Block:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.level = level
    self.remainingCooldown = 0
    self.interceptAndStealAddConfig = Skill.lerpLevel(minInterceptAndStealAddConfig, maxInterceptAndStealAddConfig, level)
end

return Block

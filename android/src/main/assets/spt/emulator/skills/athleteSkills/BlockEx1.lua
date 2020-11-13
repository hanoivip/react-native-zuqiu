local Skill = import("../Skill")
local Block = import("./Block")

local BlockEx1 = class(Block, "BlockEx1")
BlockEx1.id = "A06_1"
BlockEx1.alias = "封堵"

-- 额外扑飞概率，同时也是二次判定时增加的扑飞概率
local minProbabilityConfig = 0.16
local maxProbabilityConfig = 0.16
function BlockEx1:ctor(level)
    Block.ctor(self, level)
    self.ex1Probability = Skill.lerpLevel(minProbabilityConfig, maxProbabilityConfig, level)
end

return BlockEx1

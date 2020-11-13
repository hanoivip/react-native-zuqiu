local Skill = import("../Skill")
local LongPassDispatch = import("./LongPassDispatch")

local LongPassDispatchEx1 = class(LongPassDispatch, "LongPassDispatchEx1")
LongPassDispatchEx1.id = "C05_1"
LongPassDispatchEx1.alias = "长传转移Ex1"

-- 清除debuff概率
LongPassDispatchEx1.minAbilityConfig = 0.3
LongPassDispatchEx1.maxAbilityConfig = 0.3

function LongPassDispatchEx1:ctor(level)
    LongPassDispatch.ctor(self, level)
    self.extraProbability = Skill.lerpLevel(LongPassDispatchEx1.minAbilityConfig, LongPassDispatchEx1.maxAbilityConfig, level)
end

return LongPassDispatchEx1

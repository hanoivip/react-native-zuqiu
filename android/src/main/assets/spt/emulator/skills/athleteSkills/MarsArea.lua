local HeavyGunner = import("./HeavyGunner")

local MarsArea = class(HeavyGunner, "MarsArea")
MarsArea.id = "D07_A"
MarsArea.alias = "战神区域"

MarsArea.minAbilitiesSumMultiply = 0.396
MarsArea.maxAbilitiesSumMultiply = 3.96

-- 初始化配置数据以复用,在基类ctor之前调用
function MarsArea:initConfig(skill)
    skill.minAbilitiesSumMultiply = self.minAbilitiesSumMultiply
    skill.maxAbilitiesSumMultiply = self.maxAbilitiesSumMultiply
end

return MarsArea

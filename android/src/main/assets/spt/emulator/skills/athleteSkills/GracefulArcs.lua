local CrossLow = import("./CrossLow")

local GracefulArcs = class(CrossLow, "GracefulArcs")
GracefulArcs.id = "C03_A"
GracefulArcs.alias = "曼妙弧线"

GracefulArcs.minPassConfig = 0.66
GracefulArcs.maxPassConfig = 6.6

-- 初始化配置数据以复用,在基类ctor之前调用
function GracefulArcs:initConfig(skill)
    skill.minPassConfig = self.minPassConfig
    skill.maxPassConfig = self.maxPassConfig
end

return GracefulArcs

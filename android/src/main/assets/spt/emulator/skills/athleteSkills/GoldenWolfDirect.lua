local ThroughBall = import("./ThroughBall")

local GoldenWolfDirect = class(ThroughBall, "GoldenWolfDirect")
GoldenWolfDirect.id = "C01_A"
GoldenWolfDirect.alias = "金狼直传"

GoldenWolfDirect.minPassConfig = 0.66
GoldenWolfDirect.maxPassConfig = 6.6

-- 初始化配置数据以复用,在基类ctor之前调用
function GoldenWolfDirect:initConfig(skill)
    skill.minPassConfig = self.minPassConfig
    skill.maxPassConfig = self.maxPassConfig
end

return GoldenWolfDirect

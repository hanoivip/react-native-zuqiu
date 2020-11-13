local PerpetualMotionMachine = import("./PerpetualMotionMachine")

local Tireless = class(PerpetualMotionMachine, "Tireless")
Tireless.id = "G01_A"
Tireless.alias = "永不疲倦"

Tireless.minAddConfig = 0.0396
Tireless.maxAddConfig = 0.396

-- 初始化配置数据以复用,在基类ctor之前调用
function Tireless:initConfig(skill)
    skill.minAddConfig = self.minAddConfig
    skill.maxAddConfig = self.maxAddConfig
end

return Tireless

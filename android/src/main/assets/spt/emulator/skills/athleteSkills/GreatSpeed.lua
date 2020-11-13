local BreakThrough = import("./BreakThrough")

local GreatSpeed = class(BreakThrough, "GreatSpeed")
GreatSpeed.id = "B01_A"
GreatSpeed.alias = "风驰电掣"

GreatSpeed.minAddDribbleConfig = 0.66
GreatSpeed.maxAddDribbleConfig = 6.6
GreatSpeed.minAddConfig = 0.264
GreatSpeed.maxAddConfig = 2.64

-- 初始化配置数据以复用,在基类ctor之前调用
function GreatSpeed:initConfig(skill)
    skill.minAddDribbleConfig = self.minAddDribbleConfig
    skill.maxAddDribbleConfig = self.maxAddDribbleConfig
    skill.minAddConfig = self.minAddConfig
    skill.maxAddConfig = self.maxAddConfig
end

return GreatSpeed

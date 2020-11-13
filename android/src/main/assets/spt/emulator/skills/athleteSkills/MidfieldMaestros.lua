local Metronome = import("./Metronome")

local MidfieldMaestros = class(Metronome, "MidfieldMaestros")
MidfieldMaestros.id = "B03_A"
MidfieldMaestros.alias = "中场指挥家"

MidfieldMaestros.minAddConfig = 0.264
MidfieldMaestros.maxAddConfig = 2.64

-- 初始化配置数据以复用,在基类ctor之前调用
function MidfieldMaestros:initConfig(skill)
    skill.minAddConfig = self.minAddConfig
    skill.maxAddConfig = self.maxAddConfig
end

return MidfieldMaestros
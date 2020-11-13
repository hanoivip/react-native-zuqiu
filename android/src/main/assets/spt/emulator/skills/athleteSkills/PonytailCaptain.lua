local DefenseCommandor = import("./DefenseCommandor")

local PonytailCaptain = class(DefenseCommandor, "PonytailCaptain")
PonytailCaptain.id = "E04_A"
PonytailCaptain.alias = "马尾统帅"

PonytailCaptain.minAddConfig = 0.132
PonytailCaptain.maxAddConfig = 1.32
PonytailCaptain.minAddCommandingMultiply = 0.66
PonytailCaptain.maxAddCommandingMultiply = 6.6

-- 初始化配置数据以复用,在基类ctor之前调用
function PonytailCaptain:initConfig(skill)
    skill.minAddConfig = self.minAddConfig
    skill.maxAddConfig = self.maxAddConfig
    skill.minAddCommandingMultiply = self.minAddCommandingMultiply
    skill.maxAddCommandingMultiply = self.maxAddCommandingMultiply
end

return PonytailCaptain

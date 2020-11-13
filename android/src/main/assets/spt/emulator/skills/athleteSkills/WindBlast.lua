local ImpactWave = import("./ImpactWave")

local WindBlast = class(ImpactWave, "WindBlast")
WindBlast.id = "D05_A"
WindBlast.alias = "旋风冲击"

WindBlast.minDecreaseConfig = 0.264
WindBlast.maxDecreaseConfig = 2.64

-- 初始化配置数据以复用,在基类ctor之前调用
function WindBlast:initConfig(skill)
    skill.minDecreaseConfig = self.minDecreaseConfig
    skill.maxDecreaseConfig = self.maxDecreaseConfig
end

return WindBlast

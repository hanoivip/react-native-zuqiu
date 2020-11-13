local CorePlayMaker = import("./CorePlayMaker")

local BlauwbrugBrain = class(CorePlayMaker, "BlauwbrugBrain")
BlauwbrugBrain.id = "C04_A"
BlauwbrugBrain.alias = "蓝桥大脑"

BlauwbrugBrain.minAbilityConfig = 0.66
BlauwbrugBrain.maxAbilityConfig = 6.6

-- 初始化配置数据以复用,在基类ctor之前调用
function BlauwbrugBrain:initConfig(skill)
    skill.minAbilityConfig = self.minAbilityConfig
    skill.maxAbilityConfig = self.maxAbilityConfig
end

return BlauwbrugBrain

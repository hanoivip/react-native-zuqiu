local Skill = import("../Skill")
local Gamesmanship = import("./Gamesmanship")

local FiercelyDogfight = class(Gamesmanship, "FiercelyDogfight")
FiercelyDogfight.id = "A02_A"
FiercelyDogfight.alias = "凶悍缠斗"

Gamesmanship.minProbabilityConfig = 1
Gamesmanship.maxProbabilityConfig = 1
Gamesmanship.minDecreaseConfig = 0.264
Gamesmanship.maxDecreaseConfig = 2.64

-- 初始化配置数据以复用,在基类ctor之前调用
function FiercelyDogfight:initConfig(skill)
    skill.minProbabilityConfig = self.minProbabilityConfig
    skill.maxProbabilityConfig = self.maxProbabilityConfig
    skill.minDecreaseConfig = self.minDecreaseConfig
    skill.maxDecreaseConfig = self.maxDecreaseConfig
end

return FiercelyDogfight
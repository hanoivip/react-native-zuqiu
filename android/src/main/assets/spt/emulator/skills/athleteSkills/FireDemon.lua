local TigerShoot = import("./TigerShoot")

local FireDemon = class(TigerShoot, "FireDemon")
FireDemon.id = "D06_A"
FireDemon.alias = "飞火流星"

FireDemon.minBounceShootMuliply = 0.792
FireDemon.maxBounceShootMuliply = 7.92

-- 初始化配置数据以复用,在基类ctor之前调用
function FireDemon:initConfig(skill)
    skill.minBounceShootMuliply = self.minBounceShootMuliply
    skill.maxBounceShootMuliply = self.maxBounceShootMuliply
end

return FireDemon

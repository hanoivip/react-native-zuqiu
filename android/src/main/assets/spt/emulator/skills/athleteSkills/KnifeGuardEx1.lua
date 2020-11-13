local Skill = import("../Skill")
local KnifeGuard = import("./KnifeGuard")

local KnifeGuardEx1 = class(KnifeGuard, "KnifeGuardEx1")
KnifeGuardEx1.id = "F06_1"
KnifeGuardEx1.alias = "带刀侍卫"

function KnifeGuardEx1:ctor(level)
    KnifeGuard.ctor(self, level)
end

return KnifeGuardEx1

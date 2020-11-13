local Skill = import("../Skill")
local AttackDeterrent = import("./AttackDeterrent")

local AttackDeterrentEx1 = class(AttackDeterrent, "AttackDeterrentEx1")
AttackDeterrentEx1.id = "G04_1"
AttackDeterrentEx1.alias = "进攻威慑Ex"

function AttackDeterrentEx1:ctor(level)
    AttackDeterrent.ctor(self, level)
end

return AttackDeterrentEx1

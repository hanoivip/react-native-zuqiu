local Skill = import("../Skill")
local DefendDeterrent = import("./DefendDeterrent")

local DefendDeterrentEx1 = class(DefendDeterrent, "DefendDeterrentEx1")
DefendDeterrentEx1.id = "G05_1"
DefendDeterrentEx1.alias = "防守威慑Ex"

function DefendDeterrentEx1:ctor(level)
    DefendDeterrent.ctor(self, level)
end

return DefendDeterrentEx1

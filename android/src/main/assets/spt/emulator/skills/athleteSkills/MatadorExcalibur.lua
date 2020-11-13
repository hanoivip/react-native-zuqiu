local Skill = import("../Skill")
local FoxInTheBox = import("./FoxInTheBox")

local MatadorExcalibur = class(FoxInTheBox, "MatadorExcalibur")
MatadorExcalibur.id = "D02_A"
MatadorExcalibur.alias = "斗牛士神剑"

local minAddShootMultiply = 0.66
local maxAddShootMultiply = 6.6

function MatadorExcalibur:ctor(level)
    FoxInTheBox.ctor(self, level)
    self.addShootMultiply = Skill.lerpLevel(minAddShootMultiply, maxAddShootMultiply, level)
end

return MatadorExcalibur

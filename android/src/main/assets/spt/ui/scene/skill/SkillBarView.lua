local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local SkillBarView = class(unity.base)

function SkillBarView:ctor()
    self.skillDesc = self.___ex.skillDesc
    self.skillPlus = self.___ex.skillPlus
end

local DefaultColor = 255
local function GetColor(color)
    return Color(color.r / DefaultColor, color.g / DefaultColor, color.b / DefaultColor)
end
local WhiteColor = {r = 196, g = 197, b = 199}
local YellowColor = {r = 237, g = 208, b = 72}
function SkillBarView:InitView(desc, plus, isCurrentInfo)
    self.skillDesc.text = lang.trans(desc)
    self.skillPlus.text = "+" .. tostring(plus)
    local useColor = isCurrentInfo and WhiteColor or YellowColor
    local color = GetColor(useColor)
    self.skillDesc.color = color
    self.skillPlus.color = color
end

return SkillBarView
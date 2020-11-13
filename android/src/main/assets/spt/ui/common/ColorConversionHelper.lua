local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local ColorConversionHelper = {}

local DefaultColorRatio = 255
function ColorConversionHelper.ConversionColor(r, g, b, a)
    r = r or 255
    g = g or 255
    b = b or 255
    a = a or 255
    local color = Color(r / DefaultColorRatio, g / DefaultColorRatio, b / DefaultColorRatio, a / DefaultColorRatio)
    return color
end

return ColorConversionHelper
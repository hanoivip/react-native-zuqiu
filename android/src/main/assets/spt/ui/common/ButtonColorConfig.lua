local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local ButtonColorConfig = {}

local NormalGradientColor = {
    { percent = 0, color = Color(254 / 255, 246 / 255, 188 / 255, 1) },
    { percent = 1, color = Color(169 / 255, 143 / 255, 82 / 255, 1) }
}

local DisableGradientColor = {
    { percent = 0, color = Color(1, 1, 1, 1) },
    { percent = 1, color = Color(139 / 255, 135 / 255, 120 / 255, 1) }
}
function ButtonColorConfig.SetNormalGradientColor(gradientComponent)
    if gradientComponent then 
        ButtonColorConfig.SetGradientColor(gradientComponent, NormalGradientColor)
    end
end

function ButtonColorConfig.SetDisableGradientColor(gradientComponent)
    if gradientComponent then 
        ButtonColorConfig.SetGradientColor(gradientComponent, DisableGradientColor)
    end
end

function ButtonColorConfig.SetGradientColor(gradientComponent, gradientColor)
    gradientComponent:ResetPointColors(table.nums(gradientColor))
    for i, v in ipairs(gradientColor) do
        gradientComponent:AddPointColors(v.percent, v.color)
    end
end

return ButtonColorConfig

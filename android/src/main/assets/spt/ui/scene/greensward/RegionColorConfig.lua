local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local RegionColorConfig = {}

RegionColorConfig.Region = {}

RegionColorConfig.Region["5"] = {
    { percent = 0, color = Color(1, 0.97, 0.86, 1) },
    { percent = 1, color = Color(0.71, 0.53, 0.17, 1) }
}

RegionColorConfig.Region["Default"] = {
    { percent = 0, color = Color(0.62, 0.25, 0.12, 1) },
    { percent = 1, color = Color(0.29, 0.17, 0.05, 1) }
}
local RegionColor = RegionColorConfig.Region

function RegionColorConfig.SetGradientColor(gradientComponent, region)
    if gradientComponent then
        local g = RegionColor[region] or RegionColor.Default
        gradientComponent:ResetPointColors(table.nums(g))
        for i, v in ipairs(g) do
            gradientComponent:AddPointColors(v.percent, v.color)
        end
    end
end

return RegionColorConfig

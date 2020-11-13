local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local CardColorConfig = {}

local DefaultColor = 255
local function ConversionColor(colorData)
    local color = Color(colorData.r / DefaultColor, colorData.g / DefaultColor, colorData.b / DefaultColor, colorData.a / DefaultColor)
    return color
end

function CardColorConfig.GetColor(quality, colorMap)
    local colorData = colorMap[tonumber(quality)]
    local color = ConversionColor(colorData)
    return color
end

local NameGradientColor = {
    ["1"] = {
            { percent = 0, color = Color(72/255, 72/255, 72/255, 1) } ,
            { percent = 1, color = Color(13/255, 13/255, 13/255, 1) } ,
          },
    ["2"] = { 
            { percent = 0, color = Color(86/255, 55/255, 34/255, 1) } ,
            { percent = 1, color = Color(35/255, 24/255, 17/255, 1) } ,
          },
    ["3"] = { 
            { percent = 0, color = Color(61/255, 99/255, 135/255, 1) } ,
            { percent = 1, color = Color(35/255, 53/255, 78/255, 1) } ,
          },
    ["4"] = {
            { percent = 0, color = Color(134/255, 111/255, 9/255, 1) } ,
            { percent = 1, color = Color(21/255, 18/255, 2/255, 1) } ,
          },
    ["5"] = { 
            { percent = 0, color = Color(250/255, 230/255, 102/255, 1) } ,
            { percent = 1, color = Color(211/255, 172/255, 54/255, 1) } ,
          },
    ["6"] = {
            { percent = 0, color = Color(183/255, 164/255, 58/255, 1) } ,
            { percent = 1, color = Color(66/255, 59/255, 2/255, 1) } ,
          },
    ["6_Plus"] = {
            { percent = 0, color = Color(243/255, 201/255, 132/255, 1) } ,
            { percent = 1, color = Color(244/255, 211/255, 150/255, 1) } ,
          },
    ["6_SL"] = {
            { percent = 0, color = Color(1, 252/255, 210/255, 1) } ,
            { percent = 1, color = Color(1, 224/255, 49/255, 1) } ,
          },
    ["7"] = { 
            { percent = 0, color = Color(231/255, 176/255, 56/255, 1) } ,
            { percent = 1, color = Color(248/255, 217/255, 81/255, 1) } ,
          },
    ["7_Legend"] = { 
            { percent = 0, color = Color(248/255, 236/255, 171/255, 1) } ,
            { percent = 1, color = Color(240/255, 186/255, 120/255, 1) } ,
          },
    ["8"] = {
            { percent = 0, color = Color(242/255, 207/255, 92/255, 1) } ,
            { percent = 1, color = Color(218/255, 161/255, 45/255, 1) } ,
          },
}

local DefaultQuality = 1
-- 方形大卡名字颜色
function CardColorConfig.GetNameColor(quality)
    local nameData = NameGradientColor[tostring(quality)]
    if not nameData then 
        nameData = NameGradientColor[tostring(DefaultQuality)]
    end
    return nameData
end

function CardColorConfig.GetPosColor(quality)
    local nameData = NameGradientColor[tostring(quality)]
    if not nameData then 
        nameData = NameGradientColor[tostring(DefaultQuality)]
    end
    return nameData
end

local NameShadowColor = {
    [1] = { r = 255, g = 255, b = 255, a = 255},
    [2] = { r = 255, g = 255, b = 255, a = 255},
    [3] = { r = 255, g = 255, b = 255, a = 255},
    [4] = { r = 255, g = 255, b = 255, a = 255},
    [5] = { r = 0, g = 0, b = 0, a = 255},
    [6] = { r = 255, g = 255, b = 255, a = 255},
    [7] = { r = 255, g = 255, b = 255, a = 255},
}

-- 方形大卡影子颜色
function CardColorConfig.GetNameShadowColor(quality)
    return CardColorConfig.GetColor(quality, NameShadowColor)
end

local LevelColor = {
    [1] = { r = 237, g = 205, b = 114, a = 255},
    [2] = { r = 242, g = 181, b = 142, a = 255},
    [3] = { r = 245, g = 240, b = 255, a = 255},
    [4] = { r = 255, g = 228, b = 145, a = 255},
    [5] = { r = 255, g = 181, b = 94, a = 255},
    [6] = { r = 237, g = 205, b = 114, a = 255},
    [7] = { r = 237, g = 205, b = 114, a = 255},
}

function CardColorConfig.GetLevelColor(quality)
    return CardColorConfig.GetColor(quality, LevelColor)
end

local LevelGradientColor = {
    ["1"] = {
            { percent = 0, color = Color(0.9686, 0.949, 0.8784, 1) } ,
            { percent = 0.34, color = Color(1, 1, 1, 1) } ,
            { percent = 0.76, color = Color(0.7725, 0.7607, 0.7059, 1) } ,
            { percent = 1, color = Color(0.8353, 0.7961, 0.7059, 1) } ,
          },
    ["2"] = { 
            { percent = 0, color = Color(1, 0.9843, 0.9725, 1) } ,
            { percent = 0.34, color = Color(0.8745, 0.7373, 0.6078, 1) } ,
            { percent = 0.76, color = Color(0.5137, 0.3686, 0.2157, 1) } ,
            { percent = 1, color = Color(0.8118, 0.6549, 0.1451, 1) } ,
          },
    ["3"] = { 
          },
    ["4"] = {
            { percent = 0, color = Color(1, 0.9725, 0.8627, 1) } ,
            { percent = 0.34, color = Color(1, 0.9059, 0.5373, 1) } ,
            { percent = 0.76, color = Color(0.7137, 0.5294, 0.1725, 1) } ,
            { percent = 1, color = Color(0.9255, 0.7961, 0.4863, 1) } ,
          },
    ["5"] = { 
            { percent = 0, color = Color(1, 0.9451, 0.7098, 1) } ,
            { percent = 0.34, color = Color(0.9961, 0.851, 0.4078, 1) } ,
            { percent = 0.76, color = Color(0.7843, 0.5451, 0.2353, 1) } ,
            { percent = 1, color = Color(0.9686, 0.8, 0.3333, 1) } ,
          },
    ["6"] = {
            { percent = 0, color = Color(1, 0.9725, 0.8627, 1) } ,
            { percent = 0.34, color = Color(1, 0.9059, 0.5373, 1) } ,
            { percent = 0.76, color = Color(0.7137, 0.5294, 0.1725, 1) } ,
            { percent = 1, color = Color(0.9255, 0.7961, 0.4863, 1) } ,
          },
    ["6_Plus"] = {
            { percent = 0, color = Color(0.99, 0.96, 0.84, 1) } ,
            { percent = 0.34, color = Color(0.95, 0.9, 0.66, 1) } ,
            { percent = 0.76, color = Color(0.78, 0.66, 0.38, 1) } ,
            { percent = 1, color = Color(0.84, 0.58, 0.39, 1) } ,
          },
    ["6_Annual"] = { 
            { percent = 0, color = Color(0.976, 0.86, 0.36, 1) } ,
            { percent = 0.34, color = Color(0.9411, 0.8941, 0.6627, 1) } ,
            { percent = 0.76, color = Color(0.8353, 0.698, 0.2784, 1) } ,
            { percent = 1, color = Color(0.435, 0.318, 0.11, 1) } ,
          },
    ["6_SL"] = { 
            { percent = 0, color = Color(0.976, 0.86, 0.36, 1) } ,
            { percent = 0.34, color = Color(0.9411, 0.8941, 0.6627, 1) } ,
            { percent = 0.76, color = Color(0.8353, 0.698, 0.2784, 1) } ,
            { percent = 1, color = Color(0.435, 0.318, 0.11, 1) } ,
          },
    ["7"] = { 
            { percent = 0, color = Color(0.9647, 0.9255, 0.7176, 1) } ,
            { percent = 0.34, color = Color(0.9411, 0.8941, 0.6627, 1) } ,
            { percent = 0.76, color = Color(0.8353, 0.698, 0.2784, 1) } ,
            { percent = 1, color = Color(0.7373, 0.7765, 0.9255, 1) } ,
          },
    ["7_Legend"] = { 
            { percent = 0, color = Color(1, 0.976, 0.882, 1) } ,
            { percent = 0.34, color = Color(0.989, 0.804, 0.518, 1) } ,
            { percent = 0.76, color = Color(0.914, 0.6, 0.4, 1) } ,
            { percent = 1, color = Color(0.918, 0.61, 0.61, 1) } ,
          },
    ["8"] = { 
            { percent = 0, color = Color(1, 0.976, 0.882, 1) } ,
            { percent = 0.34, color = Color(0.989, 0.804, 0.518, 1) } ,
            { percent = 0.76, color = Color(0.914, 0.6, 0.4, 1) } ,
            { percent = 1, color = Color(0.918, 0.61, 0.61, 1) } ,
          },
}

-- 方形和圆形大卡等级颜色共用
function CardColorConfig.GetLevelGradientColor(quality)
    local levelData = LevelGradientColor[tostring(quality)]
    if not levelData then 
        levelData = LevelGradientColor[tostring(DefaultQuality)]
    end
    return levelData
end

local NameGradientColorByCircle = {
    ["1"] = {
            { percent = 0, color = Color(0.929, 0.929, 0.929, 1) } ,
            { percent = 0.3, color = Color(0.929, 0.929, 0.929, 1) } ,
            { percent = 1, color = Color(0.69, 0.69, 0.69, 1) } 
          },
    ["2"] = { 
            { percent = 0, color = Color(1, 0.933, 0.875, 1) } ,
            { percent = 0.3, color = Color(1, 0.933, 0.875, 1) } ,
            { percent = 1, color = Color(0.592, 0.447, 0.294, 1) } 
          },
    ["3"] = { 
            { percent = 0, color = Color(0.957, 0.969, 0.969, 1) } ,
            { percent = 0.3, color = Color(957, 0.969, 0.969, 1) } ,
            { percent = 1, color = Color(0.667, 0.729, 0.749, 1) } 
          },
    ["4"] = {
            { percent = 0, color = Color(1, 0.969, 0.702, 1) } ,
            { percent = 0.3, color = Color(1, 0.969, 0.702, 1) } ,
            { percent = 1, color = Color(0.796, 0.627, 0.235, 1) } 
          },
    ["5"] = { 
            { percent = 0, color = Color(1, 0.945, 0.722, 1) } ,
            { percent = 0.3, color = Color(1, 0.945, 0.722, 1) } ,
            { percent = 1, color = Color(0.922, 0.737, 0.325, 1) } 
          },
    ["5_Plus"] = { 
            { percent = 0, color = Color(1, 0.945, 0.722, 1) } ,
            { percent = 0.3, color = Color(1, 0.945, 0.722, 1) } ,
            { percent = 1, color = Color(0.922, 0.737, 0.325, 1) } 
          },
    ["6"] = {
            { percent = 0, color = Color(1, 0.969, 0.703, 1) } ,
            { percent = 0.3, color = Color(1, 0.969, 0.703, 1) } ,
            { percent = 1, color = Color(0.796, 0.627, 0.235, 1) } 
          },
    ["6_Plus"] = {
            { percent = 0, color = Color(1, 0.969, 0.703, 1) } ,
            { percent = 0.3, color = Color(1, 0.969, 0.703, 1) } ,
            { percent = 1, color = Color(0.796, 0.627, 0.235, 1) } 
          },
    ["6_Annual"] = {
            { percent = 0, color = Color(1, 0.969, 0.703, 1) } ,
            { percent = 0.3, color = Color(1, 0.969, 0.703, 1) } ,
            { percent = 1, color = Color(0.796, 0.627, 0.235, 1) } 
          },
    ["6_SL"] = {
            { percent = 0, color = Color(244/255, 237/255, 168/255, 1) } ,
            { percent = 0.3, color = Color(245/255, 239/255, 178/255, 1) } ,
            { percent = 1, color = Color(188/255, 164/255, 102/255, 1) } 
          },
    ["7"] = { 
            { percent = 0, color = Color(1, 0.996, 0.796, 1) } ,
            { percent = 0.3, color = Color(1, 0.996, 0.796, 1) } ,
            { percent = 1, color = Color(0.796, 0.627, 0.235, 1) } 
          },
    ["7_Legend"] = { 
            { percent = 0, color = Color(1, 0.976, 0.882, 1) } ,
            { percent = 0.3, color = Color(0.989, 0.804, 0.518, 1) } ,
            { percent = 1, color = Color(0.918, 0.61, 0.61, 1) } 
          },
    ["8"] = {
            { percent = 0, color = Color(1, 1, 1, 1) } ,
            { percent = 0.3, color = Color(238/255, 214/255, 149/255, 1) } ,
            { percent = 1, color = Color(234/255, 166/255, 29/255, 1) } 
          },
}

function CardColorConfig.GetNameGradientColorWithCircleCard(quality)
    local nameData = NameGradientColorByCircle[tostring(quality)]
    if not nameData then 
        nameData = NameGradientColorByCircle[tostring(DefaultQuality)]
    end
    return nameData
end

-- 阵型大卡等级和战力颜色
local FormationCardLevelAndPowerColor = {
    [1] = { r = 49, g = 49, b = 39, a = 255},
    [2] = { r = 115, g = 87, b = 52, a = 255},
    [3] = { r = 108, g = 109, b = 109, a = 255},
    [4] = { r = 137, g = 122, b = 10, a = 255},
    [5] = { r = 255, g = 255, b = 255, a = 230},
    [6] = { r = 148, g = 135, b = 74, a = 255},
    [7] = { r = 6, g = 23, b = 74, a = 255},
    [8] = { r = 51, g = 29, b = 62, a = 255},
}

function CardColorConfig.GetFormationCardLevelAndPowerColor(quality)
    return CardColorConfig.GetColor(quality, FormationCardLevelAndPowerColor)
end

return CardColorConfig
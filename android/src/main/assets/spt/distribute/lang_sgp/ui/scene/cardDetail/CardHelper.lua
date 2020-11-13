local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local CardHelper = {}

-- 以中上第一个顺时针表示顺序
CardHelper.NormalPlayerOrder =
{
    "shoot",
    "dribble",
    "steal",
    "intercept",
    "pass"
}

CardHelper.GoalKeeperOrder =
{
    "goalkeeping",  -- 门线技术
    "composure",    -- 心理素质
    "commanding",   -- 防线指挥
    "anticipation", -- 球路判断
    "launching"     -- 发起进攻
}

CardHelper.NormalPlayerOrderShort =
{
    ["shoot"] = "shootShort",
    ["intercept"] = "interceptShort",
    ["steal"] = "stealShort",
    ["dribble"] = "dribbleShort",
    ["pass"] = "passShort"
}

CardHelper.GoalKeeperOrderShort =
{
    ["goalkeeping"] = "goalkeepingShort",
    ["anticipation"] = "anticipationShort",
    ["commanding"] = "commandingShort",
    ["composure"] = "composureShort",
    ["launching"] = "launchingShort"
}

CardHelper.QualitySign =
{
    ["1"] = "quality_sign_1",       -- D品质
    ["2"] = "quality_sign_2",       -- C品质
    ["3"] = "quality_sign_3",       -- B品质
    ["4"] = "quality_sign_4",       -- A品质
    ["5"] = "quality_sign_5",       -- S品质
    ["5_Plus"] = "quality_sign_5_plus",       -- S+品质
    ["6"] = "quality_sign_6",       -- SS品质
    ["6_Plus"] = "quality_sign_6_plus",       -- SS+品质
    ["6_Annual"] = "quality_sign_6_annual",       -- 6品质周年庆卡（spg金牌卡）
    ["6_SL"] = "quality_sign_6_SL",     --6品质SL卡
    ["7"] = "quality_sign_7",       -- SSS品质
    ["7_Legend"] = "quality_sign_7_legend",       -- 7品质传奇卡
    ["8"] = "quality_sign_8",       --8品质卡
}

-- key为策划在表中的配置常用字段，value为程序中常用字段
CardHelper.ConfigQuality =
{
    ["1"] = "1",       -- D品质
    ["2"] = "2",       -- C品质
    ["3"] = "3",       -- B品质
    ["4"] = "4",       -- A品质
    ["5"] = "5",       -- S品质
    ["5+"] = "5_Plus",       -- S+品质
    ["6"] = "6",       -- SS品质
    ["6+"] = "6_Plus",       -- SS+品质
    ["6_A"] = "6_Annual",       -- 6品质周年庆卡
    ["6_SL"] = "6_SL",    --6SL 卡
    ["7"] = "7",       -- SSS品质
    ["7_L"] = "7_Legend",       -- 7品质传奇卡
    ["8"] = "8",     --典藏卡
}

CardHelper.HWSpecialFixedCardQuality = "5_Plus" -- 华为渠道特殊品质卡牌

function CardHelper.GetQualitySign(quality)
    local quality = CardHelper.QualitySign[tostring(quality)]
    if quality then
        return lang.transstr(quality)
    else
        return ""
    end
end

function CardHelper.GetQualityIndex(quality, isPlus)
    return quality .. (isPlus and "_Plus" or "")
end

function CardHelper.GetQualityFixed(quality, qualitySpecial)
    qualitySpecial = qualitySpecial or 0
    if qualitySpecial == 0 then
        return tostring(quality)
    elseif qualitySpecial == 1 then
        return quality .. "_Plus"
    elseif qualitySpecial == 2 then
        return quality .. "_Annual"
    elseif qualitySpecial == 3 then
        return quality .. "_Legend"
    elseif qualitySpecial == 4 then
        return quality .. "_SL"
    end
end

function CardHelper.GetQualityFixedByConfig(configQuality)
    if CardHelper.ConfigQuality[configQuality] ~= nil then
        return CardHelper.ConfigQuality[configQuality]
    else
        return nil
    end
end

function CardHelper.GetCardFixQualityNum(quality, qualitySpecial)
    if quality == nil then
        quality = 0
    end
    if qualitySpecial == nil then
        qualitySpecial = 0
    end
    return tonumber(quality) + tonumber(qualitySpecial) / 10
end

function CardHelper.GetPolygonColorAndMaxValue(value)
    local color
    local maxValue
    if value <= 100 then
        maxValue = 100
        color = Color(0, 1, 0, 1)
    elseif value <= 300 then
        maxValue = 300
        color = Color(0, 0, 1, 1)
    elseif value <= 900 then
        maxValue = 900
        color = Color(1, 0, 1, 1)
    elseif value <= 2700 then
        maxValue = 2700
        color = Color(1, 0.5, 0, 1)
    elseif value <= 8100 then
        maxValue = 8100
        color = Color(1, 0, 0, 1)
    elseif value <= 24300 then
        maxValue = 24300
        color = Color(1, 0.8, 0.1, 1)
    else
        maxValue = value
        color = Color(0, 1, 0, 1)
    end

    color = Color(0.58, 0.86, 0.25, 1)

    return color, maxValue
end

-- card表里的quality 和 qualitySpecial 转换为其他配表中的品质标识
CardHelper.Quality2Config =
{
    ["1"] = {
        ["0"] = "1",       -- D品质
    },
    ["2"] = {
        ["0"] = "2",       -- C品质
    },
    ["3"] = {
        ["0"] = "3",       -- B品质
    },
    ["4"] = {
        ["0"] = "4",       -- A品质
    },
    ["5"] = {
        ["0"] = "5",       -- S品质
        ["1"] = "5+",      -- S+品质
    },
    ["6"] = {
        ["0"] = "6",       -- SS品质
        ["1"] = "6+",      -- SS+品质
        ["2"] = "6_A",     -- SS+品质周年庆卡
        ["4"] = "6_SL",    -- SL品质卡
    },
    ["7"] = {
        ["0"] = "7",       -- SSS品质周年庆卡
        ["3"] = "7_L",     -- SSS品质传奇卡
    },
    ["8"] = {
        ["0"] = "8",       --典藏卡
    },
}

-- 根据card表里的quality 和 qualitySpecial 把品质转换为其他配表里的缩写
function CardHelper.GetQualityConfigFixed(quality, qualitySpecial)
    quality = quality or 1
    qualitySpecial = qualitySpecial or 0
    quality = tostring(quality)
    qualitySpecial = tostring(qualitySpecial)
    return CardHelper.Quality2Config[quality][qualitySpecial]
end

function CardHelper.GetQualityNameConfigFixed(quality, qualitySpecial)
    local quality = CardHelper.Quality2Config[tostring(quality)][tostring(qualitySpecial)]
    return lang.transstr(CardHelper.QualitySign[CardHelper.ConfigQuality[quality]])
end

return CardHelper

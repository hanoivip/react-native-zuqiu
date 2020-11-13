local PasterMainType = require("ui.scene.paster.PasterMainType")
local CoachTaskHelper = require("ui.scene.coach.coachTask.CoachTaskHelper")
local CoachItemType = require("ui.models.coach.common.CoachItemType")

local QUALITY_COLOR_MAP = {
    [1] = "White",
    [2] = "Green",
    [3] = "Blue",
    [4] = "Purple",
    [5] = "Orange",
    [6] = "Red",
    [7] = "Gold",
}

local AssetFinder = {}

-- 获取球员头像
function AssetFinder.GetPlayerIcon(iconIndex)
    local path = "Assets/CapstonesRes/Game/UI/Common/Images/PlayerIcon/".. tostring(iconIndex) .. ".png"
    local icon = res.LoadRes(path)
    if icon == nil then
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/PlayerIcon/Default.png")
    else
        return icon
    end
end

-- 获取国籍Icon
function AssetFinder.GetNationIcon(iconIndex)
    local path = "Assets/CapstonesRes/Game/UI/Common/Images/Nationality/" .. tostring(iconIndex) .. ".png"
    local icon = res.LoadRes(path)
    if icon == nil then 
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/Nationality/China.png")
    else
        return icon
    end
end

-- 获取道具Icon
function AssetFinder.GetItemIcon(iconIndex)
    local path = "Assets/CapstonesRes/Game/UI/Common/Images/ItemIcon/" .. tostring(iconIndex) .. ".png"
    local icon = res.LoadRes(path)
    if icon == nil then
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/ItemIcon/1301.png")
    else
        return icon
    end
end

-- 获取春节活动道具Icon
function AssetFinder.GetExchangeItemIcon(iconIndex)
    local path = "Assets/CapstonesRes/Game/UI/Common/Images/ExchangeItemIcon/" .. tostring(iconIndex) .. ".png"
    local icon = res.LoadRes(path)
    if icon == nil then
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/ItemIcon/1301.png")
    else
        return icon
    end
end

-- 获取装备icon
function AssetFinder.GetEquipIcon(iconIndex)
    local path = "Assets/CapstonesRes/Game/UI/Common/Images/EquipIcon/" .. tostring(iconIndex) .. ".png"
    return res.LoadRes(path)
end

-- 获取装备道具品质框
function AssetFinder.GetItemQualityBoard(iconIndex)
    local path = "Assets/CapstonesRes/Game/UI/Common/Images/ItemQualityBoard/quality_board" .. tostring(iconIndex) .. ".png"
    local icon = res.LoadRes(path)
    if icon == nil then
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/ItemQualityBoard/quality_board1.png")
    else
        return icon
    end
end

-- 获取技能Icon
function AssetFinder.GetSkillIcon(iconIndex)
    local path = "Assets/CapstonesRes/Game/UI/Common/Images/SkillIcon/" .. tostring(iconIndex) .. ".png"
    local icon = res.LoadRes(path)
    if icon == nil then
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/SkillIcon/Skill_Default.png")
    else
        return icon
    end
end

-- 获取比赛技能Icon
function AssetFinder.GetMatchSkillIcon(iconIndex)
    local path = "Assets/CapstonesRes/Game/UI/Common/Images/MatchSkill/" .. tostring(iconIndex) .. ".png"
    return res.LoadRes(path)
end

--- 获取球队Icon
function AssetFinder.GetTeamIcon(iconId)
    local path = "Assets/CapstonesRes/Game/UI/Common/Images/TeamIcon/" .. tostring(iconId) .. ".png"
    local icon = res.LoadRes(path)
    if icon == nil then
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/TeamIcon/MisteryTeam.png")
    else
        return icon
    end
end

-- TODO:当前只有2-5品质的图片，待美术出图后去除判断
local function GetFixQuality(quality)
    local qualityLevel = quality
    if qualityLevel > 6 then
        qualityLevel = 5
    elseif qualityLevel > 4 and qualityLevel <= 6 then
        qualityLevel = 4
    elseif qualityLevel < 2 then
        qualityLevel = 2
    end
    return qualityLevel
end

--- 获取卡牌头像框
function AssetFinder.GetCardAvatarBox(qualityLevel)
    local qualityLevel = GetFixQuality(qualityLevel)
    local path = "Assets/CapstonesRes/Game/UI/Common/Images/CardQuality/AvatarBox" .. tostring(qualityLevel) .. ".png"
    return res.LoadRes(path)
end

--- 获取卡牌名称框，中国专用
function AssetFinder.GetCardNameBox(qualityLevel)
    local qualityLevel = GetFixQuality(qualityLevel)
    local path = "Assets/CapstonesRes/Game/UI/Common/Images/CardQuality/NameBox" .. tostring(qualityLevel) .. ".png"
    return res.LoadRes(path)
end

--- 获取卡牌丝带框，中国专用
function AssetFinder.GetCardRibbon(qualityLevel)
    local path = "Assets/CapstonesRes/Game/UI/Common/Images/CardQuality/CardRibbon" .. tostring(qualityLevel) .. ".png"
    return res.LoadRes(path)
end

--- 获取卡牌转生标记，中国专用
function AssetFinder.GetCardAscendSign(ascend)
    local path = "Assets/CapstonesRes/Game/UI/Common/Images/CardQuality/Ascend" .. tostring(ascend) .. ".png"
    return res.LoadRes(path)
end

--- 获取卡牌觉醒标记
function AssetFinder.GetCardTrainingSign(trainIndex)
    local path = "Assets/CapstonesRes/Game/UI/Common/Images/CardQuality/Training" .. tostring(trainIndex) .. ".png"
    return res.LoadRes(path)
end

--- 获取圆形卡牌丝带框，中国专用
function AssetFinder.GetCircleCardRibbon(qualityLevel)
    local path = "Assets/CapstonesRes/Game/UI/Common/Images/CardQuality/CardCircleRibbon" .. tostring(qualityLevel) .. ".png"
    return res.LoadRes(path)
end

--- 获取卡牌名称影子框，中国专用
function AssetFinder.GetCardNameShadowBox(qualityLevel)
    local qualityLevel = GetFixQuality(qualityLevel)
    local path = "Assets/CapstonesRes/Game/UI/Common/Images/CardQuality/NameBoxShadow" .. tostring(qualityLevel) .. ".png"
    return res.LoadRes(path)
end


--- 获取卡牌上的星星，中国专用
function AssetFinder.GetCardStar(qualityLevel)
    local qualityLevel = GetFixQuality(qualityLevel)
    local path = "Assets/CapstonesRes/Game/UI/Common/Images/CardQuality/Star" .. tostring(qualityLevel) .. ".png"
    return res.LoadRes(path)
end

--- 获取卡牌标签框，中国专用
function AssetFinder.GetCardLabelBox(qualityLevel)
    local qualityLevel = GetFixQuality(qualityLevel)
    local path = "Assets/CapstonesRes/Game/UI/Common/Images/CardQuality/LabelBox" .. tostring(qualityLevel) .. ".png"
    return res.LoadRes(path)
end

--- 获取卡牌框，中国专用
function AssetFinder.GetCardBox(qualityLevel)
    local path = "Assets/CapstonesRes/Game/UI/Common/Images/CardQuality/CardBox" .. tostring(qualityLevel) .. ".png"
    return res.LoadRes(path)
end

--- 获取圆形卡牌框，中国专用
function AssetFinder.GetCircleCardBox(qualityLevel)
    local path = "Assets/CapstonesRes/Game/UI/Common/Images/CardQuality/CardCircleBox" .. tostring(qualityLevel) .. ".png"
    return res.LoadRes(path)
end

--- 获取圆形卡牌标记，中国专用
function AssetFinder.GetCircleCardSign(qualityLevel)
    local path = "Assets/CapstonesRes/Game/UI/Common/Images/CardQuality/CardCircleSign" .. tostring(qualityLevel) .. ".png"
    return res.LoadRes(path)
end

--- 根据贴纸类型，获得相应贴纸底部sticker标记
function AssetFinder.GetPasterSignOnType(qualityLevel, pasterMainType)
    if pasterMainType == PasterMainType.Compete then    -- 争霸赛贴纸
        return AssetFinder.GetPasterSignCompete(qualityLevel)
    else
        return AssetFinder.GetPasterSign(qualityLevel)
    end
end

--- 根据贴纸类型，获得相应贴纸顶部装饰
function AssetFinder.GetPasterDecorateOnType(qualityLevel, pasterMainType)
    if pasterMainType == PasterMainType.General then    -- 无贴纸
        -- TO DO
    elseif pasterMainType == PasterMainType.Default then    -- 默认贴纸
        return AssetFinder.GetPasterDecorate(qualityLevel)
    elseif pasterMainType == PasterMainType.Week then   -- 周贴纸
        return AssetFinder.GetPasterDecorate(qualityLevel)
    elseif pasterMainType == PasterMainType.Month then  -- 月贴纸
        return AssetFinder.GetPasterDecorate(qualityLevel)
    elseif pasterMainType == PasterMainType.Honor then  -- 荣耀贴纸
        return AssetFinder.GetPasterHonorDecorate(qualityLevel)
    elseif pasterMainType == PasterMainType.Annual then -- 周年纪念贴纸
        return AssetFinder.GetPasterAnnualDecorate(qualityLevel)
    elseif pasterMainType == PasterMainType.Compete then    -- 争霸赛贴纸
        return AssetFinder.GetPasterCompeteDecorate(qualityLevel)
    end
end

--- 根据贴纸类型，获得相应圆形贴纸顶部装饰
function AssetFinder.GetCirclePasterDecorateOnType(qualityLevel, pasterMainType)
    if pasterMainType == PasterMainType.General then    -- 无贴纸
        -- TO DO
    elseif pasterMainType == PasterMainType.Default then    -- 默认贴纸
        return AssetFinder.GetCirclePasterDecorate(qualityLevel)
    elseif pasterMainType == PasterMainType.Week then   -- 周贴纸
        return AssetFinder.GetCirclePasterDecorate(qualityLevel)
    elseif pasterMainType == PasterMainType.Month then  -- 月贴纸
        return AssetFinder.GetCirclePasterDecorate(qualityLevel)
    elseif pasterMainType == PasterMainType.Honor then  -- 荣耀贴纸
        return AssetFinder.GetCirclePasterHonorDecorate(qualityLevel)
    elseif pasterMainType == PasterMainType.Annual then -- 周年纪念贴纸
        return AssetFinder.GetCirclePasterAnnualDecorate(qualityLevel)
    elseif pasterMainType == PasterMainType.Compete then    -- 争霸赛贴纸
        return AssetFinder.GetCirclePasterCompeteDecorate(qualityLevel)
    end
end

--- 根据贴纸类型，获得相应贴纸品质
function AssetFinder.GetPasterQualityOnType(qualityLevel, pasterMainType)
    if pasterMainType == PasterMainType.General then    -- 无贴纸
        -- TO DO
    elseif pasterMainType == PasterMainType.Default then    -- 默认贴纸
        return AssetFinder.GetPasterQuality(qualityLevel)
    elseif pasterMainType == PasterMainType.Week then   -- 周贴纸
        return AssetFinder.GetPasterQuality(qualityLevel)
    elseif pasterMainType == PasterMainType.Month then  -- 月贴纸
        return AssetFinder.GetPasterQuality(qualityLevel)
    elseif pasterMainType == PasterMainType.Honor then  -- 荣耀贴纸
        return AssetFinder.GetPasterHonorQuality(qualityLevel)
    elseif pasterMainType == PasterMainType.Annual then -- 周年纪念贴纸
        return AssetFinder.GetPasterAnnualQuality(qualityLevel)
    elseif pasterMainType == PasterMainType.Compete then    -- 争霸赛贴纸
        return AssetFinder.GetPasterCompeteQuality(qualityLevel)
    end
end

--- 获取贴纸小图标
function AssetFinder.GetPasterIdentity(mainType)
    local path = "Assets/CapstonesRes/Game/UI/Common/Card/Paster/Image/Paster_Identity" .. tostring(mainType) .. ".png"
    return res.LoadRes(path)
end

--- 获得相应贴纸底部sticker标记
function AssetFinder.GetPasterSign(qualityLevel)
    local path = "Assets/CapstonesRes/Game/UI/Common/Card/Paster/Common/Paster_Sign" .. tostring(qualityLevel) .. ".png"
    return res.LoadRes(path)
end

--- 获取贴纸碎片
function AssetFinder.GetPasterPiece(mainType)
    local path = "Assets/CapstonesRes/Game/UI/Common/Card/Paster/Image/Paster_Piece" .. tostring(mainType) .. ".png"
    return res.LoadRes(path)
end

--- 获取【周、月贴纸】顶部装饰
function AssetFinder.GetPasterDecorate(qualityLevel)
    local path = "Assets/CapstonesRes/Game/UI/Common/Card/Paster/Normal/Paster_Decorate" .. tostring(qualityLevel) .. ".png"
    return res.LoadRes(path)
end

--- 获取【周、月圆形贴纸】顶部装饰
function AssetFinder.GetCirclePasterDecorate(qualityLevel)
    local path = "Assets/CapstonesRes/Game/UI/Common/Card/Paster/Normal/Paster_Circle_Decorate" .. tostring(qualityLevel) .. ".png"
    return res.LoadRes(path)
end

--- 获取【周、月贴纸】品质
function AssetFinder.GetPasterQuality(qualityLevel)
    local path = "Assets/CapstonesRes/Game/UI/Common/Card/Paster/Normal/Paster_Quality" .. tostring(qualityLevel) .. ".png"
    return res.LoadRes(path)
end

--- 获取【荣耀贴纸】顶部装饰
function AssetFinder.GetPasterHonorDecorate(qualityLevel)
    local path = "Assets/CapstonesRes/Game/UI/Common/Card/Paster/Honor/Paster_Decorate_Honor" .. tostring(qualityLevel) .. ".png"
    return res.LoadRes(path)
end

--- 获取【荣耀圆形贴纸】顶部装饰
function AssetFinder.GetCirclePasterHonorDecorate(qualityLevel)
    local path = "Assets/CapstonesRes/Game/UI/Common/Card/Paster/Honor/Paster_Circle_Decorate_Honor" .. tostring(qualityLevel) .. ".png"
    return res.LoadRes(path)
end

--- 获取【荣耀贴纸】品质
function AssetFinder.GetPasterHonorQuality(qualityLevel)
    local path = "Assets/CapstonesRes/Game/UI/Common/Card/Paster/Honor/Paster_Quality_Honor" .. tostring(qualityLevel) .. ".png"
    return res.LoadRes(path)
end

--- 获取【周年纪念贴纸】顶部装饰
function AssetFinder.GetPasterAnnualDecorate(qualityLevel)
    local path = "Assets/CapstonesRes/Game/UI/Common/Card/Paster/Annual/Paster_Decorate_Annual" .. tostring(qualityLevel) .. ".png"
    return res.LoadRes(path)
end

--- 获取【周年纪念圆形贴纸】顶部装饰
function AssetFinder.GetCirclePasterAnnualDecorate(qualityLevel)
    local path = "Assets/CapstonesRes/Game/UI/Common/Card/Paster/Annual/Paster_Circle_Decorate_Annual" .. tostring(qualityLevel) .. ".png"
    return res.LoadRes(path)
end

--- 获取【周年纪念贴纸】品质
function AssetFinder.GetPasterAnnualQuality(qualityLevel)
    local path = "Assets/CapstonesRes/Game/UI/Common/Card/Paster/Annual/Paster_Quality_Annual" .. tostring(qualityLevel) .. ".png"
    return res.LoadRes(path)
end

-- 获取【争霸赛贴纸】顶部装饰
function AssetFinder.GetPasterCompeteDecorate(qualityLevel)
    local path = "Assets/CapstonesRes/Game/UI/Common/Card/Paster/Compete/Paster_Decorate_Compete" .. tostring(qualityLevel) .. ".png"
    return res.LoadRes(path)
end

--- 获取【争霸赛圆形贴纸】顶部装饰
function AssetFinder.GetCirclePasterCompeteDecorate(qualityLevel)
    return nil
end

--- 获取【争霸赛贴纸】品质
function AssetFinder.GetPasterCompeteQuality(qualityLevel)
    local path = "Assets/CapstonesRes/Game/UI/Common/Card/Paster/Compete/Paster_Quality_Compete" .. tostring(qualityLevel) .. ".png"
    return res.LoadRes(path)
end

--- 获得相应贴纸底部sticker标记，争霸赛特殊
function AssetFinder.GetPasterSignCompete(qualityLevel)
    local path = "Assets/CapstonesRes/Game/UI/Common/Card/Paster/Compete/Paster_Sign_Compete.png"
    return res.LoadRes(path)
end

-- 获取品质圆点
function AssetFinder.GetPositionQualityPoint(qualityLevel)
    assert(qualityLevel >= 1 and qualityLevel <= 7)
    local color = QUALITY_COLOR_MAP[qualityLevel]
    local path = "Assets/CapstonesRes/Game/UI/Scene/Home/Images/PositionPoint".. tostring(color) .. ".png"
    return res.LoadRes(path)
end

--- 获取主线章节Icon
function AssetFinder.GetChapterIcon(iconId)
    local path = "Assets/CapstonesRes/Game/UI/Common/Images/ChapterIcon/" .. tostring(iconId) .. ".png"
    local icon = res.LoadRes(path)
    if icon == nil then
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/ChapterIcon/Q1.png")
    else
        return icon
    end
end

function AssetFinder.GetCardPieceBox(isUniversalPiece, quality)
    local pieceBox = "Normal_Quality"
    if isUniversalPiece then
        pieceBox = "Universal_Quality"
    elseif quality == "7" then
        pieceBox = "Piece_Quality_7"
    elseif quality == "7_Legend" then
        pieceBox = "Piece_Quality_7_Legend"
    end
    local path = "Assets/CapstonesRes/Game/UI/Common/Images/CardPiece/" .. tostring(pieceBox) .. ".png"
    return res.LoadRes(path)
end

function AssetFinder.GetCardPieceBox2(pieceBox)
    local path = "Assets/CapstonesRes/Game/UI/Common/Images/CardPiece/" .. tostring(pieceBox) .. ".png"
    return res.LoadRes(path)
end

--- 获取队服Icon
function AssetFinder.GetUniformIcon(iconId)
    local path = "Assets/CapstonesRes/Game/UI/Common/Images/UniformIcon/" .. tostring(iconId) .. ".png"
    return res.LoadRes(path)
end

-- 获取商城物品推荐角标图素
function AssetFinder.GetRecommendCornerIcon(color)
    local path = format("Assets/CapstonesRes/Game/UI/Common/Images/CommonTrueColor/RecommendCorner%s.png", color)
    return res.LoadRes(path)
end

-- 获取商城物品Icon
-- isFallbackItem 表示fallback到item道具的图片索引，但同时item的图片是bytes模式，而商城图片使用了pack图集模式，需要设置image的材质才能正确显示
function AssetFinder.GetStoreItemIcon(itemId)
    local path = "Assets/CapstonesRes/Game/UI/Scene/Store/Images/" .. tostring(itemId) .. ".png"
    local storeIcon = res.LoadRes(path)
    local isFallbackItem = false
    if storeIcon == nil or storeIcon == clr.null then
        storeIcon = AssetFinder.GetItemIcon(itemId)
        isFallbackItem = true
    end
    return storeIcon, isFallbackItem
end

--- 获取主线圆形奖杯Icon
function AssetFinder.GetQuestCupCircleIcon(cupIndex)
    local path = "Assets/CapstonesRes/Game/UI/Scene/Quest/Images/Cup/Cup" .. tostring(cupIndex) .. ".png"
    local icon = res.LoadRes(path)
    if icon == nil then
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Quest/Images/Cup/Cup1.png")
    else
        return icon
    end
end

--- 获取主线奖杯角落Icon
function AssetFinder.GetQuestCupCornerIcon(cupIndex)
    local path = "Assets/CapstonesRes/Game/UI/Scene/Quest/Images/Cup/Cup" .. tostring(cupIndex) .. "Corner.png"
    local icon = res.LoadRes(path)
    if icon == nil then
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Quest/Images/Cup/Cup1Corner.png")
    else
        return icon
    end
end

--- 获取主线奖杯横幅Icon
function AssetFinder.GetQuestCupBannerIcon(cupIndex)
    local path = "Assets/CapstonesRes/Game/UI/Scene/Quest/Images/Cup/Cup" .. tostring(cupIndex) .. "Banner.png"
    local icon = res.LoadRes(path)
    if icon == nil then
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Quest/Images/Cup/Cup1Banner.png")
    else
        return icon
    end
end

function AssetFinder.GetHonorPalaceTrophyIcon(TrophyIndex)
    local path = "Assets/CapstonesRes/Game/UI/Common/Images/Trophy/" .. tostring(TrophyIndex) ..".png"
    local icon = res.LoadRes(path)
    if icon == nil then
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/Trophy/000.png")
    else
        return icon
    end
end

function AssetFinder.GetStoreGachaIconByLayout(layout)
    local path = "Assets/CapstonesRes/Game/UI/Scene/Store/Images/"
    -- 普通招募
    if tonumber(layout) == 0 then
        path = path .. "A1.png"
    -- 精选招募
    elseif tonumber(layout) == 1 then
        path = path .. "A2.png"
    -- 友情招募
    elseif tonumber(layout) == 3 then
        path = path .. "C1.png"
    -- 限时招募或者新手招募
    else
        path = path .. "B2.png"
    end

    local icon = res.LoadRes(path)
    return icon
end

function AssetFinder.GetArenaStoreMoneyIcon(medalIndex)
    local path = "Assets/CapstonesRes/Game/UI/Scene/Arena/Images/Main/Medal" .. tostring(medalIndex) .. ".png"
    return res.LoadRes(path)
end

function AssetFinder.GetGuildIcon(gIndex)
    local path = "Assets/CapstonesRes/Game/UI/Common/Images/GuildIcon/" .. tostring(gIndex) ..".png"
    local icon = res.LoadRes(path)
    if icon == nil then
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/GuildIcon/GuildLogo1.png")
    else
        return icon
    end
end

function AssetFinder.GetVideoReplayMatchTypeIcon(MatchType)
    local path = "Assets/CapstonesRes/Game/UI/Scene/VideoReplay/Images/MatchTypeIcon/" .. tostring(MatchType) .. "Icon.png"
    return res.LoadRes(path)
end

-- 参数二为是否应用小图标
function AssetFinder.GetSponsorIcon(index, isLittle)
    if not isLittle then
        local path = "Assets/CapstonesRes/Game/UI/Scene/Transfort/Images/Logo/Logo_" .. tostring(index) .. ".png"
        return res.LoadRes(path)
    else
        local path = "Assets/CapstonesRes/Game/UI/Scene/Transfort/Images/Logo/Logo_" .. tostring(index) .. "_Little.png"
        return res.LoadRes(path)
    end
    dump("path has error")
end

-- 争霸赛标识
function AssetFinder.GetCompeteSign(signName)
    local path = "Assets/CapstonesRes/Game/UI/Scene/Compete/Common/Images/" .. signName .. ".png"
    return res.LoadRes(path)
end

-- 获得英雄殿堂的图标
function AssetFinder.GetHeroHallIcon(id)
    local path = "Assets/CapstonesRes/Game/UI/Common/Images/HeroHallIcon/" .. tostring(id) .. ".png"
    return res.LoadRes(path)
end

-- 教练系统根据等级获得教练头像
function AssetFinder.GetCoachIcon(level)
    local path = "Assets/CapstonesRes/Game/UI/Scene/Coach/Common/Images/CoachLevel/CoachLV_Icon_" .. tostring(level) .. ".png"
    return res.LoadRes(path)
end

-- 教练系统根据等级获得教练等级的数字
function AssetFinder.GetCoachNum(level)
    local path = "Assets/CapstonesRes/Game/UI/Scene/Coach/Common/Images/CoachLevel/CoachLV_Num_" .. tostring(level) .. ".png"
    return res.LoadRes(path)
end

-- 教练任务系统根据等级获得任务品质
function AssetFinder.GetCoachTaskQuality(quality)
    local path = "Assets/CapstonesRes/Game/UI/Scene/Coach/CoachTask/Image/Quality_Sign_" .. tostring(quality) .. ".png"
    return res.LoadRes(path)
end

-- 教练任务系统根据等级获得任务品质的背景
function AssetFinder.GetCoachTaskQualityBG(quality)
    quality = CoachTaskHelper.BG[tonumber(quality)]
    local path = "Assets/CapstonesRes/Game/UI/Scene/Coach/CoachTask/Image/" .. tostring(quality) .. ".png"
    return res.LoadRes(path)
end

-- 教练基本信息，阵型及战术图标
function AssetFinder.GetCoachBaseInfoItemIcon(picName)
    local path = "Assets/CapstonesRes/Game/UI/Scene/Coach/BaseInfo/Images/" .. tostring(picName) .. ".png"
    return res.LoadRes(path)
end

-- 教练基本信息，教练阵型/战术升级书的【小】图标
function AssetFinder.GetCtiIcon(picIndex)
    local path = "Assets/CapstonesRes/Game/UI/Scene/Coach/Common/Images/CoachTacticsItem/S_" .. tostring(picIndex) .. ".png"
    return res.LoadRes(path)
end

-- 教练基本信息，教练阵型/战术升级书的【大】图标
function AssetFinder.GetCoachTacticItemIcon(picIndex)
    local path = "Assets/CapstonesRes/Game/UI/Scene/Coach/Common/Images/CoachTacticsItem/" .. tostring(picIndex) .. ".png"
    return res.LoadRes(path)
end

-- 助理教练情报书图标
function AssetFinder.GetAssistCoachInfoItemIcon(picIndex)
    local path = "Assets/CapstonesRes/Game/UI/Common/Images/ItemIcon/" .. tostring(picIndex) .. ".png"
    return res.LoadRes(path)
end

-- 教练特性信息，教练特性(道具)图标
function AssetFinder.GetCoachFeatureItemIcon(picIndex)
    local path = "Assets/CapstonesRes/Game/UI/Common/Images/Coach/FeatureItem/" .. tostring(picIndex) .. ".png"
    return res.LoadRes(path)
end

-- 教练特性信息，教练特性(书)图标
function AssetFinder.GetCoachFeatureSkillIcon(picIndex)
    local path = "Assets/CapstonesRes/Game/UI/Common/Images/Coach/FeatureSkills/" .. tostring(picIndex) .. ".png"
    return res.LoadRes(path)
end

-- 教练特性信息，教练特性背景图标
function AssetFinder.GetCoachFeatureDecorateIcon(picBackGround)
    local path = "Assets/CapstonesRes/Game/UI/Common/Images/Coach/FeatureSkills/" .. tostring(picBackGround) .. ".png"
    return res.LoadRes(path)
end

-- 教练特性信息，教练特性入门品质
function AssetFinder.GetCoachFeatureSign(qualityPicIndex)
    local path = "Assets/CapstonesRes/Game/UI/Scene/CardDetail/Images/Feature/Images/FeatureSign_" .. tostring(qualityPicIndex) .. ".png"
    return res.LoadRes(path)
end

-- 教练执教天赋系统，获得技能图标
function AssetFinder.GetCoachTalentSkill(picIndex)
    local path = "Assets/CapstonesRes/Game/UI/Scene/Coach/Common/Images/CoachTalentSkill/" .. tostring(picIndex) .. ".png"
    return res.LoadRes(path)
end

-- 教练执教天赋系统，获得天赋树图标
function AssetFinder.GetCoachTalentRound(picIndex)
    local path = "Assets/CapstonesRes/Game/UI/Scene/Coach/Talent/Images/" .. tostring(picIndex) .. ".png"
    return res.LoadRes(path)
end

-- 教练入口的品质背景
function AssetFinder.GetCoachEntryQuality(quality)
    local path = "Assets/CapstonesRes/Game/UI/Scene/Coach/Common/Images/Entry/Entry_Quality_" .. tostring(quality) .. ".png"
    return res.LoadRes(path)
end

-- 获得争霸赛竞猜档位奖励图标
function AssetFinder.GetCompeteGuessReward(stage)
    local path = "Assets/CapstonesRes/Game/UI/Scene/Compete/Guess/Images/" .. tostring(stage) .. ".png"
    return res.LoadRes(path)
end

-- 获得教练物品的图标
function AssetFinder.GetCoachItemIcon(picIndex, coachItemType)
    if coachItemType == CoachItemType.PlayerTalentSkillBook then -- 特性书
        return AssetFinder.GetCoachFeatureSkillIcon(picIndex)
    elseif coachItemType == CoachItemType.PlayerTalentFunctionalityItem then -- 特性道具
        return AssetFinder.GetCoachFeatureItemIcon(picIndex)
    elseif coachItemType == CoachItemType.CoachTacticsItem then -- 阵型/战术道具
        return AssetFinder.GetCoachTacticItemIcon(picIndex)
    elseif coachItemType == CoachItemType.AssistCoachInfo then -- 助教情报
        return AssetFinder.GetAssistCoachInfoItemIcon(picIndex)
    else
        dump("wrong coach item config type!")
        return nil
    end
end

-- 教练系统获得助理教练头像
function AssetFinder.GetAssistantCoachIcon(idx)
    if idx == nil then idx = "Default" end
    local path = "Assets/CapstonesRes/Game/UI/Scene/Coach/Common/Bytes/AssistantCoach/ACoachPortrait_" .. tostring(idx) .. ".png"
    local icon = res.LoadRes(path)
    if icon == nil then
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Coach/Common/Bytes/AssistantCoach/ACoachPortrait_Default.png")
    else
        return icon
    end
end

function AssetFinder.GetAssistantCoachIconBg(idx)
    if idx == nil then idx = "Default" end
    local path = "Assets/CapstonesRes/Game/UI/Scene/Coach/Common/Bytes/AssistantCoach/ACoachPortraitBg_" .. tostring(idx) .. ".png"
    local icon = res.LoadRes(path)
    if icon == nil then
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Coach/Common/Bytes/AssistantCoach/ACoachPortraitBg_Default.png")
    else
        return icon
    end
end

-- 获得助理教练情报图标
-- @param superInformation: 情报特殊类别标识字段
-- @param quality: 情报品质
function AssetFinder.GetAssistantCoachInformationIcon(superInformation, quality)
    if quality == nil then quality = "1" end
    local path = "Assets/CapstonesRes/Game/UI/Scene/Coach/Common/Images/AssistantCoachInformation/ACIIcon_" .. tostring(superInformation) .. "_" .. tostring(quality) .. ".png"
    local icon = res.LoadRes(path)
    if icon == nil then
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Coach/Common/Images/AssistantCoachInformation/ACIIcon_0_1.png")
    else
        return icon
    end
end

-- 获得绿茵征途星象图标
function AssetFinder.GetGreenswardStarIcon(iconIndex)
    local path = "Assets/CapstonesRes/Game/UI/Scene/Greensward/DialogImage/Star/Greensward_Star_Icon_" .. tostring(iconIndex) .. ".png"
    local icon = res.LoadRes(path)
    if icon == nil then
        icon = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Greensward/DialogImage/Star/Greensward_Star_Icon_1.png")
    end
    return icon
end

-- 获得绿茵征途徽章图标
function AssetFinder.GetGreenswardAvatarLogo(picIndex)
    local path = "Assets/CapstonesRes/Game/UI/Scene/Greensward/EventIcon/" .. tostring(picIndex) .. ".png"
    local icon = res.LoadRes(path)
    if icon == nil then
        icon = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Greensward/EventIcon/Logo1.png")
    end
    return icon
end

-- 获得绿茵征途边框图标
function AssetFinder.GetGreenswardAvatarFrame(picIndex)
    local path = "Assets/CapstonesRes/Game/UI/Scene/Greensward/EventIcon/" .. tostring(picIndex) .. ".png"
    local icon = res.LoadRes(path)
    if icon == nil then
        icon = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Greensward/EventIcon/Head_Frame1.png")
    end
    return icon
end

-- 获取弹球活动兑换道具Icon
function AssetFinder.GetMarblesExchangeItemIcon(iconIndex)
    local path = "Assets/CapstonesRes/Game/UI/Common/Images/MarblesExchangeItem/" .. tostring(iconIndex) .. ".png"
    local icon = res.LoadRes(path)
    if icon == nil then
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/ItemIcon/1301.png")
    else
        return icon
    end
end

--- 获取梦幻卡资源
function AssetFinder.GetFancyCardIcon(icon, isBig)
    local path = "Assets/CapstonesRes/Game/UI/Common/Fancy/Images/" .. tostring(icon) .. ".png"
    return res.LoadRes(path)
end

return AssetFinder

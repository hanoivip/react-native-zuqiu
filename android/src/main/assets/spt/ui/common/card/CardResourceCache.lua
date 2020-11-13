local AssetFinder = require("ui.common.AssetFinder")
local CardConfig = require("ui.common.card.CardConfig")
local PasterMainType = require("ui.scene.paster.PasterMainType")
local CardResourceCache = class()

function CardResourceCache:ctor()
    self.qualityCache = {}
    self.ribbonCache = {}
    self.avatarCache = {}
    self.ascendCache = {}
    self.nationCache = {}
    self.circleQualityCache = {}
    self.pasterDecorateCache = {}
    self.pasterHonorDecorateCache = {}
    self.pasterAnnualDecorateCache = {}
    self.pasterCompeteDecorateCache = {}
    self.pasterSignCache = {}
    self.circleQualityRibbonCache = {}
    self.circleCardSignCache = {}
    self.circleCardTrainingSignCache = {}
    self.circlePasterDecorateCache = {}
end

function CardResourceCache:GetAvatarCache()
    return self.avatarCache
end
function CardResourceCache:GetRibbonCache()
    return self.ribbonCache
end
function CardResourceCache:GetQualityCache()
    return self.qualityCache
end
function CardResourceCache:GetAscendCache()
    return self.ascendCache
end
function CardResourceCache:GetNationCache()
    return self.nationCache
end
function CardResourceCache:GetCircleQualityCache()
    return self.circleQualityCache
end
function CardResourceCache:GetCircleQualityRibbonCache()
    return self.circleQualityRibbonCache
end
function CardResourceCache:GetCircleCardSignCache()
    return self.circleCardSignCache
end
function CardResourceCache:GetCircleCardTrainingSignCache()
    return self.circleCardTrainingSignCache
end
function CardResourceCache:GetPasterDecorateCache()
    return self.pasterDecorateCache
end
function CardResourceCache:GetPasterHonorDecorateCache()
    return self.pasterHonorDecorateCache
end
function CardResourceCache:GetPasterAnnualDecorateCache()
    return self.pasterAnnualDecorateCache
end
function CardResourceCache:GetPasterCompeteDecorateCache()
    return self.pasterCompeteDecorateCache
end
function CardResourceCache:GetPasterSignCache()
    return self.pasterSignCache
end
function CardResourceCache:GetCirclePasterDecorateCache()
    return self.circlePasterDecorateCache
end

function CardResourceCache:Clear()
    self:ctor()
end

-- 球员头像
function CardResourceCache:GetAvatarRes(avatar)
    if not self.avatarCache[avatar] then
        self.avatarCache[avatar] = AssetFinder.GetPlayerIcon(avatar)
    end
    return self.avatarCache[avatar]
end

-- 球员品质
function CardResourceCache:GetQualityRes(quality)
    if not self.qualityCache[quality] then
        self.qualityCache[quality] = AssetFinder.GetCardBox(quality)
    end
    return self.qualityCache[quality]
end

-- 球员丝带
function CardResourceCache:GetRibbonRes(quality)
    if not self.ribbonCache[quality] then
        self.ribbonCache[quality] = AssetFinder.GetCardRibbon(quality)
    end
    return self.ribbonCache[quality]
end

-- 球员转生标记
function CardResourceCache:GetAscendRes(ascend)
    if not self.ascendCache[ascend] then
        self.ascendCache[ascend] = AssetFinder.GetCardAscendSign(ascend)
    end
    return self.ascendCache[ascend]
end

-- 国籍
function CardResourceCache:GetNationRes(nation)
    if not self.nationCache[nation] then
        self.nationCache[nation] = AssetFinder.GetNationIcon(nation)
    end
    return self.nationCache[nation]
end

-- 圆形品质
function CardResourceCache:GetCircleQualityRes(quality)
    if not self.circleQualityCache[quality] then
        self.circleQualityCache[quality] = AssetFinder.GetCircleCardBox(quality)
    end
    return self.circleQualityCache[quality]
end

-- 圆形丝带
function CardResourceCache:GetCircleQualityRibbonRes(quality)
    if not self.circleQualityRibbonCache[quality] then
        self.circleQualityRibbonCache[quality] = AssetFinder.GetCircleCardRibbon(quality)
    end
    return self.circleQualityRibbonCache[quality]
end

-- 圆形品质标记
function CardResourceCache:GetCircleCardSignRes(quality)
    if not self.circleCardSignCache[quality] then
        self.circleCardSignCache[quality] = AssetFinder.GetCircleCardSign(quality)
    end
    return self.circleCardSignCache[quality]
end

-- 圆形特训标记
function CardResourceCache:GetCircleCardTrainingSignRes(train)
    if not self.circleCardTrainingSignCache[train] then
        self.circleCardTrainingSignCache[train] = AssetFinder.GetCardTrainingSign(train)
    end
    return self.circleCardTrainingSignCache[train]
end

-- 贴纸底部标记
function CardResourceCache:GetPasterSignRes(quality, pasterMainType)
    -- 争霸赛特殊，key不能重复
    if pasterMainType == PasterMainType.Compete then
        quality = quality .. "_" .. pasterMainType
    end
    if not self.pasterSignCache[quality] then
        self.pasterSignCache[quality] = AssetFinder.GetPasterSignOnType(quality, pasterMainType)
    end
    return self.pasterSignCache[quality]
end

-- 荣耀贴纸顶部装饰，弃用
function CardResourceCache:GetPasterHonorDecorateRes(quality)
    if not self.pasterHonorDecorateCache[quality] then
        self.pasterHonorDecorateCache[quality] = AssetFinder.GetPasterHonorDecorate(quality)
    end
    return self.pasterHonorDecorateCache[quality]
end

-- 根据贴纸类型获得贴纸资源
function CardResourceCache:GetPasterDecorateOnTypeRes(quality, pasterMainType)
    if not self.pasterDecorateCache[pasterMainType] then
        self.pasterDecorateCache[pasterMainType] = {}
    end
    if not self.pasterDecorateCache[pasterMainType][quality] then 
        self.pasterDecorateCache[pasterMainType][quality] = AssetFinder.GetPasterDecorateOnType(quality, pasterMainType)
    end
    return self.pasterDecorateCache[pasterMainType][quality]
end

-- 圆形贴纸资源
function CardResourceCache:GetCirclePasterDecorateOnTypeRes(quality, pasterMainType)
    if not self.circlePasterDecorateCache[pasterMainType] then
        self.circlePasterDecorateCache[pasterMainType] = {}
    end
    if not self.circlePasterDecorateCache[pasterMainType][quality] then 
        self.circlePasterDecorateCache[pasterMainType][quality] = AssetFinder.GetCirclePasterDecorateOnType(quality, pasterMainType)
    end
    return self.circlePasterDecorateCache[pasterMainType][quality]
end

return CardResourceCache

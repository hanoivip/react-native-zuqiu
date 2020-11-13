local AssetFinder = require("ui.common.AssetFinder")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local CardColorConfig = require("ui.common.card.CardColorConfig")
local PasterMainType = require("ui.scene.paster.PasterMainType")
local PasterView = class(unity.base)

function PasterView:ctor()
    self.backside = self.___ex.backside
    self.playerIcon = self.___ex.playerIcon
    self.ribbon = self.___ex.ribbon
    self.playerName = self.___ex.playerName
    self.nameGradient = self.___ex.nameGradient
    self.cname = self.___ex.cname
    self.decorate = self.___ex.decorate
    self.sign = self.___ex.sign
end

function PasterView:SetCardResourceCache(resourceCache)
    self.resourceCache = resourceCache
end

function PasterView:InitView(pasterModel)
    self.pasterModel = pasterModel
    local quality = pasterModel:GetPasterQuality()
    local qualitySpecial = pasterModel:GetPasterQualitySpecial()
    local fixQuality = CardHelper.GetQualityFixed(quality, qualitySpecial)
    local mainType = pasterModel:GetPasterType()
    self:SetQualityCard(fixQuality, mainType)
    -- 头像
    self:SetCardAvatar(pasterModel:GetAvatar())

    self.playerName.text = tostring(pasterModel:GetNameByEnglish())
    -- 颜色
    local nameGradientColor = CardColorConfig.GetNameColor(quality)
    self.nameGradient:ResetPointColors(table.nums(nameGradientColor))
    for i, v in ipairs(nameGradientColor) do
        self.nameGradient:AddPointColors(v.percent, v.color)
    end
    -- 贴纸
    self:PasterShowOnType(fixQuality, mainType)
end

-- 设置贴纸品质框
function PasterView:SetQualityCard(quality, pasterMainType)
    local isCompete = pasterMainType == PasterMainType.Compete
    self.backside.enabled = not isCompete
    -- 争霸赛贴纸暂时没有8品质的中间标识
    local ribbonQuality = quality
    if isCompete and tonumber(quality) >=8 then
        ribbonQuality = "7_Legend"
    end
    if self.resourceCache then
        self.backside.overrideSprite = self.resourceCache:GetQualityRes(quality)
        self.ribbon.overrideSprite = self.resourceCache:GetRibbonRes(ribbonQuality or quality)
        self.sign.overrideSprite = self.resourceCache:GetPasterSignRes(quality, pasterMainType)
    else
        local backsideRes = AssetFinder.GetCardBox(quality)
        self.backside.overrideSprite = backsideRes
        local ribbonRes = AssetFinder.GetCardRibbon(ribbonQuality or quality)
        self.ribbon.overrideSprite = ribbonRes
        local signRes = AssetFinder.GetPasterSignOnType(quality, pasterMainType)
        self.sign.overrideSprite = signRes
    end
end

function PasterView:PasterShow(quality, pasterMainType)
    if self.resourceCache then
        self.decorate.overrideSprite = self.resourceCache:GetPasterDecorateRes(quality, pasterMainType)
    else
        local decorateRes = AssetFinder.GetPasterDecorate(quality)
        self.decorate.overrideSprite = decorateRes
    end
end

function PasterView:PasterHonorShow(quality)
    if self.resourceCache then
        self.decorate.overrideSprite = self.resourceCache:GetPasterHonorDecorateRes(quality)
    else
        local decorateRes = AssetFinder.GetPasterHonorDecorate(quality)
        self.decorate.overrideSprite = decorateRes
    end
end

-- 根据贴纸类型显示贴纸
function PasterView:PasterShowOnType(quality, pasterMainType)
    if self.resourceCache then
        self.decorate.overrideSprite = self.resourceCache:GetPasterDecorateOnTypeRes(quality, pasterMainType)
    else
        local decorateRes = AssetFinder.GetPasterDecorateOnType(quality, pasterMainType)
        self.decorate.overrideSprite = decorateRes
    end
end

-- 设置贴纸头像
function PasterView:SetCardAvatar(avatar)
    if self.resourceCache then
        self.playerIcon.overrideSprite = self.resourceCache:GetAvatarRes(avatar)
    else
        local avatarRes = AssetFinder.GetPlayerIcon(avatar)
        self.playerIcon.overrideSprite = avatarRes
    end
end

return PasterView

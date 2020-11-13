local GameObjectHelper = require("ui.common.GameObjectHelper")
local CardConfig = require("ui.common.card.CardConfig")
local AssetFinder = require("ui.common.AssetFinder")
local PasterMainType = require("ui.scene.paster.PasterMainType")
local CardColorConfig = require("ui.common.card.CardColorConfig")
local CircleCardItem = class(unity.base)

function CircleCardItem:ctor()
    self.backside = self.___ex.backside
    self.quality = self.___ex.quality
    self.playerIcon = self.___ex.playerIcon
    self.ribbon = self.___ex.ribbon
    self.playerName = self.___ex.playerName
    self.playerLevel = self.___ex.playerLevel
    self.levelColorComponent = self.___ex.levelColorComponent
    self.nameColorComponent = self.___ex.nameColorComponent
    self.shadow = self.___ex.shadow
    self.signIcon = self.___ex.signIcon
    self.ascendArea = self.___ex.ascendArea
    self.ascend = self.___ex.ascend
    self.decorate = self.___ex.decorate
    self.trainingArea = self.___ex.trainingArea
    self.training = self.___ex.training
end

function CircleCardItem:start()
end

function CircleCardItem:IsShowShadow(isShow)
    GameObjectHelper.FastSetActive(self.shadow, isShow)
end

function CircleCardItem:InitView(cardModel)
    local quality = cardModel:GetCardQuality()
    -- 品质
    local fixQuality = cardModel:GetCardFixQuality()
    self:SetQualityCard(fixQuality)
    -- 头像
    self:SetCardAvatar(cardModel:GetAvatar())

    self.playerName.text = tostring(cardModel:GetName())
    local nameGradientColor = CardColorConfig.GetNameGradientColorWithCircleCard(fixQuality)
    self.nameColorComponent:ResetPointColors(table.nums(nameGradientColor))
    for i, v in ipairs(nameGradientColor) do
        self.nameColorComponent:AddPointColors(v.percent, v.color)
    end

    -- 颜色
    local levelGradientColor = CardColorConfig.GetLevelGradientColor(fixQuality)
    self.levelColorComponent:ResetPointColors(table.nums(levelGradientColor))
    for i, v in ipairs(levelGradientColor) do
        self.levelColorComponent:AddPointColors(v.percent, v.color)
    end
    self.playerLevel.text = tostring(cardModel:GetLevel())
    self:SetCardTraining(cardModel:GetTrainingLevel())

    self:SetCardAscend(cardModel:GetAscend())

    -- 贴纸
    local hasPaster = cardModel:HasPaster()
    GameObjectHelper.FastSetActive(self.decorate.gameObject, hasPaster)
    if hasPaster then 
        local mainType = cardModel:GetPasterMainType()
        self:PasterShowOnType(fixQuality, mainType)
    end
end

-- 设置卡牌品质框
function CircleCardItem:SetQualityCard(quality)
    local backsideRes = AssetFinder.GetCircleCardBox(quality)
    self.backside.overrideSprite = backsideRes
    local ribbonRes = AssetFinder.GetCircleCardRibbon(quality)
    self.ribbon.overrideSprite = ribbonRes
    if self.signIcon then 
        local cardSignRes = AssetFinder.GetCircleCardSign(quality)
        self.signIcon.overrideSprite = cardSignRes
    end
end

function CircleCardItem:PasterShow(quality)
    local decorateRes = AssetFinder.GetCirclePasterDecorate(quality)
    self.decorate.overrideSprite = decorateRes
end

function CircleCardItem:PasterHonorShow(quality)
    local decorateRes = AssetFinder.GetCirclePasterHonorDecorate(quality)
    self.decorate.overrideSprite = decorateRes
end

function CircleCardItem:PasterShowOnType(quality, pasterMainType)
     -- 争霸贴纸不显示效果
    if pasterMainType == PasterMainType.Compete then
        GameObjectHelper.FastSetActive(self.decorate.gameObject, false)
        return
    end

    local decorateRes = AssetFinder.GetCirclePasterDecorateOnType(quality, pasterMainType)
    self.decorate.overrideSprite = decorateRes
end

function CircleCardItem:SetCardAscend(ascend)
    local isShowAscend = tobool(ascend > 0)
    if isShowAscend then 
        local ascendRes = AssetFinder.GetCardAscendSign(ascend)
        self.ascend.overrideSprite = ascendRes
        self.ascend:SetNativeSize()
    end
    GameObjectHelper.FastSetActive(self.ascendArea, isShowAscend)
end

function CircleCardItem:SetCardTraining(train)
    local isShowTraining = tobool(train)
    if isShowTraining then 
        local trainingRes = AssetFinder.GetCardTrainingSign(train)
        self.training.overrideSprite = trainingRes
        self.training:SetNativeSize()
    end
    GameObjectHelper.FastSetActive(self.trainingArea, isShowTraining)
    GameObjectHelper.FastSetActive(self.playerLevel.gameObject, not isShowTraining)
end


function CircleCardItem:SetCardAvatar(avatar)
    local avatarRes = AssetFinder.GetPlayerIcon(avatar)
    self.playerIcon.overrideSprite = avatarRes
end

return CircleCardItem

local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CardConfig = require("ui.common.card.CardConfig")
local AssetFinder = require("ui.common.AssetFinder")
local CardColorConfig = require("ui.common.card.CardColorConfig")
local CardOpenFromType = require("ui.controllers.cardDetail.CardOpenFromType")

local ChemicalCard = class(unity.base)

function ChemicalCard:ctor()
    self.backside = self.___ex.backside
    self.quality = self.___ex.quality
    self.playerIcon = self.___ex.playerIcon
    self.ribbon = self.___ex.ribbon
    self.playerName = self.___ex.playerName
    self.nameColorComponent = self.___ex.nameColorComponent
    self.shadow = self.___ex.shadow
    self.mask = self.___ex.mask
    self.add = self.___ex.add
    self.addValue = self.___ex.addValue
    self.signIcon = self.___ex.signIcon
end

function ChemicalCard:InitView(cardModel, isExist)
    local quality = cardModel:GetCardQuality()
    -- 品质
    local fixQuality = cardModel:GetCardFixQuality()
    self:SetQualityCard(fixQuality)
    -- 头像
    self:SetCardAvatar(cardModel:GetAvatar())
    self.cardModel = cardModel
    self.playerName.text = tostring(cardModel:GetName())
    local nameGradientColor = CardColorConfig.GetNameGradientColorWithCircleCard(quality)
    self.nameColorComponent:ResetPointColors(table.nums(nameGradientColor))
    for i, v in ipairs(nameGradientColor) do
        self.nameColorComponent:AddPointColors(v.percent, v.color)
    end
    GameObjectHelper.FastSetActive(self.shadow, true)
    GameObjectHelper.FastSetActive(self.add, false)
    local isShowIconColor = isExist and 1 or 0
    self.playerIcon.color = Color(isShowIconColor, 1, 1)
    GameObjectHelper.FastSetActive(self.mask, not isExist)
end

-- 设置卡牌品质框
function ChemicalCard:SetQualityCard(quality)
    local backsideRes = AssetFinder.GetCircleCardBox(quality)
    self.backside.overrideSprite = backsideRes
    local ribbonRes = AssetFinder.GetCircleCardRibbon(quality)
    self.ribbon.overrideSprite = ribbonRes
    local cardSignRes = AssetFinder.GetCircleCardSign(quality)
    self.signIcon.overrideSprite = cardSignRes  
end

function ChemicalCard:SetCardAvatar(avatar)
    local avatarRes = AssetFinder.GetPlayerIcon(avatar)
    self.playerIcon.overrideSprite = avatarRes
end

function ChemicalCard:ExtraAttribute(addValue)
    local isShowPlus = tobool(addValue > 0)
    if self.cardModel:GetOpenFromPageType() == CardOpenFromType.COLLABORATE then
        isShowPlus = false
    end
    GameObjectHelper.FastSetActive(self.shadow, not isShowPlus)
    GameObjectHelper.FastSetActive(self.add, isShowPlus)
    self.addValue.text = "+" .. addValue
end

return ChemicalCard

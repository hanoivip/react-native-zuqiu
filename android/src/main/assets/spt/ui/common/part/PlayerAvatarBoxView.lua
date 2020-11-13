local CardColorConfig = require("ui.common.card.CardColorConfig")
local AssetFinder = require("ui.common.AssetFinder")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local CommonConstants = require("ui.common.CommonConstants")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CardBuilder = require("ui.common.card.CardBuilder")
local Vector3 = clr.UnityEngine.Vector3

local PlayerAvatarBoxView = class(unity.base)

function PlayerAvatarBoxView:ctor()
    -- 图标
    self.icon = self.___ex.icon
    -- 品级框
    self.qualityBorder = self.___ex.qualityBorder
    -- 名称框
    self.nameBox = self.___ex.nameBox
    -- 名称
    self.nameTxt = self.___ex.name
    self.playerLevel = self.___ex.playerLevel
    self.levelColorComponent = self.___ex.levelColorComponent
    self.nameColorComponent = self.___ex.nameColorComponent
    self.addNum = self.___ex.addNum
    self.addNumText = self.___ex.addNumText
    self.signIcon = self.___ex.signIcon
    self.content = self.___ex.content
    self.cardBg = self.___ex.cardBg
    -- 遮罩按钮
    self.maskBtn = self.___ex.maskBtn
    self.playerCardStaticModel = nil
    -- 是否显示名称
    self.isShowName = nil
    -- 是否要显示详情板
    self.isShowDetail = false
    self.isShowBg = false
end

function PlayerAvatarBoxView:InitView(cardId, num, isShowDetail, isHideLvl, cardLv, isShowBg)
    self.num = num
    self.playerCardStaticModel = StaticCardModel.new(cardId)
    self.isShowDetail = isShowDetail or false
    self.isHideLvl = isHideLvl or false
    self.isShowBg = isShowBg or false
    self:BuildPage(cardLv)
end

function PlayerAvatarBoxView:start()
    if self.isShowDetail then
        self.maskBtn:regOnButtonClick(function()
            self:ShowCardDetail()
        end)
    end
end

function PlayerAvatarBoxView:BuildPage(cardLv)
    self.icon.overrideSprite = AssetFinder.GetPlayerIcon(self.playerCardStaticModel:GetAvatar())
    local cardQuality = self.playerCardStaticModel:GetCardQuality()
    local fixQuality = self.playerCardStaticModel:GetCardFixQuality()
    self.qualityBorder.overrideSprite = AssetFinder.GetCircleCardBox(fixQuality)
    self.nameTxt.text = self.playerCardStaticModel:GetName()
    self.nameBox.overrideSprite = AssetFinder.GetCircleCardRibbon(fixQuality)
    local cardSignRes = AssetFinder.GetCircleCardSign(fixQuality)
    self.signIcon.overrideSprite = cardSignRes

    -- 颜色
    local nameGradientColor = CardColorConfig.GetNameGradientColorWithCircleCard(cardQuality)
    self.nameColorComponent:ResetPointColors(table.nums(nameGradientColor))
    for i, v in ipairs(nameGradientColor) do
        self.nameColorComponent:AddPointColors(v.percent, v.color)
    end

    local levelGradientColor = CardColorConfig.GetLevelGradientColor(cardQuality)
    self.levelColorComponent:ResetPointColors(table.nums(levelGradientColor))
    for i, v in ipairs(levelGradientColor) do
        self.levelColorComponent:AddPointColors(v.percent, v.color)
    end
    if cardLv then
        self.playerLevel.text = tostring(cardLv)
    else
        self.playerLevel.text = tostring(self.playerCardStaticModel:GetLevel())
    end
    if self.cardBg then
        if self.isShowBg then
            GameObjectHelper.FastSetActive(self.cardBg.gameObject, true)
            self.content.transform.localScale = Vector3(1.2, 1.2, 1.2)
        else
            GameObjectHelper.FastSetActive(self.cardBg.gameObject, false)
            self.content.transform.localScale = Vector3(1, 1, 1)
        end
    end
    GameObjectHelper.FastSetActive(self.playerLevel.gameObject, not self.isHideLvl)

    if tonumber(self.num) > 0 then
        self.addNumText.text = "x" .. self.num
        GameObjectHelper.FastSetActive(self.addNum.gameObject, true)

        local addNumRect = self.addNum.rect
        if addNumRect.height > 25 then
            self.addNumText.fontSize = math.floor(18 *(addNumRect.height / 25))
        end
    else
        GameObjectHelper.FastSetActive(self.addNum.gameObject, false)
    end
end

function PlayerAvatarBoxView:ShowCardDetail()
    local cid = self.playerCardStaticModel:GetCid()
    local currentModel = CardBuilder.GetBaseCardModel(cid)
    res.PushScene("ui.controllers.cardDetail.CardDetailMainCtrl", {cid}, 1, currentModel)
end

return PlayerAvatarBoxView

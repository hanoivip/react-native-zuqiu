local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local CommonConstants = require("ui.models.activity.mascotPresent.CommonConstants")
local MascotPresentGiftBoxItemView = class(unity.base)

function MascotPresentGiftBoxItemView:ctor()
    self.btnCollect = self.___ex.btnCollect
    self.contentTrans = self.___ex.contentTrans
    self.boxObj = self.___ex.boxObj
    self.iconObj = self.___ex.iconObj
    self.boxText = self.___ex.boxText
    self.giftOwnerText = self.___ex.giftOwnerText
    self.receivedIcon = self.___ex.receivedIcon
    self.nameText = self.___ex.nameText
    self.blueBg = self.___ex.blueBg
    self.collectedPropNameText = self.___ex.collectedPropNameText
    self.nameBg = self.___ex.nameBg
end

function MascotPresentGiftBoxItemView:start()
    self.btnCollect:regOnButtonClick(function()
        if type(self.clickCollect) == "function" then
            self.clickCollect()
        end
    end)
end

function MascotPresentGiftBoxItemView:InitView(itemModel, showType)
    self.itemModel = itemModel
    self.showType = showType
    self:ShowIconType()
    self:InitTextToEmpty()

    self:RefreshOneGiftBox()
end

function MascotPresentGiftBoxItemView:InitTextToEmpty()
    self.boxText.text = ""
    self.giftOwnerText.text = ""
    self.nameText.text = ""
    self.collectedPropNameText.text = ""
end

function MascotPresentGiftBoxItemView:ShowIconType()
    GameObjectHelper.FastSetActive(self.blueBg, self.showType == CommonConstants.COLLECTABLE)
    local isGiftCollected = self.itemModel:IsGiftAlreadyCollected()
    local isShowGiftBox = self.showType == CommonConstants.COLLECTABLE and not isGiftCollected
    GameObjectHelper.FastSetActive(self.boxObj, isShowGiftBox)
    GameObjectHelper.FastSetActive(self.iconObj, not isShowGiftBox)
end

function MascotPresentGiftBoxItemView:RefreshOneGiftBox()
    local isGiftCollected = self.itemModel:IsGiftAlreadyCollected()
    local rewardContents = self.itemModel:GetRewardContents()
    GameObjectHelper.FastSetActive(self.nameBg, true)
    if self.showType == CommonConstants.COLLECTABLE then
        if not isGiftCollected then
            self.clickCollect = function() self:OnClickCollect() end
            self.boxText.text = lang.transstr("mascotPresent_desc19", tostring(self.itemModel:GetBoxIndex()))
        else
            GameObjectHelper.FastSetActive(self.nameBg, false)
            self:InitOneRewardItem(rewardContents)
            self.giftOwnerText.text = self.itemModel:GetGiftOwnerName()
        end
    elseif self.showType == CommonConstants.PREVIEW then
        self:InitOneRewardItem(rewardContents)
    elseif self.showType == CommonConstants.COLLECTABLE_PREVIEW then
        self:InitOneRewardItem(rewardContents)
        GameObjectHelper.FastSetActive(self.receivedIcon, isGiftCollected)
    end
end

function MascotPresentGiftBoxItemView:InitOneRewardItem(contents)
    res.ClearChildren(self.contentTrans)
    local rewardParams = {
            parentObj = self.contentTrans,
            rewardData = contents,
            isShowName = false,
            isReceive = false,
            isShowBaseReward = true,
            isShowCardReward = true,
            isShowDetail = true,
        }
    RewardDataCtrl.new(rewardParams)

    local propName = self.itemModel:GetPropName()
    if self.showType == CommonConstants.COLLECTABLE then
        self.collectedPropNameText.text = propName
    else
        self.nameText.text = propName
    end
end

function MascotPresentGiftBoxItemView:OnClickCollect()
    if type(self.clickCollectProgressReward) == "function" then
        self.clickCollectProgressReward()
    end
end

return MascotPresentGiftBoxItemView
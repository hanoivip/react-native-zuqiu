local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ItemType = require("ui.scene.itemList.ItemType")

local FanShopRecycleItemView = class(unity.base)

function FanShopRecycleItemView:ctor()
    self.selectPieceBg = self.___ex.selectPieceBg
    self.selectItemBg = self.___ex.selectItemBg
    self.itemArea = self.___ex.itemArea
    self.pieceArea = self.___ex.pieceArea
    self.cardArea = self.___ex.cardArea
    self.clickBtn = self.___ex.clickBtn
    self.sellPrice = self.___ex.sellPrice
    self.itemName = self.___ex.itemName
    self.lock = self.___ex.lock

    self.clickBtn:regOnButtonClick(function()
        self:OnClickItem()
    end)
end

function FanShopRecycleItemView:InitView(itemData, index)
    self.index = index
    self.itemData = itemData
    res.ClearChildren(self.itemArea.transform)
    res.ClearChildren(self.pieceArea.transform)
    res.ClearChildren(self.cardArea.transform)
    if itemData.itemType == ItemType.CardPiece or itemData.itemType == ItemType.PasterPiece then
        self:InitArea(self.pieceArea, itemData.contents)
    elseif itemData.itemType == ItemType.Card then
        self:InitCardArea(self.cardArea)
    else
        self:InitArea(self.itemArea, itemData.contents)
    end
    self.sellPrice.text = "x" .. itemData.fanCoinRecycle
    self.itemName.text = itemData.name
    clr.coroutine(function()
        unity.waitForNextEndOfFrame()
        self.sellPrice.gameObject:SetActive(false)
        unity.waitForNextEndOfFrame()
        self.sellPrice.gameObject:SetActive(true)
    end)

    self:IsSelect(false)
end

function FanShopRecycleItemView:IsSelect(flag)
    if self.itemData.itemType == ItemType.CardPiece or self.itemData.itemType == ItemType.PasterPiece then
        GameObjectHelper.FastSetActive(self.selectPieceBg, flag)
        GameObjectHelper.FastSetActive(self.selectItemBg, false)
    else
        GameObjectHelper.FastSetActive(self.selectPieceBg, false)
        GameObjectHelper.FastSetActive(self.selectItemBg, flag)
    end
end

function FanShopRecycleItemView:InitArea(areaObj, contents)
    local rewardParams = {
        parentObj = areaObj,
        rewardData = contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
        hideCount = true
    }
    RewardDataCtrl.new(rewardParams)
end

function FanShopRecycleItemView:InitCardArea(areaObj)
    local cardObject, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
    cardObject.transform:SetParent(areaObj.transform, false)
    spt:InitView(self.itemData.itemModel)
    spt:IsShowName(false)

    local shouldLock = not self.itemData.canRecycle
    GameObjectHelper.FastSetActive(self.lock, shouldLock)
end

function FanShopRecycleItemView:OnClickItem()
    if self.clickCardPiece then
        self.clickCardPiece(self.index, self.itemData)
    end
end

function FanShopRecycleItemView:onDestroy()
end

return FanShopRecycleItemView

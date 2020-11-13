local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local RewardNameHelper = require("ui.scene.itemList.RewardNameHelper")

local DreamItemStoreItemView = class()

function DreamItemStoreItemView:ctor()
    self.titleTxt = self.___ex.titleTxt
    self.clickBuy = self.___ex.clickBuy
    self.limitNum = self.___ex.limitNum
    self.price = self.___ex.price
    self.priceType = self.___ex.priceType
    self.itemParentRect = self.___ex.itemParentRect
end

function DreamItemStoreItemView:InitView(storeItem)
    self.titleTxt.text = RewardNameHelper.GetSingleContentName(storeItem.contents)

    if storeItem.limitAmount > 0 then
        self.limitNum.text = lang.transstr("newYearExchange_property_buyLimit", (storeItem.num or 0), storeItem.limitAmount)
    else
        GameObjectHelper.FastSetActive(self.limitNum.gameObject, false)
    end
    local cardRes = AssetFinder.GetItemIcon(storeItem.picIndex)
    self.price.text = "x " .. tostring(storeItem.price)
    local priceTypePath
    if storeItem.currencytype == "dc" then
        priceTypePath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamStore/Image/dc.png"
    else
        priceTypePath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamStore/Image/dp.png"
    end
    local priceRes = res.LoadRes(priceTypePath)
    if priceRes then
        self.priceType.overrideSprite = priceRes
    else
        GameObjectHelper.FastSetActive(self.priceType.gameObject, false)
    end

    res.ClearChildren(self.itemParentRect)
    local rewardParams = {
        parentObj = self.itemParentRect,
        rewardData = storeItem.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)
end

function DreamItemStoreItemView:OnBuyBtnClick()
    
end

return DreamItemStoreItemView

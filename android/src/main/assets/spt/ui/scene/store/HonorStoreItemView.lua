local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CurrencyImagePath = require("ui.scene.itemList.CurrencyImagePath")
local HonorStoreItemView = class(unity.base)

function HonorStoreItemView:ctor()
    self.itemArea = self.___ex.itemArea
    self.mName = self.___ex.mName
    self.honorMoney = self.___ex.honorMoney
    self.buyBtn = self.___ex.buyBtn
    self.diamond = self.___ex.diamond
    self.buyInfo = self.___ex.buyInfo
    self.symbol = self.___ex.symbol
    self.diamondImg = self.___ex.diamondImg
    self.mGroup = self.___ex.mGroup
end

function HonorStoreItemView:start()
    self.buyBtn:regOnButtonClick(function()
        if type(self.clickBuy) == "function" then
            self.clickBuy(self.honorModel)
        end
    end)
    EventSystem.AddEvent("HonorStoreExchange", self, self.HonorStoreExchange)
end

function HonorStoreItemView:onDestroy()
    EventSystem.RemoveEvent("HonorStoreExchange", self, self.HonorStoreExchange)
end

function HonorStoreItemView:HonorStoreExchange(selecthonorId)
    if tostring(selecthonorId) == self.honorModel:GethonorId() then 
        GameObjectHelper.FastSetActive(self.symbol, true)
    end
end

function HonorStoreItemView:InitView(honorData, index)
    self.index = index
    self.honorData = honorData
    res.ClearChildren(self.itemArea.transform)
    local rewardParams = {
        parentObj = self.itemArea,
        rewardData = honorData.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)

    self.buyInfo.text = not (honorData.limitType == 0) and lang.trans("honorStore_buy_limit", honorData.limitAmount - honorData.buyCount, honorData.limitAmount) or ""
    self.mName.text = honorData.itemName
    self.honorMoney.text = "x" .. string.formatIntWithTenThousands(honorData.honour) .. "  "
    self.diamond.text = "x" .. string.formatIntWithTenThousands(honorData.price)
    self.diamondImg.overrideSprite = res.LoadRes(CurrencyImagePath[honorData.currencyType])
    clr.coroutine(function()
        unity.waitForNextEndOfFrame()
        self.mGroup:SetActive(false)
        clr.coroutine(function()
            unity.waitForNextEndOfFrame()
            self.mGroup:SetActive(true)
        end)
    end)
end

return HonorStoreItemView

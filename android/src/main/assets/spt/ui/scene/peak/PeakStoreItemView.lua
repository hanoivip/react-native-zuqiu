local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local LimitType = require("ui.scene.itemList.LimitType")
local DialogManager = require("ui.control.manager.DialogManager")
local ItemPlateType = require("ui.scene.itemList.ItemPlateType")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")

local PeakStoreItemView = class(unity.base)

function PeakStoreItemView:ctor()
    self.itemArea = self.___ex.itemArea
    self.purchaseBtn = self.___ex.purchaseBtn
    self.priceTxt = self.___ex.priceTxt
    self.timeTxt = self.___ex.timeTxt
    self.nameTxt = self.___ex.nameTxt
end

function PeakStoreItemView:InitView(data, peakStoreModel)
    local rewardParams = {
        parentObj = self.itemArea,
        rewardData = data.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)

    self.nameTxt.text = data.name
    self.timeTxt.text = lang.trans("giftbox_limit", data.maxTime - data.buyCount, data.maxTime)
    self.priceTxt.text = "x" .. tostring(data.price)
    self.purchaseBtn:regOnButtonClick(function ()
        self:OnPurchaseClick(data, peakStoreModel)
    end)
end

function PeakStoreItemView:OnPurchaseClick(data, peakStoreModel)
    if data.buyCount == data.maxTime then
        DialogManager.ShowToast(lang.trans("peak_bought_time_none"))
        return
    end

    local itemType = nil
    local id = nil
    for k, v in pairs(data.contents) do
        itemType = k
        if type(v) == "number" then
            id = v
        else
            id = v[1].id
        end
    end
    -- 在这里弹出购买弹板
    local args = {
        currencyType = require("ui.models.itemList.CurrencyType").PeakDiamond,
        price = data.price or 0,
        plateType = ItemPlateType.OrdinaryItemOne,
        boughtTime = data.buyCount,
        itemId = id,
        limitAmount = data.maxTime,
        limitType = LimitType.ForeverLimit,
        itemType = itemType,
        contents = data.contents
    }

    local function purchaseCallback(num)
        self:coroutine(function()
            local respone = req.peakExchangeNormalItem(data.ID, num)
            if api.success(respone) then
                local responseData = respone.val
                -- 更新花费，更新获奖数据
                if responseData.cost and responseData.cost.type == "pp" then
                    PlayerInfoModel.new():SetPeakDiamond(responseData.cost.curr_num)
                end
                if responseData.contents then
                    CongratulationsPageCtrl.new(responseData.contents)
                end
                peakStoreModel:SetBoughtTimeWithId(data.ID)
            end
        end)
    end

    res.PushDialog("ui.controllers.itemList.ItemPurchaseCtrl", args, function (num)
        purchaseCallback(num)
    end)
end

return PeakStoreItemView
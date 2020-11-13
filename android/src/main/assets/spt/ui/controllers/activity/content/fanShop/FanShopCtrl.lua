local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local ActivityListModel = require("ui.models.activity.ActivityListModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local ActivityRes = require("ui.scene.activity.ActivityRes")
local DialogManager = require("ui.control.manager.DialogManager")
local ItemPlateType = require("ui.scene.itemList.ItemPlateType")

local FanShopCtrl = class(ActivityContentBaseCtrl)

function FanShopCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent("CapsUnityLuaBehav")
    self.view.resetCousume = function (func) self:ResetCousume(func) end
    self.view.onClickBuy = function(itemData, num, buyCallBack) self:OnFanShopBuy(itemData, num, buyCallBack) end
    self.view.onClickRecycle = function() self:OnClickRecycle() end
    self.view:InitView(self.activityModel)
end

function FanShopCtrl:OnRefresh()
end

function FanShopCtrl:OnFanShopBuy(itemData, num, buyCallBack)
    if itemData.limitType ~= 0 and itemData.buyCount >= itemData.limitAmount then
        DialogManager.ShowToast(lang.trans("peak_bought_time_none"))
        return
    end
    local activityModel = self.activityModel
    local function callback(num)
        if itemData.fanCoinPrice * num > activityModel:GetCoinCount() then
            DialogManager.ShowToast(lang.trans("fanShop_nil_fanCoin"))
            return
        end
        clr.coroutine(function()
            local response = req.fanShopBuy(itemData.goodsId, num)
            if api.success(response) then
                local data = response.val
                if data and data.gift then
                    CongratulationsPageCtrl.new(data.gift)
                end
                local tempData = activityModel:RefreshItemData(data, itemData)
                if tempData then buyCallBack(tempData) end
            end
        end)
    end

    local id = nil
    local itemType = nil
    for k, v in pairs(itemData.contents) do
        itemType = k
        id = v[1].id
    end
    local GiftBoxOneType = 1
    local maxNum = math.floor(activityModel:GetCoinCount() / itemData.fanCoinPrice)
    maxNum = math.clamp(maxNum, 1, itemData.limitAmount - itemData.buyCount)
    itemData.plate = ItemPlateType.OrdinaryItemMultiWithMax
    local args = {
        boughtTime = 0,
        limitAmount = maxNum,
        itemId = id,
        currencyType = "fan",
        price = itemData.fanCoinPrice,
        limitType = 2,
        plateType = tonumber(itemData.plate or GiftBoxOneType),
        itemType = itemType,
        hideLimitText = true,
        tips = lang.trans("fanshop_lack_time_coin")
    }
    dump(args, "argsargsargs")
    res.PushDialog("ui.controllers.itemList.ItemPurchaseCtrl", args,function (num) callback(num) end)
end

function FanShopCtrl:OnClickRecycle()
    res.PushDialog("ui.controllers.activity.content.fanShop.FanShopRecycleCtrl", self.activityModel:GetPeriod())
end

function FanShopCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function FanShopCtrl:OnExitScene()
    self.view:OnExitScene()
end

return FanShopCtrl


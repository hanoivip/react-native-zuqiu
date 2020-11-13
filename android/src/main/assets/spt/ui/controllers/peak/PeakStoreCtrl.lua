local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local MatchLoader = require("coregame.MatchLoader")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local PeakStoreModel = require("ui.models.peak.PeakStoreModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local DialogManager = require("ui.control.manager.DialogManager")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local ItemPlateType = require("ui.scene.itemList.ItemPlateType")
local LimitType = require("ui.scene.itemList.LimitType")
local PeakShopRefreshDialogCtrl = require("ui.controllers.peak.PeakShopRefreshDialogCtrl")
local CurrencyType = require("ui.models.itemList.CurrencyType")
local BaseCtrl = require("ui.controllers.BaseCtrl")

local PeakStoreCtrl = class(BaseCtrl)

PeakStoreCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Peak/PeakStore.prefab"

PeakStoreCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function PeakStoreCtrl:AheadRequest()
    local response = req.peakShop()
    if api.success(response) then
        local data = response.val
        self.peakStoreModel = PeakStoreModel.new()
        self.peakStoreModel:InitWithProtocol(data)
    end
end

function PeakStoreCtrl:Init()
    self.view.dPurchaseBtnClick = function () self:DPurchaseBtnClick() end
    self.view.pdPurchaseBtnClick = function () self:PdPurchaseBtnClick() end
    self.view.refreshBtnClick = function () self:RefreshBtnClick() end
    self.view.refreshItem = function () self:RefreshItem() end
    self.view:InitView(self.peakStoreModel)
end

function PeakStoreCtrl:Refresh()
    PeakStoreCtrl.super.Refresh(self)
end

function PeakStoreCtrl:DPurchaseBtnClick()
    local itemId = self.peakStoreModel:GetGiftBoxId()
    local price = self.peakStoreModel:GetDiamondPriceByTime()
    local boughtTime = self.peakStoreModel:GetHaveBoughtGiftBoxTime()
    local maxTime = self.peakStoreModel:GetDiamondMaxTime()

    if maxTime - boughtTime == 0 then
        DialogManager.ShowToast(lang.trans("can_buy_is_full"))
        return
    end

    -- 在这里弹出购买弹板
    local args = {
        currencyType = CurrencyType.Diamond,
        price = price or 0,
        plateType = ItemPlateType.OrdinaryItemOne,
        boughtTime = boughtTime,
        itemId = itemId,
        limitAmount = maxTime,
        limitType = LimitType.ForeverLimit,
        itemType = "item"
    }

    local function purchaseCallback(num)
        clr.coroutine(function()
            local response = req.peakExchangeMysteryBox(CurrencyType.Diamond, num)
            if api.success(response) then
                local data = response.val
                CongratulationsPageCtrl.new(data.contents)
                PlayerInfoModel.new():SetDiamond(data.cost.curr_num)
                EventSystem.SendEvent("Refresh_Peak_Store_Main_Page")
            end
        end)
    end

    res.PushDialog("ui.controllers.itemList.ItemPurchaseCtrl", args, function (num)
        purchaseCallback(num)
    end)
end

function PeakStoreCtrl:PdPurchaseBtnClick()
    local itemId = self.peakStoreModel:GetGiftBoxId()
    local price = self.peakStoreModel:GetPDiamondPrice()
    local boughtTime = self.peakStoreModel:GetPeakHaveBoughtGiftBoxTime()
    local maxTime = self.peakStoreModel:GetPPurchaseMaxTime()
    
    if not maxTime or maxTime < 0.5 then
        DialogManager.ShowToast(lang.trans("peak_max_bought_time_none"))
        return
    end

    if maxTime - boughtTime == 0 then
        DialogManager.ShowToast(lang.trans("peak_not_recv_gift"))
        return
    end

    local args = {
        currencyType = CurrencyType.PeakDiamond,
        price = price or 0,
        plateType = ItemPlateType.OrdinaryItemMultiWithMax,
        boughtTime = boughtTime,
        itemId = itemId,
        limitAmount = maxTime,
        limitType = LimitType.ForeverLimit,
        itemType = "item"
    }

    self.view:coroutine(function()
        local response = req.peakExchangeMysteryBox(CurrencyType.PeakDiamond, maxTime - boughtTime)
        if api.success(response) then
            local data = response.val
            CongratulationsPageCtrl.new(data.contents)
            EventSystem.SendEvent("Refresh_Peak_Store_Main_Page")
        end
    end)
end

function PeakStoreCtrl:RefreshItem()
    self.view:ClearItemContent()
    local dataList = self.peakStoreModel:GetDataList()
    for k, v in pairs(dataList) do
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Peak/PeakStoreItem.prefab")
        spt:InitView(v, self.peakStoreModel)
        self.view:AddItemView(obj)
    end
end

function PeakStoreCtrl:RefreshMainPage()
    clr.coroutine(function ()
        local response = req.peakShop()
        if api.success(response) then
            local data = response.val
            self.peakStoreModel:InitWithProtocol(data)
            self.view:InitView(self.peakStoreModel)
        end
    end)
end

function PeakStoreCtrl:OnEnterScene()
    self.view:OnEnterScene()
    EventSystem.AddEvent("Refresh_Peak_Store", self, self.RefreshItem)
    EventSystem.AddEvent("Refresh_Peak_Store_Main_Page", self, self.RefreshMainPage)
end

function PeakStoreCtrl:OnExitScene()
    EventSystem.RemoveEvent("Refresh_Peak_Store", self, self.RefreshItem)
    EventSystem.RemoveEvent("Refresh_Peak_Store_Main_Page", self, self.RefreshMainPage)
end

function PeakStoreCtrl:RefreshBtnClick()
    local price = self.peakStoreModel:GetRefreshPrice()
    if tonumber(price) == -1 then
        DialogManager.ShowToast(lang.trans("peak_refresh_no_time"))
        return
    end

    local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Peak/PeakShopRefreshDialog.prefab", "camera", true, true)
    local peakShopRefreshDialogCtrl = PeakShopRefreshDialogCtrl.new(dialogcomp.contentcomp)
    peakShopRefreshDialogCtrl:InitView(self.peakStoreModel)
end

return PeakStoreCtrl
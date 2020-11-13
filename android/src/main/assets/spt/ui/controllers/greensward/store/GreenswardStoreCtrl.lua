local BaseCtrl = require("ui.controllers.BaseCtrl")
local GreenswardItemActionMainCtrl = require("ui.controllers.greensward.item.itemAction.GreenswardItemActionMainCtrl")
local CurrencyNameMap = require("ui.models.itemList.CurrencyNameMap")
local DialogManager = require("ui.control.manager.DialogManager")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local CurrencyType = require("ui.models.itemList.CurrencyType")
local GreenswardStoreModel = require("ui.models.greensward.store.GreenswardStoreModel")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")

local GreenswardStoreCtrl = class(BaseCtrl, "GreenswardStoreCtrl")

GreenswardStoreCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/Store/GreenswardStore.prefab"

GreenswardStoreCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function GreenswardStoreCtrl:AheadRequest(greenswardBuildModel)
    if self.view then
        self.view:ShowDisplayArea(false)
    end

    local response = req.greenswardAdventureOpenItemStore()
    if api.success(response) then
        local data = response.val
        if not self.model then
            self.model = GreenswardStoreModel.new()
            self.model:SetGreenswardBuildModel(greenswardBuildModel)
            self.model:InitWithProtocol(data)
        end
        self.view:ShowDisplayArea(true)
    end
end

function GreenswardStoreCtrl:ctor(greenswardBuildModel)
    GreenswardStoreCtrl.super.ctor(self)
end

function GreenswardStoreCtrl:Init(greenswardBuildModel)
    GreenswardStoreCtrl.super.Init(self)

    self.view.onTabClick = function(storeType) self:OnTabClick(storeType) end
    self.view.onItemClick = function(itemModel) self:OnItemClick(itemModel) end
    self.view.onBtnBuyClick = function() self:OnBtnBuyClick() end
    self.view.onBtnItemBuyClick = function(storeItemModel) self:OnBtnItemBuyClick(storeItemModel) end
    self.view:InitView(self.model)
end

function GreenswardStoreCtrl:Refresh(greenswardBuildModel)
    GreenswardStoreCtrl.super.Refresh(self)

    self.view:RefreshView()
end

function GreenswardStoreCtrl:GetStatusData()
    return self.model:GetGreenswardBuildModel()
end

-- 页签点击事件
function GreenswardStoreCtrl:OnTabClick(storeType)
    self.model:SetCurrTab(storeType)
    self.view:SwtichToBoard(storeType)
end

-- 商品点击事件
function GreenswardStoreCtrl:OnItemClick(itemModel)
    local oldItemModel = self.model:GetSelectedItemModel() -- GreenswardStoreItemModel
    local oldIdx = oldItemModel:GetIdx()
    local newIdx = itemModel:GetIdx()
    if oldIdx == newIdx then return end

    self.model:SetSelectedIdx(newIdx)
    if oldItemModel then
        self.view:UpdateItemView(oldIdx, oldItemModel)
    end
    if itemModel then
        self.view:UpdateItemView(newIdx, itemModel)
    end
    self.view:RefreshDetailView()
end

-- 购买（边框&徽章）
function GreenswardStoreCtrl:OnBtnBuyClick()
    local storeItemModel = self.model:GetSelectedItemModel() -- GreenswardStoreItemModel
    if not storeItemModel then return end

    local commodityId = storeItemModel:GetId()
    local num = 1
    local currencyType = storeItemModel:GetCurrencyType()
    local currencyName = lang.transstr(CurrencyNameMap[currencyType])
    local price = storeItemModel:GetPrice()
    local priceStr = currencyName .. " X" .. tostring(price)
    local itemName = tostring(storeItemModel:GetName())

    local purchaseCallback = function()
        self.view:coroutine(function()
            local response = req.greenswardAdventureBuyItemStore(commodityId, num)
            if api.success(response) then
                local data = response.val
                if not table.isEmpty(data) then
                    self.model:UpdateAfterPurchased(data, storeItemModel)
                    self.view:UpdateAfterPurchased()
                    DialogManager.ShowToastByLang("buy_item_success")
                end
            end
        end)
    end

    local confirmCallback = function()
        if currencyType == CurrencyType.Diamond or currencyType == CurrencyType.BlackDiamond then
            CostDiamondHelper.CostCurrency(price, self.view, purchaseCallback, currencyType)
        else
            if self.model:IsCostEnough(currencyType, price) then
                purchaseCallback()
            else
                local msg = lang.trans("lack_item_tips", currencyName)
                DialogManager.ShowToast(msg)
            end
        end
    end

    local title = lang.transstr("tips")
    local content = lang.transstr("itemPurchase_buyTip", priceStr, itemName)
    DialogManager.ShowConfirmPop(title, content, confirmCallback)
end

-- 购买道具
function GreenswardStoreCtrl:OnBtnItemBuyClick(storeItemModel)
    if not storeItemModel then return end

    if storeItemModel:IsPurchaseLimit() then
        DialogManager.ShowToastByLang("can_buy_is_full")
        return
    end

    local currencyType = storeItemModel:GetCurrencyType()
    local currencyName = lang.transstr(CurrencyNameMap[currencyType])
    local price = storeItemModel:GetPrice()

    if (currencyType == CurrencyType.Fight or currencyType == CurrencyType.Morale) and not self.model:IsCostEnough(currencyType, price) then
        local msg = lang.trans("lack_item_tips", currencyName)
        DialogManager.ShowToast(msg)
        return
    end

    local commodityId = storeItemModel:GetId() -- 商品的id
    local args = {
        contents = storeItemModel:GetContents(),
        boughtTime = storeItemModel:GetBought(),
        limitAmount = storeItemModel:GetLimitAmount(),
        itemId = storeItemModel:GetItemId(), -- 商品contents中的物品id
        currencyType = currencyType,
        price = price,
        limitType = storeItemModel:GetLimitType(),
        plateType = tonumber(storeItemModel:GetPlate()),
        itemType = storeItemModel:GetItemType(),
    }

    local BuyCallback = function(num)
        self.view:coroutine(function()
            local response = req.greenswardAdventureBuyItemStore(commodityId, num)
            if api.success(response) then
                local data = response.val
                if not table.isEmpty(data) then
                    if not table.isEmpty(data.contents) then
                        CongratulationsPageCtrl.new(data.contents)
                        self.model:GetGreenswardBuildModel():RewardDetail(data.contents)
                    end
                    self.model:UpdateAfterPurchased(data, storeItemModel, true)
                    self.view:UpdateAfterPurchasedItem(storeItemModel)
                end
            end
        end)
    end

    res.PushDialog("ui.controllers.itemList.ItemPurchaseCtrl", args, function(num) BuyCallback(num) end)
end

return GreenswardStoreCtrl

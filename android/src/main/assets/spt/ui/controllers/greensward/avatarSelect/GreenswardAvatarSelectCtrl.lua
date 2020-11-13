local BaseCtrl = require("ui.controllers.BaseCtrl")
local CurrencyNameMap = require("ui.models.itemList.CurrencyNameMap")
local DialogManager = require("ui.control.manager.DialogManager")
local GreenswardItemType = require("ui.models.greensward.item.configType.GreenswardItemType")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local CurrencyType = require("ui.models.itemList.CurrencyType")
local GreenswardAvatarSelectModel = require("ui.models.greensward.avatarSelect.GreenswardAvatarSelectModel")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")

local GreenswardAvatarSelectCtrl = class(BaseCtrl, "GreenswardAvatarSelectCtrl")

GreenswardAvatarSelectCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/AvatarSelect/GreenswardAvatarSelect.prefab"

GreenswardAvatarSelectCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function GreenswardAvatarSelectCtrl:ctor(greenswardBuildModel, greenswardItemMapModel)
    GreenswardAvatarSelectCtrl.super.ctor(self)
end

function GreenswardAvatarSelectCtrl:Init(greenswardBuildModel, greenswardItemMapModel)
    GreenswardAvatarSelectCtrl.super.Init(self)
    self.model = GreenswardAvatarSelectModel.new()
    self.model:SetGreenswardBuildModel(greenswardBuildModel)

    self.view.onTabClick = function(storeType) self:OnTabClick(storeType) end
    self.view.onItemClick = function(itemModel) self:OnItemClick(itemModel) end
    self.view.onBtnBuyClick = function() self:OnBtnBuyClick() end
    self.view.onBtnSwitchClick = function() self:OnBtnSwitchClick() end
    self.view:InitView(self.model)
end

function GreenswardAvatarSelectCtrl:Refresh(greenswardBuildModel, greenswardItemMapModel)
    GreenswardAvatarSelectCtrl.super.Refresh(self)

    self.view:RefreshView()
end

function GreenswardAvatarSelectCtrl:GetStatusData()
    return self.model:GetGreenswardBuildModel(), self.model:GetItemMapModel()
end

-- 页签点击事件
function GreenswardAvatarSelectCtrl:OnTabClick(storeType)
    self.model:SetCurrTab(storeType)
    self.view:SwtichToBoard(storeType)
end

-- 物品点击事件
function GreenswardAvatarSelectCtrl:OnItemClick(itemModel)
    local oldItemModel = self.model:GetSelectedItemModel() -- GreenswardItemModel
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
function GreenswardAvatarSelectCtrl:OnBtnBuyClick()
    local itemModel = self.model:GetSelectedItemModel() -- GreenswardItemModel
    if not itemModel then return end

    local storeItemModel = self.model:GetAccessStoreItemModel(itemModel)
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
                    self.model:UpdateAfterPurchased(data, storeItemModel, itemModel)
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

-- 更换
function GreenswardAvatarSelectCtrl:OnBtnSwitchClick()
    local itemModel = self.model:GetSelectedItemModel() -- GreenswardItemModel
    if not itemModel then return end

    local itemId = itemModel:GetId()
    local itemType = itemModel:GetItemType()
    local setType = nil
    if itemType == GreenswardItemType.Logo then
        setType = "badge"
    elseif itemType == GreenswardItemType.Frame then
        setType = "frame"
    end

    if setType then
        self.view:coroutine(function()
            local response = req.greenswardAdventureSetImage(setType, itemId)
            if api.success(response) then
                local data = response.val
                if not table.isEmpty(data) then
                    self.model:UpdateAfterSwitch(data)
                    self.view:UpdateAfterSwitch()
                    DialogManager.ShowToastByLang("change_success")
                end
            end
        end)
    end
end

return GreenswardAvatarSelectCtrl

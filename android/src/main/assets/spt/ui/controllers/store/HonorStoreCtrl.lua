local HonorStoreModel = require("ui.models.store.HonorStoreModel")
local DialogManager = require("ui.control.manager.DialogManager")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CurrencyType = require("ui.models.itemList.CurrencyType")

local HonorStoreCtrl = class(nil, "HonorStoreCtrl")

function HonorStoreCtrl:ctor(content)
    self:Init(content)
end

function HonorStoreCtrl:Init(content)
    self.playerInfoModel = PlayerInfoModel.new()
    local object, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Store/HonorStore.prefab")
    object.transform:SetParent(content, false)
    self.view = spt
    self.view.cardClick = function(honorItemData) self:OnCardClick(honorItemData) end
    self.view.exchangeCard = function(honorItemData) self:OnExchangeCard(honorItemData) end
    self.view.helpClick = function() self:OnBtnTip() end
end

function HonorStoreCtrl:InitView()
    clr.coroutine(function()
        local respone = req.vip14Store()
        if api.success(respone) then 
            local data = respone.val
            self.honorStoreModel = HonorStoreModel.new()
            self.honorStoreModel:InitWithProtocol(data)
            self.view:InitView(self.honorStoreModel)
        end
    end)
end

function HonorStoreCtrl:OnBtnTip()
    DialogManager.ShowAlertAlignmentPop(lang.trans("instruction"), lang.trans("honorStore_help_tip"), 3)
end

function HonorStoreCtrl:EnterScene()
end

function HonorStoreCtrl:OnExitScene()
    EventSystem.RemoveEvent("PayAddDiamond", self, self.RefreshHonorDiamond)
end

function HonorStoreCtrl:OnExchangeCard(honorItemData)
    if not (honorItemData.limitType == 0) and honorItemData.buyCount - honorItemData.limitAmount >= 0 then
        DialogManager.ShowToast(lang.trans("can_buy_is_full"))
        return
    end
    local itemType = nil
    local itemId = nil
    for k, v in pairs(honorItemData.contents) do
        itemType = k
        if type(v) == "number" then
            itemId = v
        else
            itemId = v[1].id
        end
    end
    local args = {
        currencyType = CurrencyType.HonorDiamond,
        price = honorItemData.price,
        plateType = tonumber(honorItemData.plate),
        boughtTime = honorItemData.buyCount,
        itemId = itemId,
        limitAmount = honorItemData.limitAmount,
        limitType = honorItemData.limitType,
        itemType = itemType,
        contents = honorItemData.contents,
        mulCurrencyTypes = { ["other"] = honorItemData.currencyType, ["honor"] = "h" },
        mulPrices = { ["other"] = honorItemData.price, ["honor"] = honorItemData.honour }
    }
    local function purchaseCallback(num)
        local playerCostNum = tonumber(num * honorItemData.price)
        if honorItemData.currencyType == CurrencyType.Diamond then
            if playerCostNum > tonumber(self.playerInfoModel:GetDiamond()) then
                local confirmCallback = function()
                    res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl")
                end
                DialogManager.ShowConfirmPopByLang("tips", "store_gacha_tip_1", confirmCallback)
                return
            end
        elseif honorItemData.currencyType == CurrencyType.Money then
            if playerCostNum > tonumber(self.playerInfoModel:GetMoney()) then
                DialogManager.ShowToastByLang("euro_not_enough")
                return
            end
        end

        clr.coroutine(function()
            local respone = req.vip14ShopBuy(honorItemData.boxId, num)
            if api.success(respone) then
                self.honorStoreModel:SetBoughtTimeWithId(honorItemData.boxId, num)
                local responseData = respone.val
                for k,v in pairs(responseData.cost) do
                    if v.type == "d" then
                        self.playerInfoModel:SetDiamond(v.curr_num)
                    elseif v.type == "m" then
                        self.playerInfoModel:SetMoney(v.curr_num)
                    else
                        self.playerInfoModel:SetHonorDiamond(v.curr_num)
                        self.honorStoreModel:SetHonorDiamond(v.curr_num)
                    end
                end
                CongratulationsPageCtrl.new(responseData.gift)
                self.view:InitView(self.honorStoreModel)
            end
        end)
    end
    res.PushDialog("ui.controllers.itemList.ItemPurchaseCtrl", args, function (num)
        purchaseCallback(num)
    end)
end

function HonorStoreCtrl:ShowPageVisible(isShow)
    if isShow then
        EventSystem.AddEvent("PayAddDiamond", self, self.RefreshHonorDiamond)
    else
        EventSystem.RemoveEvent("PayAddDiamond", self, self.RefreshHonorDiamond)
    end
    self.view:ShowPageVisible(isShow)
end

function HonorStoreCtrl:RefreshHonorDiamond(val)
    if not val or val == 0 then return end
    val = self.playerInfoModel:GetHonorDiamond()
    self.honorStoreModel:SetHonorDiamond(val)
    self.view:RefreshHonorDiamond(tostring(val))
end

return HonorStoreCtrl

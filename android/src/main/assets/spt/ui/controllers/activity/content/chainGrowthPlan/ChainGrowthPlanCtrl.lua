local StoreModel = require("ui.models.store.StoreModel")
local ActivityRes = require("ui.scene.activity.ActivityRes")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CurrencyType = require("ui.models.itemList.CurrencyType")
local DialogManager = require("ui.control.manager.DialogManager")
local ActivityListModel = require("ui.models.activity.ActivityListModel")
local ChainGrowthPlanState = require("ui.scene.activity.ChainGrowthPlan.ChainGrowthPlanState")
local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")
local ChainGrowthPlanCtrl = class(ActivityContentBaseCtrl)

function ChainGrowthPlanCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent("CapsUnityLuaBehav")
    self.view:InitView(self.activityModel)

    self.view.resetCousume = function (func) self:ResetCousume(func) end
    self.view.buyGrowthPlan = function() self:BuyGrowthPlan() end
    self.playerInfoModel = PlayerInfoModel.new()
end

function ChainGrowthPlanCtrl:BuyGrowthPlan()
    local actState = self.activityModel:GetActState()
    local isBought = self.activityModel:IsBought()
    if not actState or isBought then return end
    local clientBuyState = self.activityModel:GetClientBuyState()
    if clientBuyState == ChainGrowthPlanState.Disable then
        DialogManager.ShowToast(lang.trans("chain_growthplan_pre"))
        return
    end

    local userVip = self.playerInfoModel:GetVipLevel()
    local userLvl = self.playerInfoModel:GetLevel()
    local vipLow = self.activityModel:GetVipLow()
    local vipHigh = self.activityModel:GetVipHigh()
    local lvLow = self.activityModel:GetLvlLow()
    local lvHigh = self.activityModel:GeLvlHigh()

    if not (lvHigh == 0 and lvLow == 0) then
        if userLvl > lvHigh or userLvl < lvLow then
            DialogManager.ShowToast(lang.transstr("chain_growthplan_lvl", lvLow, lvHigh))
            return
        end
    end

    if not (vipHigh == 0 and vipLow == 0) then
        if userVip > vipHigh or userVip < vipLow then
            DialogManager.ShowToast(lang.transstr("growthPlan_tip1"))
            return
        end
    end

    local payType = self.activityModel:GetPayType()
    local needCount = self.activityModel:GetBuyCount()
    if self:IsHasEnoughPayCurrency(payType, needCount) then
        if payType == CurrencyType.Diamond or payType == CurrencyType.BlackDiamond then
            local title = lang.trans("tips")
            local content = ""
            if payType == CurrencyType.Diamond then
                content = lang.trans("confirm_cost_diamond", needCount)
            end
            if payType == CurrencyType.BlackDiamond then
                content = lang.trans("confirm_cost_blackDiamond", needCount)
            end
            DialogManager.ShowConfirmPop(title, content, function()
                self:DoBuyingAction(payType, needCount)
            end)
        else
            self:DoBuyingAction(payType, needCount)
        end
    end
end

function ChainGrowthPlanCtrl:IsHasEnoughPayCurrency(payType, needCount)
    if not payType or payType == CurrencyType.Diamond then
        if self.playerInfoModel:GetDiamond() < needCount then
            local title = lang.trans("tips")
            local content = lang.trans("store_gacha_tip_1")
            DialogManager.ShowConfirmPop(title, content, function ()
                res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl")
            end)
            return false
        end
    elseif payType == CurrencyType.Money then
        if self.playerInfoModel:GetMoney() < needCount then
            local title = lang.trans("tips")
            local content = lang.trans("store_gacha_tip_2")
            DialogManager.ShowConfirmPop(title, content, function ()
                res.PushScene("ui.controllers.store.StoreCtrl", StoreModel.MenuTags.ITEM)
            end)
            return false
        end
    elseif payType == CurrencyType.BlackDiamond then
        if self.playerInfoModel:GetBlackDiamond() < needCount then
            local title = lang.trans("tips")
            local content = lang.trans("store_gacha_tip_3")
            DialogManager.ShowConfirmPop(title, content, function ()
                res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl", nil, nil, true)
            end)
            return false
        end
    end
    return true
end

function ChainGrowthPlanCtrl:DoBuyingAction(currencyType, needCount)
    self.view:coroutine(function()
        local response = req.activityBuyGrowthPlan(self.activityModel:GetActivityType(), self.activityModel:GetActivityID())
        if api.success(response) then
            if currencyType == CurrencyType.Diamond or not currencyType then
                self.playerInfoModel:AddDiamond(-needCount)
            elseif currencyType == CurrencyType.BlackDiamond then
                self.playerInfoModel:AddBKDiamond(-needCount)
            elseif currencyType == CurrencyType.Money then
                local m = self.playerInfoModel:GetMoney() - needCount
                self.playerInfoModel:SetMoney(m)
            end
            local data = response.val[tostring(self.activityModel:GetActivityID())]
            if data.type == self.activityModel:GetActivityType() then
                DialogManager.ShowToast(lang.transstr("buy_item_success"))
            end
        end
    end)
end

function ChainGrowthPlanCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function ChainGrowthPlanCtrl:OnExitScene()
    self.view:OnExitScene()
end

return ChainGrowthPlanCtrl


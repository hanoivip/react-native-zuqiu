local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local DialogManager = require("ui.control.manager.DialogManager")
local StoreModel = require("ui.models.store.StoreModel")
local CurrencyType = require("ui.models.itemList.CurrencyType")
local GrowthPlanCtrl = class(ActivityContentBaseCtrl)

function GrowthPlanCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent("CapsUnityLuaBehav")
    self.view:InitView(self.activityModel)
    self.view.resetCousume = function (func) self:ResetCousume(func) end
    self.view.buyGrowthPlan = function() self:BuyGrowthPlan() end
end

function GrowthPlanCtrl:BuyGrowthPlan(isActActive)
    if not self.activityModel:GetActState() or self.activityModel:IsBought() then return end

    local userVip = PlayerInfoModel.new():GetVipLevel()
    local vipLow = self.activityModel:GetVipLow()
    local vipHigh = self.activityModel:GetVipHigh()
    if not (vipHigh == 0 and vipLow == 0) then
        if userVip > vipHigh or userVip < vipLow then
            DialogManager.ShowToast(lang.transstr("growthPlan_tip1"))
            return
        end
    end

    local payType = self.activityModel:GetPayType()
    local needCount = self.activityModel:GetBuyCount()
    if self:IsHasEnoughPayCurrency(payType, needCount) then
        self:DoBuyingAction(payType, needCount)
    end
end

function GrowthPlanCtrl:IsHasEnoughPayCurrency(payType, needCount)
    if not payType or payType == CurrencyType.Diamond then
        if PlayerInfoModel.new():GetDiamond() < needCount then
            local title = lang.trans("tips")
            local content = lang.trans("store_gacha_tip_1")
            DialogManager.ShowConfirmPop(title, content, function ()
                res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl")
            end)
            return false
        end
    elseif payType == CurrencyType.Money then
        if PlayerInfoModel.new():GetMoney() < needCount then
            local title = lang.trans("tips")
            local content = lang.trans("store_gacha_tip_2")
            DialogManager.ShowConfirmPop(title, content, function ()
                res.PushScene("ui.controllers.store.StoreCtrl", StoreModel.MenuTags.ITEM)
            end)
            return false
        end
    elseif payType == CurrencyType.BlackDiamond then
        if PlayerInfoModel.new():GetBlackDiamond() < needCount then
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

function GrowthPlanCtrl:DoBuyingAction(currencyType, needCount)
    local callback = function()
        self.view:coroutine(function()
            local response = req.activityBuyGrowthPlan(self.activityModel:GetActivityType(), self.activityModel:GetActivityID())
            if api.success(response) then
                if currencyType == CurrencyType.Diamond or not currencyType then
                    PlayerInfoModel.new():AddDiamond(-needCount)
                elseif currencyType == CurrencyType.BlackDiamond then
                    PlayerInfoModel.new():AddBKDiamond(-needCount)
                elseif currencyType == CurrencyType.Money then
                    PlayerInfoModel.new():AddMoney(-needCount)
                end
                local data = response.val[tostring(self.activityModel:GetActivityID())]
                if data.type == self.activityModel:GetActivityType() then
                    DialogManager.ShowToast(lang.transstr("buy_item_success"))
                    self.activityModel:RefreshActivityData(data)

                    local selectedTabTag = self.activityModel:GetSelectedTabTag()

                    local hasRewardCollectable = self.activityModel:HasRewardCollectable(selectedTabTag)
                    self.view.tabMenuGroup.menu[selectedTabTag]:RefreshRedPoint(selectedTabTag, hasRewardCollectable)
                    self.view:OnClickTab(selectedTabTag)
                end
            end
        end)
    end
    DialogManager.ShowConfirmPop(lang.transstr("tips"), lang.transstr("oldPlayer_buy_tip"), callback)
end

function GrowthPlanCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function GrowthPlanCtrl:OnExitScene()
    self.view:OnExitScene()
end

return GrowthPlanCtrl


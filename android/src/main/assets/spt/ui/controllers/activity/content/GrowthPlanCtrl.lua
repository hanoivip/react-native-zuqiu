local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local DialogManager = require("ui.control.manager.DialogManager")
local DialogMultipleConfirmation = require("ui.control.manager.DialogMultipleConfirmation")
local ActivityListModel = require("ui.models.activity.ActivityListModel")
local ActivityRes = require("ui.scene.activity.ActivityRes")
local StoreModel = require("ui.models.store.StoreModel")
local CurrencyType = require("ui.models.itemList.CurrencyType")
local GrowthPlanCtrl = class(ActivityContentBaseCtrl)

function GrowthPlanCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)

    self.view:InitView(self.activityModel)

    self.view.resetCousume = function (func) self:ResetCousume(func) end
    self.view.buyGrowthPlan = function() self:BuyGrowthPlan() end
end

function GrowthPlanCtrl:OnRefresh()
end

function GrowthPlanCtrl:BuyGrowthPlan()
    local payType = self.activityModel:GetPayType()
    local needCount = self.activityModel:GetDiamondToBuy()
    if not payType or payType == CurrencyType.Diamond then
        if PlayerInfoModel.new():GetDiamond() < needCount then
            local title = lang.trans("tips")
            local content = lang.trans("store_gacha_tip_1")
            DialogManager.ShowConfirmPop(title, content, function ()
                res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl")
            end)
            return
        end
    elseif payType == CurrencyType.Money then
        if PlayerInfoModel.new():GetMoney() < needCount then
            local title = lang.trans("tips")
            local content = lang.trans("store_gacha_tip_2")
            DialogManager.ShowConfirmPop(title, content, function ()
                res.PushScene("ui.controllers.store.StoreCtrl", StoreModel.MenuTags.ITEM)
            end)
            return
        end
    elseif payType == CurrencyType.BlackDiamond then
        if PlayerInfoModel.new():GetBlackDiamond() < needCount then
            local title = lang.trans("tips")
            local content = lang.trans("store_gacha_tip_3")
            DialogManager.ShowConfirmPop(title, content, function ()
                res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl", nil, nil, true)
            end)
            return
        end
    end
    -- 更新数据
    local callback = function()
        clr.coroutine(function()
            local response = req.activityBuyGrowthPlan(self.activityModel:GetActivityType(), self.activityModel:GetActivityId())
            if api.success(response) then
                local currencyType = self.activityModel:GetPayType()
                if currencyType == CurrencyType.Diamond or not currencyType then
                    PlayerInfoModel.new():AddDiamond(-self.activityModel:GetDiamondToBuy())
                elseif currencyType == CurrencyType.BlackDiamond then
                    PlayerInfoModel.new():AddBKDiamond(-self.activityModel:GetDiamondToBuy())
                elseif currencyType == CurrencyType.Money then
                    PlayerInfoModel.new():AddMoney(-self.activityModel:GetDiamondToBuy())
                end
                local data = response.val[tostring(self.activityModel:GetActivityId())]
                if data.type == self.activityModel:GetActivityType() then
                    self.activityModel.singleData = data
                    self.view:InitView(self.activityModel)
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


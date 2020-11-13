local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Timer = require('ui.common.Timer')
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CurrencyType = require("ui.models.itemList.CurrencyType")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local DialogManager = require("ui.control.manager.DialogManager")
local StoreModel = require("ui.models.store.StoreModel")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")

local GrowthPlanLoginCtrl = class()

-- 每个单独活动的ctrl基类
function GrowthPlanLoginCtrl:ctor(activityType, activityId, activityRes, parentRect, activityModel)
    self.activityType = activityType
    self.activityId = activityId
    self.activityRes = activityRes
    self.parentRect = parentRect
    self.activityModel = activityModel
    local contentPrefabRes = activityRes:GetActivityContent(activityType, activityId)
    if contentPrefabRes then 
        self.contentPrefab = Object.Instantiate(contentPrefabRes)
        self.contentPrefab.transform:SetParent(parentRect, false)
    end

    if self.contentPrefab then
    	self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)
    else
        dump("error contentPrefab failure !!!")
    end

    self.view.clickBuyBtn = function() self:OnBuyBtnClick() end
    self.view.clickSeventhBtn = function(isEnable) self:OnSeventhBtnClick(isEnable) end

    self.activityModel:DataListPretreatment()
    self:InitView()
end

function GrowthPlanLoginCtrl:ShowContent(isSelect)
    if self.contentPrefab then 
        GameObjectHelper.FastSetActive(self.contentPrefab, isSelect)
    end
end

function GrowthPlanLoginCtrl:InitView()
    self.view:InitView(self.activityModel)
end

function GrowthPlanLoginCtrl:OnBuyBtnClick()
    if self.activityModel:IsActivityEnd() then 
        DialogManager.ShowToast(lang.trans("time_limit_growthPlan_desc5"))
        return
    end
    local isBuy = self.activityModel:GetIsBuy()
    if isBuy then return end

    local payType = self.activityModel:GetPayType()
    local needCount = self.activityModel:GetBuyPrice()
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
    clr.coroutine(function()
        local response = req.activityBuyGrowthPlan(self.activityModel:GetActivityType(), self.activityModel:GetActivityID())
        if api.success(response) then
            local currencyType = self.activityModel:GetPayType()
            if currencyType == CurrencyType.Diamond or not currencyType then
                PlayerInfoModel.new():AddDiamond(-self.activityModel:GetBuyPrice())
            elseif currencyType == CurrencyType.BlackDiamond then
                PlayerInfoModel.new():AddBKDiamond(-self.activityModel:GetBuyPrice())
            elseif currencyType == CurrencyType.Money then
                PlayerInfoModel.new():AddMoney(-self.activityModel:GetBuyPrice())
            end

            local data = response.val[tostring(self.activityModel:GetActivityId())]
            if data.type == self.activityModel:GetActivityType() then
                self.activityModel.singleData = data
                self.activityModel:DataListPretreatment()
                self.activityModel:InitWithProtocol()
                self:OnEnterScene()
                self.view:InitView(self.activityModel)
            else
                self.view.btnBuy.interactable = false
                self.activityModel:SetIsBuy(true)
                local firstDay = 1
                local qualified = 0
                self.activityModel:SetRewardStatusByCondition(firstDay, qualified)
                EventSystem.SendEvent("ChangeGrowthPlanLoginRewardItemButtonState", false, true, false)
            end

            DialogManager.ShowToast(lang.trans("buy_item_success"))
        end
    end)

end

function GrowthPlanLoginCtrl:OnSeventhBtnClick(isEnable)
    if not isEnable then return end
    local seventhData = self.activityModel:GetSeventhRewardData()
    if not seventhData or not next(seventhData) then return end
    if self.activityModel:IsActivityEnd() then 
        DialogManager.ShowToast(lang.trans("time_limit_growthPlan_desc5"))
        return 
    end

    local subID = seventhData.subID
    self.view:coroutine(function()
        local respone = req.activityFirstPay(self.activityModel:GetActivityType(), subID)
        if api.success(respone) then
            local data = respone.val
            if type(data) == "table" and next(data) then
                local collected = data.activity.status or 1 --设置状态为已领取
                self.activityModel:SetRewardStatusByCondition(seventhData.condition, collected)
                seventhData.status = collected
                self.view:InitSeventhBtnState()
                local popCongratulationsPage = function()
                    CongratulationsPageCtrl.new(data.contents, false)
                end
                self:Close(popCongratulationsPage)
            end
        end
    end)
end

function GrowthPlanLoginCtrl:Close(popCongratulationsPage)
    popCongratulationsPage()
end

function GrowthPlanLoginCtrl:UpdateResidualTimeText(residualSeconds)
    local residualSeconds = tonumber(residualSeconds)
    if self.countDownTimer ~= nil then self.countDownTimer:Destroy() end
    self.countDownTimer = Timer.new(residualSeconds, function(time)
        local str = self.activityModel:GetResidualTimeStr(time) 
        self.view.residualTimeText.text = str
    end)
end

function GrowthPlanLoginCtrl:OnRefresh()
end

function GrowthPlanLoginCtrl:OnEnterScene()
    local residualTime = self.activityModel:GetResidualTime()
    self:UpdateResidualTimeText(residualTime)
end

function GrowthPlanLoginCtrl:OnExitScene()
    if self.countDownTimer ~= nil then
        self.countDownTimer:Destroy()
    end
end

return GrowthPlanLoginCtrl
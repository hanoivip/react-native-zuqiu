local Timer = require('ui.common.Timer')
local CurrencyType = require("ui.models.itemList.CurrencyType")
local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")

local GrowthPlanView = class(ActivityParentView)

function GrowthPlanView:ctor()
    self.scrollView = self.___ex.scrollView
    self.activityDes = self.___ex.activityDes
    self.timeTxt = self.___ex.timeTxt
    self.buttonPay = self.___ex.buttonPay
    self.goPayBtn = self.___ex.goPayBtn
    self.goPayBtnText = self.___ex.goPayBtnText
    self.titleOutlintTxt = self.___ex.titleOutlintTxt
    self.titleTxt = self.___ex.titleTxt
    self.residualTimer = nil
end

function GrowthPlanView:start()
end

function GrowthPlanView:InitView(growthPlanModel)
    self.growthPlanModel = growthPlanModel
    self:RefreshContent()
end

function GrowthPlanView:RefreshContent()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end

    if self.titleTxt then
        self.titleTxt.text = self.growthPlanModel:GetTitle()
    end
    if self.titleOutlintTxt then
        self.titleOutlintTxt.text = self.growthPlanModel:GetTitle()
    end

    self.residualTimer = Timer.new(self.growthPlanModel:GetRemainTime(), function(time)
        self.timeTxt.text = lang.transstr("residual_time") .. string.convertSecondToTime(time)
    end)
    self.buttonPay.interactable = not self.growthPlanModel:IsBought()
    self.goPayBtnText.text = self.growthPlanModel:IsBought() and lang.trans("bought") or lang.trans("activity_buyGrowth", tostring(self.growthPlanModel:GetDiamondToBuy()))
    if self.growthPlanModel:IsBought() then
        self.goPayBtnText.text = lang.trans("bought")
    else
        local currencyType = self.growthPlanModel:GetPayType()
        if currencyType == CurrencyType.Diamond or not currencyType then
            self.goPayBtnText.text = lang.trans("activity_buyGrowth", tostring(self.growthPlanModel:GetDiamondToBuy()))
        elseif currencyType == CurrencyType.BlackDiamond then
            self.goPayBtnText.text = lang.trans("activity_buyGrowth_1", tostring(self.growthPlanModel:GetDiamondToBuy()))
        elseif currencyType == CurrencyType.Money then
            self.goPayBtnText.text = lang.trans("activity_buyGrowth_2", tostring(self.growthPlanModel:GetDiamondToBuy()))
        end
    end
    self.activityDes.text = self.growthPlanModel:GetActivityDesc()
    self.goPayBtn:regOnButtonClick(function()
        if type(self.buyGrowthPlan) == "function" then
            self.buyGrowthPlan()
        end
    end)
    self.scrollView:InitView(self.growthPlanModel)
end

function GrowthPlanView:OnEnterScene()
    self.super.OnEnterScene(self)
end

function GrowthPlanView:OnExitScene()
    self.super.OnExitScene(self)
end

function GrowthPlanView:RefreshScrollView()
    -- 更新model数据
    if type(self.resetCousume) == "function" then
        self.resetCousume()
    end
end

function GrowthPlanView:OnRefresh()
end

function GrowthPlanView:onDestroy()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
end

return GrowthPlanView

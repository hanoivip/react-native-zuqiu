local VIP = require("data.VIP")
local Timer = require('ui.common.Timer')
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CurrencyType = require("ui.models.itemList.CurrencyType")
local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")
local ChainGrowthPlanState = require("ui.scene.activity.ChainGrowthPlan.ChainGrowthPlanState")
local ChainGrowthPlanView = class(ActivityParentView)

function ChainGrowthPlanView:ctor()
--------Start_Auto_Generate--------
    self.residualTimeTxt = self.___ex.residualTimeTxt
    self.titleTxt = self.___ex.titleTxt
    self.vipLimitTxt = self.___ex.vipLimitTxt
    self.confirmBtn = self.___ex.confirmBtn
    self.confirmTxt = self.___ex.confirmTxt
    self.confirmInfoGo = self.___ex.confirmInfoGo
    self.buyPreTxt = self.___ex.buyPreTxt
    self.diamondGo = self.___ex.diamondGo
    self.bkdGo = self.___ex.bkdGo
    self.mGo = self.___ex.mGo
    self.priceTxt = self.___ex.priceTxt
    self.boughtGo = self.___ex.boughtGo
    self.tabScrollSpt = self.___ex.tabScrollSpt
    self.mainScrollSpt = self.___ex.mainScrollSpt
--------End_Auto_Generate----------
    self.confirmButton = self.___ex.confirmButton
end

function ChainGrowthPlanView:start()
    self.confirmBtn:regOnButtonClick(function()
        if type(self.buyGrowthPlan) == "function" then
            self.buyGrowthPlan()
        end
    end)
end

function ChainGrowthPlanView:InitView(growthPlanModel, tabTag)
    self.activityModel = growthPlanModel
    local defaultTabTag = self.activityModel:GetDefaultTabTag()
    self.tabTag = tabTag or defaultTabTag
    assert(self.tabTag, "data error!!!")

    self.isActActive = true
    self.activityModel:SetActState(self.isActActive)
    self.activityModel:SetSelectedTabTag(self.tabTag)

    self:RefreshContent()
end

function ChainGrowthPlanView:RefreshContent()
    self:RefreshCountDownTxt()
    self:InitVipConstraintTxt()
    self:InitBuyButtonStyle()
    self.mainScrollSpt:InitView(self.activityModel)
    self:InitTabScrollArea()
end

function ChainGrowthPlanView:RefreshCountDownTxt()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end

    local remainTime = self.activityModel:GetRemainTime()
    if remainTime <= 1 then
        self.isActActive = false
        self.activityModel:SetActState(self.isActActive)
        self.residualTimeTxt.text = lang.transstr("visit_endInfo")
        return
    end

    self.residualTimer = Timer.new(remainTime, function(time)
        self.residualTimeTxt.text = lang.transstr("residual_time") .. string.convertSecondToTime(time)
        if time <= 1 then
            self:DoIfActEnd()
        end
    end)
end

function ChainGrowthPlanView:DoIfActEnd()
    self.isActActive = false
    self.activityModel:SetActState(self.isActActive)
    self.residualTimeTxt.text = lang.transstr("visit_endInfo")
    self:InitBuyButtonStyle()
    self.mainScrollSpt:InitView(self.activityModel)
end

function ChainGrowthPlanView:InitVipConstraintTxt()
    local vipLow = self.activityModel:GetVipLow()
    local vipHigh = self.activityModel:GetVipHigh()
    local maxVipValue = 0
    local buyTipStr = ""
    for k, v in pairs(VIP) do
        if v.vipLv > maxVipValue then
            maxVipValue = v.vipLv
        end
    end
    if not (vipLow == 0 and (vipHigh == maxVipValue or vipHigh == 0)) then
        GameObjectHelper.FastSetActive(self.rightTipObj, true)
        buyTipStr = lang.transstr("growthPlan_tip", tostring(vipLow), tostring(vipHigh))
    end
    self.vipLimitTxt.text = buyTipStr
    self.titleTxt.text = self.activityModel:GetActTitle()
end

function ChainGrowthPlanView:InitBuyButtonStyle()
    local isGrowthPlanBought = self.activityModel:IsBought()
    GameObjectHelper.FastSetActive(self.confirmButton.gameObject, not isGrowthPlanBought)
    if not self.isActActive then
        self.confirmButton.interactable = false
        self.confirmTxt.text = lang.transstr("visit_endInfo")
        GameObjectHelper.FastSetActive(self.confirmInfoGo, false)
        return
    end
    GameObjectHelper.FastSetActive(self.confirmInfoGo, true)

    local clientBuyState = self.activityModel:GetClientBuyState()
    self.confirmButton.interactable = (clientBuyState == ChainGrowthPlanState.Buy)
    GameObjectHelper.FastSetActive(self.boughtGo, isGrowthPlanBought)
    if isGrowthPlanBought then
        self.confirmTxt.text = lang.trans("bought")
    else
        local currencyType = self.activityModel:GetPayType()
        local price = self.activityModel:GetBuyCount()
        local maxIndex = self.activityModel:GetMaxIndex()
        local maxOpenIndex = self.activityModel:GetMaxOpenIndex()
        GameObjectHelper.FastSetActive(self.diamondGo, currencyType == CurrencyType.Diamond)
        GameObjectHelper.FastSetActive(self.bkdGo, currencyType == CurrencyType.BlackDiamond)
        GameObjectHelper.FastSetActive(self.mGo, currencyType == CurrencyType.Money)
        if currencyType == CurrencyType.Money then
            self.priceTxt.text = "x" .. string.formatIntWithTenThousands(price)
        else
            self.priceTxt.text = "x" .. price
        end
        local preStr
        if self.tabTag == 1 or self.tabTag == maxOpenIndex then
            preStr = lang.trans("chain_growthplan_next")
        else
            preStr = lang.trans("chain_growthplan_pre")
        end
        if self.tabTag == maxIndex then
            preStr = lang.trans("chain_growthplan_final")
        end
        self.buyPreTxt.text = preStr
        self.confirmTxt.text = lang.trans("buy")
    end
end

function ChainGrowthPlanView:InitTabScrollArea(tabScrollPos)
    local tabDataList = self.activityModel:GetTabDataList()
    self.tabScrollSpt:RegOnItemButtonClick("tabBtn", function(data)
        self:OnClickTab(data)
    end)
    local id = self.activityModel:GetActID()
    self.tabScrollSpt:InitView(tabDataList, id)
    self.tabScrollSpt:SetScrollNormalizedPosition(self.position or 1)
    EventSystem.SendEvent("ChainGrowthPlanTabItemView_OnSelect", id)
    self:AcknowledgeFirstReadAndRefresh()
end

function ChainGrowthPlanView:OnClickTab(data)
    local tabTag = data.uniqueID
    if tabTag then
        self.activityModel:SetSelectedTabTag(tabTag)
    end
    self:AcknowledgeFirstReadAndRefresh()
    EventSystem.SendEvent("ChainGrowthPlanTabItemView_OnSelect", data.id)
    self.position = self.tabScrollSpt:GetScrollNormalizedPosition()
    self:InitView(self.activityModel, tabTag)
end

function ChainGrowthPlanView:onDestroy()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
end

function ChainGrowthPlanView:AcknowledgeFirstReadAndRefresh()
    if self.activityModel:IsActFirstRead() then
        self:coroutine(function ()
            local tabTag = self.activityModel:GetSelectedTabTag(tabTag)
            local response = req.activityRead(self.activityModel:GetActivityType(), self.activityModel:GetActID(), nil, nil, true)
            self.activityModel:SetActFirstRead(false)
        end)
    end
end

function ChainGrowthPlanView:OnEnterScene()
    ChainGrowthPlanView.super.OnEnterScene(self)
    EventSystem.AddEvent("PlayerInfoModel_SetMoney", self, self.ResetCousume)
end

function ChainGrowthPlanView:OnExitScene()
    ChainGrowthPlanView.super.OnExitScene(self)
    EventSystem.RemoveEvent("PlayerInfoModel_SetMoney", self, self.ResetCousume)
end

return ChainGrowthPlanView

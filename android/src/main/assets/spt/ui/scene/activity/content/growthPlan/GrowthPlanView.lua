local VIP = require("data.VIP")
local Timer = require('ui.common.Timer')
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")
local GrowthPlanView = class(ActivityParentView)

function GrowthPlanView:ctor()
    self.timeTxt = self.___ex.timeTxt
    self.buyButtonSpt = self.___ex.buyButtonSpt
    self.buyButtonBtn = self.___ex.buyButtonBtn
    self.scrollToLeft = self.___ex.scrollToLeft
    self.scrollToRight = self.___ex.scrollToRight
    self.tabMenuGroup = self.___ex.tabMenuGroup
    self.tabScrollView = self.___ex.tabScrollView
    self.rewardScrollView = self.___ex.rewardScrollView
    self.buyButtonTxt = self.___ex.buyButtonTxt
    self.arrowLeftIcon = self.___ex.arrowLeftIcon
    self.arrowRightIcon = self.___ex.arrowRightIcon
    self.vipConstraintTxt = self.___ex.vipConstraintTxt
    self.rightTipObj = self.___ex.rightTipObj
    self.leftTipTxt = self.___ex.leftTipTxt
    self:InitTabScrollViewFuncs()
end

function GrowthPlanView:start()
    self.buyButtonSpt:regOnButtonClick(function()
        if type(self.buyGrowthPlan) == "function" then
            self.buyGrowthPlan()
        end
    end)
end

function GrowthPlanView:InitView(growthPlanModel, tabTag)
    self.activityModel = growthPlanModel
    local defaultTabTag = self.activityModel:GetDefaultTabTag()
    self.tabTag = tabTag or defaultTabTag
    assert(self.tabTag, "data error!!!")

    self.isActActive = true
    self.activityModel:SetActState(self.isActActive)
    self.activityModel:SetSelectedTabTag(self.tabTag)
    if not tabTag then
        self:InitTabScrollArea()
    end

    self:RefreshContent()
end

function GrowthPlanView:RefreshContent()
    self:RefreshCountDownTxt()
    self:InitLeftTipTxt()
    self:InitVipConstraintTxt()
    self:InitBuyButtonStyle()
    
    self.rewardScrollView:InitView(self.activityModel)
end

function GrowthPlanView:InitLeftTipTxt()
    self.leftTipTxt.text = self.activityModel:GetActDesc()
end

function GrowthPlanView:RefreshCountDownTxt()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end

    local remainTime = self.activityModel:GetRemainTime()
    if remainTime <= 0 then
        self.isActActive = false
        self.activityModel:SetActState(self.isActActive)
        self.timeTxt.text = lang.transstr("visit_endInfo")
        self:SetTabRedPointHide()
        return
    end

    self.residualTimer = Timer.new(remainTime, function(time)
        if self.timeTxt then
            self.timeTxt.text = lang.transstr("residual_time") .. string.convertSecondToTime(time)
        end
        if time <= 0 then
            self:DoIfActEnd()
        end
    end)
end

function GrowthPlanView:DoIfActEnd()
    self.isActActive = false
    self.activityModel:SetActState(self.isActActive)
    self.timeTxt.text = lang.transstr("visit_endInfo")
    self:InitBuyButtonStyle()
    self:SetTabRedPointHide()
    self.rewardScrollView:InitView(self.activityModel)
end

function GrowthPlanView:SetTabRedPointHide()
    local selectedTabTag = self.activityModel:GetSelectedTabTag()
    EventSystem.SendEvent("TabItem_RefreshRedPoint", selectedTabTag, false)
end

function GrowthPlanView:InitVipConstraintTxt()
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
    else
        GameObjectHelper.FastSetActive(self.rightTipObj, false)
    end
    self.vipConstraintTxt.text = buyTipStr
end

function GrowthPlanView:InitBuyButtonStyle()
    if not self.isActActive then
        self.buyButtonBtn.interactable = false
        self.buyButtonTxt.text = lang.transstr("visit_endInfo")
        return
    end

    local isGrowthPlanBought = self.activityModel:IsBought()
    self.buyButtonBtn.interactable = not isGrowthPlanBought
    if isGrowthPlanBought then
        self.buyButtonTxt.text = lang.trans("bought")
    else
        local currencyType = self.activityModel:GetPayType()
        local langStr = "growthPlan_buy_" .. currencyType
        self.buyButtonTxt.text = lang.trans(langStr, tostring(self.activityModel:GetBuyCount()))
    end
end

function GrowthPlanView:InitTabScrollViewFuncs()
    self.tabMenuGroup.menu = {}

    self.tabScrollView:regOnCreateItem(function (scrollSelf, index)
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/Activties/GrowthPlan/GrowthPlanTabItem.prefab"
        local obj, spt = res.Instantiate(prefab)
        scrollSelf:resetItem(spt, index)
        return obj
    end)
    self.tabScrollView:regOnResetItem(function (scrollSelf, spt, index)
        local tag = scrollSelf.itemDatas[index].uniqueID
        local title = scrollSelf.itemDatas[index].title
        spt:Init(title, tag)
        local hasRewardCollectable = self.activityModel:HasRewardCollectable(tag)
        spt:RefreshRedPoint(tag, hasRewardCollectable or scrollSelf.itemDatas[index].isFirstRead)
        self.tabMenuGroup.menu[tag] = spt
        self.tabMenuGroup:BindMenuItem(tag, function()
            self:OnClickTab(tag)
        end)
    end)

    self.scrollToLeft:regOnButtonClick(function()
        self.tabScrollView:scrollToPreviousGroup()
    end)
    self.scrollToRight:regOnButtonClick(function()
        self.tabScrollView:scrollToNextGroup();
    end)

    self.tabScrollView:regOnItemIndexChanged(function(index)
        local tabCount = #self.tabScrollView.itemDatas
        local viewShowTabNum = 5
        GameObjectHelper.FastSetActive(self.scrollToLeft.gameObject, index > 1)
        GameObjectHelper.FastSetActive(self.arrowLeftIcon, index == 1)
        
        local isShowRightArrow = tabCount > viewShowTabNum and index < tabCount - viewShowTabNum + 1
        GameObjectHelper.FastSetActive(self.scrollToRight.gameObject, isShowRightArrow)
        GameObjectHelper.FastSetActive(self.arrowRightIcon, not isShowRightArrow)
    end)
end

function GrowthPlanView:InitTabScrollArea(tabScrollPos)
    local tabDataList = self.activityModel:GetTabDataList()
    self.tabScrollView:refresh(tabDataList, tabScrollPos)
    self.tabMenuGroup:selectMenuItem(self.tabTag)
    self:InitArrowButtonArea()
end

function GrowthPlanView:InitArrowButtonArea()
    local tabCount = #self.tabScrollView.itemDatas
    local viewShowTabNum = 5
    GameObjectHelper.FastSetActive(self.scrollToLeft.gameObject, false)
    GameObjectHelper.FastSetActive(self.arrowLeftIcon, true)
    
    GameObjectHelper.FastSetActive(self.scrollToRight.gameObject, tabCount > viewShowTabNum)
    GameObjectHelper.FastSetActive(self.arrowRightIcon, tabCount <= viewShowTabNum)
end

function GrowthPlanView:OnClickTab(tabTag)
    if tabTag then
        self.activityModel:SetSelectedTabTag(tabTag)
    end
    if self.activityModel:IsActFirstRead() then
        self:coroutine(function ()
            local response = req.activityRead(self.activityModel:GetActivityType(), self.activityModel:GetActID(), nil, nil, true)
            self.activityModel:SetActFirstRead(false)
            EventSystem.SendEvent("TabItem_RefreshRedPoint", tabTag, false)
            self:InitView(self.activityModel, tabTag)
        end)
    else
        self:InitView(self.activityModel, tabTag)
    end
end

function GrowthPlanView:RefreshScrollView()
    -- 更新model数据
    if type(self.resetCousume) == "function" then
        self.resetCousume()
    end
end

function GrowthPlanView:OnRefresh()
end

function GrowthPlanView:OnEnterScene()
    self.super.OnEnterScene(self)
end

function GrowthPlanView:OnExitScene()
    self.super.OnExitScene(self)
end

function GrowthPlanView:onDestroy()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
end

return GrowthPlanView

local GameObjectHelper = require("ui.common.GameObjectHelper")
local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")

local TimeLimitGiftBoxView = class(ActivityParentView)

function TimeLimitGiftBoxView:ctor()
    self.scrollView = self.___ex.scrollView
    self.timeTxt = self.___ex.timeTxt
    self.tabMenuScroll = self.___ex.tabMenuScroll
    self.tabMenuGroup = self.___ex.tabMenuGroup
    self.scrollToLeft = self.___ex.scrollToLeft
    self.scrollToRight = self.___ex.scrollToRight
    self.leftNormalObj = self.___ex.leftNormalObj
    self.leftHighlightObj = self.___ex.leftHighlightObj
    self.rightNormalObj = self.___ex.rightNormalObj
    self.rightHighlightObj = self.___ex.rightHighlightObj
    self.onlyOneTabBtn = self.___ex.onlyOneTabBtn
    self.residualTimer = nil
end

function TimeLimitGiftBoxView:InitView(giftboxModel, tabTag)
    self.giftboxModel = giftboxModel
    if not tabTag then
        tabTag = self.giftboxModel:GetSelectedTabTag()
        assert(tabTag, "data error!!!")
        self.giftboxModel:SetSelectedTabTag(tabTag)
        self:InitTabMenu()
    else
        self.isUseOldScrollPos = false
        self:RefreshContent()
    end
    self:InitActDurationTxt()
end

function TimeLimitGiftBoxView:InitActDurationTxt()
    local startTime = self.giftboxModel:GetBeginTime()
    local endTime = self.giftboxModel:GetEndTime()
    startTime = string.convertSecondToMonth(startTime)
    endTime = string.convertSecondToMonth(endTime)
    self.timeTxt.text = lang.trans("cumulative_pay_time", startTime, endTime)
end

function TimeLimitGiftBoxView:RefreshContent()
    local scrollPos = 1
    if self.isUseOldScrollPos then
        scrollPos = self.scrollView:GetScrollPos()
    end
    self.scrollView:InitView(self.giftboxModel, scrollPos)
end

function TimeLimitGiftBoxView:start()
    self.onlyOneTabBtn:regOnButtonClick(function()
        if type(self.clickOnlyOneTab) == "function" then
            self.clickOnlyOneTab()
        end
    end)
end

function TimeLimitGiftBoxView:ShowOrHideOnlyOneTabBtn(isShow)
    GameObjectHelper.FastSetActive(self.onlyOneTabBtn.gameObject, isShow)
end

function TimeLimitGiftBoxView:InitTabMenu()
    self:InitTabScrollViewFuncs()
    self:InitTabScrollArea()
end

function TimeLimitGiftBoxView:InitTabScrollArea()
    local tabDataList = self.giftboxModel:GetTabDataList()
    self.tabMenuScroll:refresh(tabDataList)
    local selectedTabTag = self.giftboxModel:GetSelectedTabTag()
    self.tabMenuGroup:selectMenuItem(selectedTabTag)
end

function TimeLimitGiftBoxView:InitTabScrollViewFuncs()
    self.tabMenuGroup.menu = {}

    self.tabMenuScroll:regOnCreateItem(function (scrollSelf, index)
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/Activties/TimeLimitGiftBag/GiftBagTabItem.prefab"
        local obj, spt = res.Instantiate(prefab)
        scrollSelf:resetItem(spt, index)
        return obj
    end)
    self.tabMenuScroll:regOnResetItem(function (scrollSelf, spt, index)
        local tag = scrollSelf.itemDatas[index].tabTag
        local title = scrollSelf.itemDatas[index].title
        local isSpecialTab = self.giftboxModel:IsSpecialTabByTag(tag)
        spt:Init(title, tag, isSpecialTab)
        spt:RefreshRedPoint(tag, scrollSelf.itemDatas[index].isFirstRead)
        self.tabMenuGroup.menu[tag] = spt
        self.tabMenuGroup:BindMenuItem(tag, function()
            self:OnClickTab(tag)
        end)
    end)

    self.scrollToLeft:regOnButtonClick(function()
        self.tabMenuScroll:scrollToPreviousGroup()
    end)
    self.scrollToRight:regOnButtonClick(function()
        self.tabMenuScroll:scrollToNextGroup();
    end)

    self.tabMenuScroll:regOnItemIndexChanged(function(index)
        local tabCount = table.nums(self.tabMenuScroll.itemDatas)
        local viewShowTabNum = 4
        local isShowLeftArrow = tabCount > viewShowTabNum and index > 1
        GameObjectHelper.FastSetActive(self.leftNormalObj, not isShowLeftArrow)
        GameObjectHelper.FastSetActive(self.leftHighlightObj, isShowLeftArrow)
        
        local isShowRightArrow = tabCount > viewShowTabNum and index < tabCount - viewShowTabNum + 1
        GameObjectHelper.FastSetActive(self.rightNormalObj, not isShowRightArrow)
        GameObjectHelper.FastSetActive(self.rightHighlightObj, isShowRightArrow)
    end)
end

function TimeLimitGiftBoxView:OnClickTab(tabTag)
    if tabTag then
        self.giftboxModel:SetSelectedTabTag(tabTag)
    end
    if self.giftboxModel:IsActFirstRead() then
        local func = function() self:InitView(self.giftboxModel, tabTag) end
        self:AcknowledgeFirstReadAndRefresh(self.giftboxModel, tabTag, func)
    else
        self:InitView(self.giftboxModel, tabTag)
    end
end

function TimeLimitGiftBoxView:AcknowledgeFirstReadAndRefresh(giftboxModel, tabTag, func)
    self:coroutine(function ()
        local response = req.activityRead(giftboxModel:GetActivityType(), giftboxModel:GetActID(), nil, nil, true)
        giftboxModel:SetActFirstRead(false)
        EventSystem.SendEvent("TabItem_RefreshRedPoint", tabTag, false)
        if type(func) == "function" then
            func()
        end
    end)
end

function TimeLimitGiftBoxView:UseOldScrollPos()
    self.isUseOldScrollPos = true
end

function TimeLimitGiftBoxView:OnEnterScene()
    self.isUseOldScrollPos = false
    self.super.OnEnterScene(self)
    EventSystem.AddEvent("TimeLimitGiftBox_UseOldScrollPos", self, self.UseOldScrollPos)
end

function TimeLimitGiftBoxView:OnExitScene()
    self.super.OnExitScene(self)
    EventSystem.RemoveEvent("TimeLimitGiftBox_UseOldScrollPos", self, self.UseOldScrollPos)
end

function TimeLimitGiftBoxView:onDestroy()
end

return TimeLimitGiftBoxView

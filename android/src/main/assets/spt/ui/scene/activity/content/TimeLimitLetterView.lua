local GameObjectHelper = require("ui.common.GameObjectHelper")
local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")
local TimeLimitLetterView = class(ActivityParentView)

function TimeLimitLetterView:ctor()
    self.residualTime = self.___ex.residualTime
    self.scrollView = self.___ex.scrollView
    self.activityDes = self.___ex.activityDes
    self.activityTime = self.___ex.activityTime
    self.tabMenuGroup = self.___ex.tabMenuGroup
    self.tabMenuScroll = self.___ex.tabMenuScroll
    self.scrollToLeft = self.___ex.scrollToLeft
    self.scrollToRight = self.___ex.scrollToRight
end

function TimeLimitLetterView:InitView(timeLimitedLetterModel)
    self.timeLimitedLetterModel = timeLimitedLetterModel
    self:BuildView()
    EventSystem.SendEvent("ActivityPlayerLetterDetail.RefreshModel", self.timeLimitedLetterModel)
end 

function TimeLimitLetterView:BuildView()
    local beginTime = string.convertSecondToMonth(self.timeLimitedLetterModel:GetBeginTime())
    local endTime = string.convertSecondToMonth(self.timeLimitedLetterModel:GetEndTime())
    self.activityTime.text = lang.trans("cumulative_pay_time", beginTime, endTime)
    self.scrollView:InitView(self.timeLimitedLetterModel)
    self:InitTabMenu()
end

function TimeLimitLetterView:InitTabMenu()
    self:InitTabScrollViewFuncs()
    self:InitTabScrollArea()
end

function TimeLimitLetterView:InitTabScrollArea()
    local tabDataList = self.timeLimitedLetterModel:GetTabDataList()
    self.tabMenuScroll:refresh(tabDataList)
    local selectedTabTag = self.timeLimitedLetterModel:GetSelectedTabTag()
    self:AcknowledgeFirstReadAndRefresh(selectedTabTag)
    self.tabMenuGroup:selectMenuItem(selectedTabTag)
    self.tabMenuScroll:scrollToCellImmediate(self.currentTabIndex or selectedTabTag)
    self.currentTabIndex = 1
end

function TimeLimitLetterView:InitTabScrollViewFuncs()
    self.tabMenuGroup.menu = {}
    local prefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/TimeLimitLetter/TimeLimitLetterTabItem.prefab"

    self.tabMenuScroll:regOnCreateItem(function(scrollSelf, index)
        local obj, spt = res.Instantiate(prefabPath)
        scrollSelf:resetItem(spt, index)
        return obj
    end)
    self.tabMenuScroll:regOnResetItem(function(scrollSelf, spt, index)
        local tag = scrollSelf.itemDatas[index].tabTag
        spt:Init(scrollSelf.itemDatas[index])
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
        self.tempTabIndex = index
        local tabCount = table.nums(self.tabMenuScroll.itemDatas)
        local viewShowTabNum = 4
        local isShowLeftArrow = tabCount > viewShowTabNum and index > 1
        GameObjectHelper.FastSetActive(self.scrollToLeft.gameObject, isShowLeftArrow)
        
        local isShowRightArrow = tabCount > viewShowTabNum and index < tabCount - viewShowTabNum + 1
        GameObjectHelper.FastSetActive(self.scrollToRight.gameObject, isShowRightArrow)
    end)
end

function TimeLimitLetterView:OnClickTab(tabTag)
    if tabTag then
        self.timeLimitedLetterModel:SetSelectedTabTag(tabTag)
    end
    self:AcknowledgeFirstReadAndRefresh(tabTag)
    self.currentTabIndex = self.tempTabIndex
    self:InitView(self.timeLimitedLetterModel)
end

function TimeLimitLetterView:AcknowledgeFirstReadAndRefresh(tabTag)
    if self.timeLimitedLetterModel:IsActFirstRead() then
        self:coroutine(function ()
            local response = req.activityRead(self.timeLimitedLetterModel:GetActivityType(), self.timeLimitedLetterModel:GetActID(), nil, nil, true)
            self.timeLimitedLetterModel:SetActFirstRead(false)
        end)
    end
end

return TimeLimitLetterView
local Timer = require('ui.common.Timer')
local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local MultiSerialPayView = class(ActivityParentView)

function MultiSerialPayView:ctor()
    self.scrollView = self.___ex.scrollView
    self.activityDes = self.___ex.activityDes
    self.timeTxt = self.___ex.timeTxt
    self.goPayBtn = self.___ex.goPayBtn
    self.cumulativePayBtn = self.___ex.cumulativePayBtn
    self.cumulativePayTxt = self.___ex.cumulativePayTxt
    self.dayScroll = self.___ex.dayScroll
    self.nextNone = self.___ex.nextNone
    self.nextExist = self.___ex.nextExist
    self.prevNone = self.___ex.prevNone
    self.prevExist = self.___ex.prevExist
    self.nextBtn = self.___ex.nextBtn
    self.prevBtn = self.___ex.prevBtn
end

function MultiSerialPayView:start()
end

function MultiSerialPayView:InitView(multiSerialPayModel)
    self.multiSerialPayModel = multiSerialPayModel
    self.goPayBtn:regOnButtonClick(function ()
        if self.onClickPayBtn then
            self.onClickPayBtn()
        end
    end)
    self.cumulativePayBtn:regOnButtonClick(function ()
        if self.onClickCumulativePayBtn then
            self.onClickCumulativePayBtn()
        end
    end)
end

function MultiSerialPayView:InitDayScrollView(serialUpData)
    self.dayScroll:regOnCreateItem(function (scrollSelf, index)
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/Activties/MultiSerialPay/MultiSerialUpItem.prefab"
        local obj, spt = res.Instantiate(prefab)
        scrollSelf:resetItem(spt, index)
        return obj
    end)
    self.dayScroll:regOnItemIndexChanged(function(index)
        GameObjectHelper.FastSetActive(self.prevNone, index == 1)
        GameObjectHelper.FastSetActive(self.prevExist, index > 1)
        self.prevBtn:onPointEventHandle(index > 1)

        GameObjectHelper.FastSetActive(self.nextNone, index >= #self.dayScroll.itemDatas - 5)
        GameObjectHelper.FastSetActive(self.nextExist, index < #self.dayScroll.itemDatas - 5)
        self.nextBtn:onPointEventHandle(index < #self.dayScroll.itemDatas - 5)
    end)

    self.prevBtn:regOnButtonClick(function()
        self.dayScroll:scrollToPreviousGroup()
    end)
    self.nextBtn:regOnButtonClick(function()
        self.dayScroll:scrollToNextGroup()
    end)

    self.dayScroll:regOnResetItem(function (scrollSelf, spt, index)
        local data = scrollSelf.itemDatas[index]
        spt:Init(data, data.price == self.multiSerialPayModel:GetCurrMoneyTag())
        spt.onClickBtn = function ()
            self.multiSerialPayModel:SetCurrMoneyTag(data.price)
        end
        scrollSelf:updateItemIndex(spt, index)
    end)

    self.dayScroll:refresh(serialUpData)
end

function MultiSerialPayView:RefreshContent()
    self.activityDes.text = self.multiSerialPayModel:GetActivityDesc()
    self.cumulativePayTxt.text = lang.trans("today_cumulative_pay_tip", self.multiSerialPayModel:GetCostByIndex(self.multiSerialPayModel:GetTodayIndex()))
    self.timeTxt.text = lang.trans("cumulative_pay_time", string.convertSecondToMonth(self.multiSerialPayModel:GetStartTime()), 
                            string.convertSecondToMonth(self.multiSerialPayModel:GetEndTime()))
    self.scrollView:InitView(self.multiSerialPayModel)
    self:InitDayScrollView(self.multiSerialPayModel:GetMoneyList())
end

function MultiSerialPayView:RefreshRewardContent()
    self.scrollView:InitView(self.multiSerialPayModel)
    self:InitDayScrollView(self.multiSerialPayModel:GetMoneyList())
end

return MultiSerialPayView
local Timer = require('ui.common.Timer')
local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local SerialPayView = class(ActivityParentView)

function SerialPayView:ctor()
    self.residualTime = self.___ex.residualTime
    self.scrollView = self.___ex.scrollView
    self.activityDes = self.___ex.activityDes
    self.timeTxt = self.___ex.timeTxt
    self.goPayBtn = self.___ex.goPayBtn
    self.dayScroll = self.___ex.dayScroll
    self.nextNone = self.___ex.nextNone
    self.nextExist = self.___ex.nextExist
    self.prevNone = self.___ex.prevNone
    self.prevExist = self.___ex.prevExist
    self.nextBtn = self.___ex.nextBtn
    self.prevBtn = self.___ex.prevBtn
end

function SerialPayView:start()
end

function SerialPayView:InitView(serialPayModel)
    self.serialPayModel = serialPayModel
    self.goPayBtn:regOnButtonClick(function ()
        res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl")
    end)
end

function SerialPayView:InitDayScrollView(serialUpItemModel)
    self.dayScroll:regOnCreateItem(function (scrollSelf, index)
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/SerialUpItem.prefab"
        local obj, spt = res.Instantiate(prefab)
        scrollSelf:resetItem(spt, index)
        return obj
    end)
    self.dayScroll:regOnItemIndexChanged(function(index)
        GameObjectHelper.FastSetActive(self.prevNone, index == 1)
        GameObjectHelper.FastSetActive(self.prevExist, index > 1)
        self.prevBtn:onPointEventHandle(index > 1)

        GameObjectHelper.FastSetActive(self.nextNone, index >= #self.dayScroll.itemDatas - 8)
        GameObjectHelper.FastSetActive(self.nextExist, index < #self.dayScroll.itemDatas - 8)
        self.nextBtn:onPointEventHandle(index < #self.dayScroll.itemDatas - 8)
    end)

    self.prevBtn:regOnButtonClick(function()
        self.dayScroll:scrollToPreviousGroup()
    end)
    self.nextBtn:regOnButtonClick(function()
        self.dayScroll:scrollToNextGroup()
    end)

    self.dayScroll:regOnResetItem(function (scrollSelf, spt, index)
        local data = scrollSelf.itemDatas[index]
        local currTime = os.time() - 5 * 60 * 60
        local today = string.convertSecondToMonthAndDay(currTime)
        spt:Init(lang.trans("month_and_day", data.month, data.day, data.price),
            today.month == data.month and today.day == data.day , data.isFinish)
        scrollSelf:updateItemIndex(spt, index)
    end)

    self.dayScroll:refresh(serialUpItemModel)
end

function SerialPayView:RefreshContent()
    self.activityDes.text = self.serialPayModel:GetActivityDesc()
    self.timeTxt.text = lang.trans("cumulative_pay_time", string.convertSecondToMonth(self.serialPayModel:GetStartTime()), 
                            string.convertSecondToMonth(self.serialPayModel:GetEndTime()))
    self.scrollView:InitView(self.serialPayModel)
    self:InitDayScrollView(self.serialPayModel:GetSerialUpItemModel())
end

function SerialPayView:onDestroy()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
end

return SerialPayView
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local CarnivalItemView = class(unity.base)
local TaskState = {
    Lock2 = -3,
    Lock = -2,
    Unlock = -1,
    Finish = 0,
    GetReward = 1,
}

function CarnivalItemView:ctor()
    self.tip = self.___ex.tip
    self.progress = self.___ex.progress
    self.scroll = self.___ex.scroll
    self.parentRect = self.___ex.parentRect
    self.btnOperate = self.___ex.btnOperate
    self.finishObj = self.___ex.finishObj
    self.unlockObj = self.___ex.unlockObj
    self.getRewardObj = self.___ex.getRewardObj
    self.lockObj = self.___ex.lockObj
    self.lockText = self.___ex.lockText
    self.btnObj = self.___ex.btnObj
    self.carnivalItemScrollAtOnce = self.___ex.carnivalItemScrollAtOnce
end

function CarnivalItemView:start()
    self.btnOperate:regOnButtonClick(function()
        self:OnButtonClick()
    end)
    EventSystem.AddEvent("CarnivalItem.UpdateButtonState", self, self.UpdateButtonState)
end

function CarnivalItemView:InitView(data, parentScrollRect)
    self.data = data
    res.ClearChildren(self.carnivalItemScrollAtOnce.gameObject.transform)
    local rewardParams = {
        parentObj = self.parentRect,
        rewardData = data.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    self.carnivalItemScrollAtOnce.scrollRectInParent = parentScrollRect
    RewardDataCtrl.new(rewardParams)
    self:BuildPage()
end

function CarnivalItemView:OnButtonClick(data)
    if self.clickButton then
        self.clickButton(data)
    end
    self:BuildPage()
end

function CarnivalItemView:BuildPage()
    -- 1-1 任务是副本任务，任务进度显示需要特殊处理
    if self.data.dayIndex == 1 and self.data.tagIndex == 1 then
        if self.data.taskValue.value == nil then
            self.progress.text = lang.trans("unfinished")
        else
            self.progress.text = self.data.taskValue.value >= self.data.target and lang.trans("finished_cumulative_login") or lang.trans("unfinished")
        end
    else
        self.progress.text = self.data.taskValue.value == nil and "0" or tostring(self.data.taskValue.value)
        self.progress.text = self.progress.text .. "/" .. self.data.target
    end
    self.taskState = self.data.taskState
    self.tip.text = self.data.desc
    GameObjectHelper.FastSetActive(self.btnObj, self.taskState == TaskState.Unlock or self.taskState == TaskState.Finish)
    GameObjectHelper.FastSetActive(self.getRewardObj, self.taskState == TaskState.GetReward)
    GameObjectHelper.FastSetActive(self.finishObj, self.taskState == TaskState.Finish)
    GameObjectHelper.FastSetActive(self.unlockObj, self.taskState == TaskState.Unlock)
    GameObjectHelper.FastSetActive(self.lockObj, self.taskState == TaskState.Lock or self.taskState == TaskState.Lock2)
    if self.taskState == TaskState.Lock then
        self.lockText.text = lang.trans("carnival_unlockTomorrow")
    elseif self.taskState == TaskState.Lock2 then
        self.lockText.text = lang.trans("carnival_unlockTheDayAfterTomorrow")
    end
end

function CarnivalItemView:UpdateButtonState()
    self:BuildPage()
end

function CarnivalItemView:onDestroy()
    EventSystem.RemoveEvent("CarnivalItem.UpdateButtonState", self, self.UpdateButtonState)
end

return CarnivalItemView
local GameObjectHelper = require("ui.common.GameObjectHelper")
local TabItemView = require("ui.scene.activity.content.growthPlan.TabItemView")
local ReqEventModel = require("ui.models.event.ReqEventModel")
local TimeLimitLetterTabItemView = class(TabItemView)

function TimeLimitLetterTabItemView:Init(itemDatas)
    local tag = itemDatas.tabTag
    local title = itemDatas.title
    local status = itemDatas.status == 0
    local isFirstRead = itemDatas.isFirstRead
    TimeLimitLetterTabItemView.super.Init(self, title, tag)
    self.activityType = itemDatas.type
    self.activityId = itemDatas.id
    GameObjectHelper.FastSetActive(self.redPoint, isFirstRead or status)
end

function TimeLimitLetterTabItemView:start()
    TimeLimitLetterTabItemView.super.start(self)
    EventSystem.AddEvent("ReqEventModel_activity", self, self.UpdateRedPointState)
end

function TimeLimitLetterTabItemView:UpdateRedPointState()
    local activity = ReqEventModel.GetInfo("activity")
    local activityData = activity[self.activityType]
    if activityData == nil then
        GameObjectHelper.FastSetActive(self.redPoint, false)
        return
    end

    local isFirstRead, isCanReceive = false
    if type(activityData) == "table" then
        isFirstRead = tonumber(activityData[tostring(self.activityId)]) == -2
        isCanReceive = tostring(activityData[tostring(self.activityId)]) == "0"
    else
        isFirstRead = tonumber(activityData) == -2
        isCanReceive = tostring(activityData) == "0"
    end
    GameObjectHelper.FastSetActive(self.redPoint, isFirstRead or isCanReceive)
end

function TimeLimitLetterTabItemView:onDestroy()
    TimeLimitLetterTabItemView.super.onDestroy(self)
    EventSystem.RemoveEvent("ReqEventModel_activity", self, self.UpdateRedPointState)
end

return TimeLimitLetterTabItemView


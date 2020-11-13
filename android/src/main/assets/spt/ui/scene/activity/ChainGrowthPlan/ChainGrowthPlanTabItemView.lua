local ReqEventModel = require("ui.models.event.ReqEventModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local ChainGrowthPlanState = require("ui.scene.activity.ChainGrowthPlan.ChainGrowthPlanState")

local ChainGrowthPlanTabItemView = class(unity.base)

function ChainGrowthPlanTabItemView:ctor()
--------Start_Auto_Generate--------
    self.selectGo = self.___ex.selectGo
    self.canBuyGo = self.___ex.canBuyGo
    self.lockGo = self.___ex.lockGo
    self.boughtGo = self.___ex.boughtGo
    self.titleTxt = self.___ex.titleTxt
    self.descTxt = self.___ex.descTxt
    self.tabBtn = self.___ex.tabBtn
    self.redPointGo = self.___ex.redPointGo
--------End_Auto_Generate----------
end

function ChainGrowthPlanTabItemView:start()
    EventSystem.AddEvent("ReqEventModel_activity", self, self.UpdateRedPointState)
    EventSystem.AddEvent("ChainGrowthPlanTabItemView_OnSelect", self, self.UpdateSelectState)
end

function ChainGrowthPlanTabItemView:InitView(data, selectId)
    self.titleTxt.text = data.title
    self.descTxt.text = data.desc
    self.activityType = data.type
    self.activityId = data.id
    GameObjectHelper.FastSetActive(self.canBuyGo, data.clientBuyState == ChainGrowthPlanState.Buy)
    GameObjectHelper.FastSetActive(self.lockGo, data.clientBuyState == ChainGrowthPlanState.Disable)
    GameObjectHelper.FastSetActive(self.boughtGo, data.clientBuyState == ChainGrowthPlanState.Sell)
    GameObjectHelper.FastSetActive(self.selectGo, self.activityId == selectId)
    self:UpdateRedPointState()
end

function ChainGrowthPlanTabItemView:UpdateRedPointState()
    local activity = ReqEventModel.GetInfo("activity")
    local activityData = activity[self.activityType]
    if activityData == nil then
        GameObjectHelper.FastSetActive(self.redPointGo, false)
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
    GameObjectHelper.FastSetActive(self.redPointGo, isFirstRead or isCanReceive)
end

function ChainGrowthPlanTabItemView:UpdateSelectState(activityId)
    GameObjectHelper.FastSetActive(self.selectGo, self.activityId == activityId)
end

function ChainGrowthPlanTabItemView:onDestroy()
    EventSystem.RemoveEvent("ReqEventModel_activity", self, self.UpdateRedPointState)
    EventSystem.RemoveEvent("ChainGrowthPlanTabItemView_OnSelect", self, self.UpdateSelectState)
end

return ChainGrowthPlanTabItemView

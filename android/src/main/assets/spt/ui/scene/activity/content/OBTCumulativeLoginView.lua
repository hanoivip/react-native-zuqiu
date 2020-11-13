local Timer = require('ui.common.Timer')
local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local OBTSerialConsumeView = class(ActivityParentView)

function OBTSerialConsumeView:ctor()
    self.activityTime = self.___ex.activityTime
    self.scrollView = self.___ex.scrollView
    self.activityDes = self.___ex.activityDes
end

function OBTSerialConsumeView:start()
end

function OBTSerialConsumeView:InitView(obtCumulativeLoginModel)
    self.obtCumulativeLoginModel = obtCumulativeLoginModel
    self:RefreshContent()
end

function OBTSerialConsumeView:RefreshContent()
    self.activityDes.text = self.obtCumulativeLoginModel:GetActivityDesc()

    self.activityTime.text = lang.trans("cumulative_pay_time", string.convertSecondToMonth(self.obtCumulativeLoginModel:GetStartTime()), 
                        string.convertSecondToMonth(self.obtCumulativeLoginModel:GetEndTime()))

    self.scrollView:InitView(self.obtCumulativeLoginModel)
end

function OBTSerialConsumeView:OnEnterScene()
    self:RefreshContent()
end

function OBTSerialConsumeView:OnExitScene()
end

function OBTSerialConsumeView:OnRefresh()
end

function OBTSerialConsumeView:onDestroy()
end

return OBTSerialConsumeView
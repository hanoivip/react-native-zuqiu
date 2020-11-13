local Timer = require('ui.common.Timer')
local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")
local OBTCumulativeConsumeView = class(ActivityParentView)

function OBTCumulativeConsumeView:ctor()
    self.residualTime = self.___ex.residualTime
    self.scrollView = self.___ex.scrollView
    self.activityDes = self.___ex.activityDes
    self.activityTime = self.___ex.activityTime
end

function OBTCumulativeConsumeView:start()

end

function OBTCumulativeConsumeView:InitView(obtCumulativeConsumeModel)
    self.obtCumulativeConsumeModel = obtCumulativeConsumeModel
end

function OBTCumulativeConsumeView:RefreshContent()
    self.activityTime.text = lang.trans("cumulative_pay_time", string.convertSecondToMonth(self.obtCumulativeConsumeModel:GetStartTime()), 
                        string.convertSecondToMonth(self.obtCumulativeConsumeModel:GetEndTime()))
                        
    self.activityDes.text = self.obtCumulativeConsumeModel:GetActivityDesc()
    self.scrollView:InitView(self.obtCumulativeConsumeModel)
end

function OBTCumulativeConsumeView:onDestroy()
end

return OBTCumulativeConsumeView
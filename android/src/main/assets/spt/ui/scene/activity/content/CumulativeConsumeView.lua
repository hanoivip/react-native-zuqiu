local Timer = require('ui.common.Timer')
local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")
local CumulativeConsumeView = class(ActivityParentView)

function CumulativeConsumeView:ctor()
    self.residualTime = self.___ex.residualTime
    self.scrollView = self.___ex.scrollView
    self.activityDes = self.___ex.activityDes
    self.residualTimer = nil
end

function CumulativeConsumeView:start()

end

function CumulativeConsumeView:InitView(cumulativeConsumeModel)
    self.cumulativeConsumeModel = cumulativeConsumeModel
end

function CumulativeConsumeView:RefreshContent()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end

    self.residualTimer = Timer.new(self.cumulativeConsumeModel:GetRemainTime(), function(time)
        self.residualTime.text = lang.transstr("residual_time") .. string.convertSecondToTime(time)
    end)

    self.activityDes.text = self.cumulativeConsumeModel:GetActivityDesc()
    self.scrollView:InitView(self.cumulativeConsumeModel)
end

function CumulativeConsumeView:onDestroy()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
end

return CumulativeConsumeView
local ActivityModel = require("ui.models.activity.ActivityModel")
local TimeLimitBrainTraingModel = class(ActivityModel)

function TimeLimitBrainTraingModel:ctor(data)
    TimeLimitBrainTraingModel.super.ctor(self, data)
end

function TimeLimitBrainTraingModel:InitWithProtocol()

end

--- 获取活动说明
function TimeLimitBrainTraingModel:GetDesc()
    local singleData = self:GetActivitySingleData()
    return singleData.desc
end

--- 获取活动开始时间
function TimeLimitBrainTraingModel:GetStartTime()
    local singleData = self:GetActivitySingleData()
    return singleData.beginTime
end

--- 获取活动结束时间
function TimeLimitBrainTraingModel:GetEndTime()
    local singleData = self:GetActivitySingleData()
    return singleData.endTime
end

return TimeLimitBrainTraingModel

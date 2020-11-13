local ActivityModel = require("ui.models.activity.ActivityModel")
local RewardDoubleModel = class(ActivityModel)

function RewardDoubleModel:InitWithProtocol()
end

function RewardDoubleModel:GetRewardData()
    return self:GetActivitySingleData().list
end

function RewardDoubleModel:GetActivityDesc()
    return self:GetActivitySingleData().desc
end

function RewardDoubleModel:GetStartTime()
    return self:GetActivitySingleData().beginTime
end

function RewardDoubleModel:GetEndTime()
    return self:GetActivitySingleData().endTime
end

function RewardDoubleModel:GetBuyTime()
    return self:GetActivitySingleData().value
end

function RewardDoubleModel:GetCondition()
    return self:GetActivitySingleData().list[1].condition
end

return RewardDoubleModel
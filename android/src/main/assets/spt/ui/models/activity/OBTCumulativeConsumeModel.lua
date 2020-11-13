local ActivityModel = require("ui.models.activity.ActivityModel")
local OBTCumulativeConsumeModel = class(ActivityModel)

function OBTCumulativeConsumeModel:InitWithProtocol()
end

function OBTCumulativeConsumeModel:GetRewardSubIdByIndex(index)
    return self:GetActivitySingleData().list[index].subID
end

function OBTCumulativeConsumeModel:GetRewardStatusByIndex(index)
    return self:GetActivitySingleData().list[index].status
end

function OBTCumulativeConsumeModel:SetRewardStatusByIndex(index, value)
    self:GetActivitySingleData().list[index].status = value
end

function OBTCumulativeConsumeModel:GetStartTime()
    return self:GetActivitySingleData().beginTime
end

function OBTCumulativeConsumeModel:GetEndTime()
    return self:GetActivitySingleData().endTime
end

function OBTCumulativeConsumeModel:GetRewardData()
    return self:GetActivitySingleData().list
end

function OBTCumulativeConsumeModel:GetActivityDesc()
    return self:GetActivitySingleData().desc
end

function OBTCumulativeConsumeModel:GetCurrentConsumeDiamondNumber()
    return self:GetActivitySingleData().value
end

function OBTCumulativeConsumeModel:GetConsumeDiamondNumberByIndex(index)
    return self:GetActivitySingleData().list[index].value
end

function OBTCumulativeConsumeModel:GetRewardConditionByIndex(index)
    return self:GetActivitySingleData().list[index].condition
end

return OBTCumulativeConsumeModel
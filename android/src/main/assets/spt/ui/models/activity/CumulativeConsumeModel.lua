local ActivityModel = require("ui.models.activity.ActivityModel")
local CumulativeConsumeModel = class(ActivityModel)

function CumulativeConsumeModel:InitWithProtocol()
end

function CumulativeConsumeModel:GetRewardSubIdByIndex(index)
    return self:GetActivitySingleData().list[index].subID
end

function CumulativeConsumeModel:GetRewardStatusByIndex(index)
    return self:GetActivitySingleData().list[index].status
end

function CumulativeConsumeModel:SetRewardStatusByIndex(index, value)
    self:GetActivitySingleData().list[index].status = value
end

function CumulativeConsumeModel:GetRemainTime()
    return self:GetActivitySingleData().remainTime
end

function CumulativeConsumeModel:GetRewardData()
    return self:GetActivitySingleData().list
end

function CumulativeConsumeModel:GetActivityDesc()
    return self:GetActivitySingleData().desc
end

function CumulativeConsumeModel:GetCurrentConsumeDiamondNumber()
    return self:GetActivitySingleData().value
end

function CumulativeConsumeModel:GetConsumeDiamondNumberByIndex(index)
    return self:GetActivitySingleData().list[index].value
end

function CumulativeConsumeModel:GetRewardConditionByIndex(index)
    return self:GetActivitySingleData().list[index].condition
end

return CumulativeConsumeModel
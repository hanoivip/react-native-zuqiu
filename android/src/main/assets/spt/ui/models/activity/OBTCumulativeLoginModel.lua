local ActivityModel = require("ui.models.activity.ActivityModel")
local OBTSerialConsumeModel = class(ActivityModel)

function OBTSerialConsumeModel:InitWithProtocol()
end

function OBTSerialConsumeModel:GetRewardSubIdByIndex(index)
    return self:GetActivitySingleData().list[index].subID
end

function OBTSerialConsumeModel:GetRewardStatusByIndex(index)
    return self:GetActivitySingleData().list[index].status
end

function OBTSerialConsumeModel:SetRewardStatusByIndex(index, value)
    self:GetActivitySingleData().list[index].status = value
end

function OBTSerialConsumeModel:GetRewardData()
    return self:GetActivitySingleData().list
end

function OBTSerialConsumeModel:GetActivityDesc()
    return self:GetActivitySingleData().desc
end

function OBTSerialConsumeModel:GetCurrentConsumeDiamondNumber()
    return self:GetActivitySingleData().value
end

function OBTSerialConsumeModel:GetConsumeDiamondNumberByIndex(index)
    return self:GetActivitySingleData().list[index].value
end

function OBTSerialConsumeModel:GetRewardConditionByIndex(index)
    return self:GetActivitySingleData().list[index].condition
end

function OBTSerialConsumeModel:GetPayDescByIndex(index)
    return self:GetActivitySingleData().list[index].conditionDesc
end

function OBTSerialConsumeModel:GetStartTime()
    return self:GetActivitySingleData().beginTime
end

function OBTSerialConsumeModel:GetEndTime()
    return self:GetActivitySingleData().endTime
end

function OBTSerialConsumeModel:GetSerialUpItemModel()
    return self:GetActivitySingleData().list
end


return OBTSerialConsumeModel
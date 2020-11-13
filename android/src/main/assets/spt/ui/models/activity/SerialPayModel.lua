local ActivityModel = require("ui.models.activity.ActivityModel")
local SerialPayModel = class(ActivityModel)

function SerialPayModel:InitWithProtocol()
end

function SerialPayModel:GetRewardSubIdByIndex(index)
    return self:GetActivitySingleData().list[index].subID
end

function SerialPayModel:GetRewardStatusByIndex(index)
    return self:GetActivitySingleData().list[index].status
end

function SerialPayModel:SetRewardStatusByIndex(index, value)
    self:GetActivitySingleData().list[index].status = value
end

function SerialPayModel:GetRewardData()
    return self:GetActivitySingleData().list
end

function SerialPayModel:GetActivityDesc()
    return self:GetActivitySingleData().desc
end

function SerialPayModel:GetCurrentConsumeDiamondNumber()
    return self:GetActivitySingleData().value
end

function SerialPayModel:GetConsumeDiamondNumberByIndex(index)
    return self:GetActivitySingleData().list[index].value
end

function SerialPayModel:GetRewardConditionByIndex(index)
    return self:GetActivitySingleData().list[index].condition
end

function SerialPayModel:GetPayDescByIndex(index)
    return self:GetActivitySingleData().list[index].conditionDesc
end

function SerialPayModel:GetStartTime()
    return self:GetActivitySingleData().beginTime
end

function SerialPayModel:GetEndTime()
    return self:GetActivitySingleData().endTime
end

function SerialPayModel:GetPayPrice()
    return self:GetActivitySingleData().list[1].condition1
end

function SerialPayModel:GetCostByIndex(index)
    return self:GetActivitySingleData().param[index]
end

function SerialPayModel:GetSerialUpItemModel()
    local data = string.convertSecondToMonthAndDayRange(self:GetStartTime(), self:GetEndTime())
    for i, v in ipairs(data) do
        v.isFinish = self:GetCostByIndex(i) >= self:GetPayPrice()
        v.price = self:GetPayPrice()
        v.timestamp = self:GetStartTime() + 24 * 60 * 60 * (i - 1)
    end
    return data
end


return SerialPayModel
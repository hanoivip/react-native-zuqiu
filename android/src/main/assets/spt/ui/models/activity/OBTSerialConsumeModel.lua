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

function OBTSerialConsumeModel:GetPayPrice()
    return self:GetActivitySingleData().list[1].condition1
end

function OBTSerialConsumeModel:GetCostByIndex(index)
    -- return self:GetActivitySingleData().param[index]
    return 0
end

function OBTSerialConsumeModel:GetSerialUpItemModel()
    local data = string.convertSecondToMonthAndDayRange(self:GetStartTime(), self:GetEndTime())
    for i, v in ipairs(data) do
        -- v.isFinish = self:GetCostByIndex(i) >= self:GetPayPrice()
        -- v.price = self:GetPayPrice()
        -- v.timestamp = self:GetStartTime() + 24 * 60 * 60 * (i - 1)
        v.isFinish = false
        v.price = 100
        v.timestamp = self:GetStartTime() + 24 * 60 * 60 * (i - 1)        
    end
    return data
end

function OBTSerialConsumeModel:GetServerTime()
    return self:GetActivitySingleData().currTime
end

-- 获得活动期间，今日在params中的下标
function OBTSerialConsumeModel:GetTodayIndex()
    local currTime = self:GetServerTime()
    local beginTime = self:GetStartTime()
    local index = (currTime - beginTime) / (24 * 60 * 60)
    return math.floor(index) + 1
end

function OBTSerialConsumeModel:GetHistoryTxt()
    local second = 24 * 60 * 60
    local startTime = self:GetStartTime()
    local txt = ""
    for i = 0, self:GetTodayIndex() - 1, 1 do
        local timeTable = string.convertSecondToYearAndMonthAndDay(startTime + i * second)
        txt = txt .. lang.transstr("serial_consume_history_item", timeTable.year, string.format("%02d", timeTable.month), string.format("%02d", timeTable.day), i + 1, self:GetCostByIndex(i+1))
    end
    return txt
end

function OBTSerialConsumeModel:GetCostByIndex(index)
    return self:GetActivitySingleData().param[index]
end

return OBTSerialConsumeModel
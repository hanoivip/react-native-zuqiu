local ActivityModel = require("ui.models.activity.ActivityModel")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")

local TimeLimitedLeaugeLetterModel = class(ActivityModel, "TimeLimitedLeaugeLetterModel")

function TimeLimitedLeaugeLetterModel:InitWithProtocol()
end

function TimeLimitedLeaugeLetterModel:GetBigCardModel()
    if not self.bigCardModel then
        local cardId = self:GetCardIdByIndex(1)
        local playerCardStaticModel = StaticCardModel.new(cardId)
        self.bigCardModel = playerCardStaticModel
    end
    return self.bigCardModel
end

function TimeLimitedLeaugeLetterModel:GetScrollData()
    local scrollData = {}
    local questConditionDecList = self:GetQuestConditionDecListByIndex(1)
    local questConditionParamList = self:GetQuestConditionParamListByIndex(1)
    for id, state in pairs(questConditionParamList) do
        local conditionData = {}
        conditionData.id = id
        conditionData.state = state
        conditionData.desc = questConditionDecList[id]
        table.insert(scrollData, conditionData)
    end
    return scrollData
end

function TimeLimitedLeaugeLetterModel:GetProgress()
    local questConditionParamList = self:GetQuestConditionParamListByIndex(1)
    local sum = table.nums(questConditionParamList)
    local finishNum = 0
    for k, v in pairs(questConditionParamList) do
        if v == 1 then
            finishNum = finishNum + 1
        end
    end
    return finishNum / sum
end

function TimeLimitedLeaugeLetterModel:UpdateDataAfterReceive(data)
    self:GetActivitySingleData().list[1].status = data.status
end

function TimeLimitedLeaugeLetterModel:GetStatus()
    return self:GetRewardStatesByIndex(1)
end

function TimeLimitedLeaugeLetterModel:GetLetterList()
    return self:GetActivitySingleData().list
end

function TimeLimitedLeaugeLetterModel:GetSubId()
    return self:GetSubIdByIndex(1)
end

function TimeLimitedLeaugeLetterModel:GetQuestConditionDecListByIndex(index)
    return self:GetActivitySingleData().list[index].conditionDesc
end

function TimeLimitedLeaugeLetterModel:GetQuestConditionParamListByIndex(index)
    return self:GetActivitySingleData().list[index].param
end

function TimeLimitedLeaugeLetterModel:GetBeginTime()
    return self:GetActivitySingleData().beginTime
end

function TimeLimitedLeaugeLetterModel:GetEndTime()
    return self:GetActivitySingleData().endTime
end

function TimeLimitedLeaugeLetterModel:GetCardIdByIndex(index)
    return self:GetActivitySingleData().list[index].contents.card[1].id
end

function TimeLimitedLeaugeLetterModel:GetActivityType()
    return self:GetActivitySingleData().type
end

function TimeLimitedLeaugeLetterModel:GetSubIdByIndex(index)
    return self:GetActivitySingleData().list[index].subID 
end

function TimeLimitedLeaugeLetterModel:GetRewardStatesByIndex(index)
    return self:GetActivitySingleData().list[index].status
end

function TimeLimitedLeaugeLetterModel:GetShowType()
    return self:GetActivitySingleData().showType
end

function TimeLimitedLeaugeLetterModel:GetCardInfoByIndex(index)
    return self:GetActivitySingleData().list[index].contents
end

function TimeLimitedLeaugeLetterModel:GetQuestConditionDecCountByIndex(index)
    local count = 0  
    for k,v in pairs(self:GetActivitySingleData().list[index].conditionDesc) do  
        count = count + 1  
    end  
    return count
end

function TimeLimitedLeaugeLetterModel:GetFinishedCountByIndex(index)
    return self:GetActivitySingleData().list[index].value
end

return TimeLimitedLeaugeLetterModel
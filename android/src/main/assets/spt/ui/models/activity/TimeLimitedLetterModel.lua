local ActivityModel = require("ui.models.activity.ActivityModel")
local ReqEventModel = require("ui.models.event.ReqEventModel")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")

local TimeLimitedLetterModel = class(ActivityModel)
local DefaultTag = 1

function TimeLimitedLetterModel:InitWithProtocol()
    self:RefreshTabData()
end

function TimeLimitedLetterModel:RefreshTabData()
    local allData = self:GetActivitySingleData()
    local activityFirstRead = -2
    local activity = ReqEventModel.GetInfo("activity")
    local activityType = self:GetActivityType()
    local activityData = activity[activityType]

    for i,v in ipairs(allData.allActivity) do
        v.tabTag = i
        v.title = lang.transstr("playerMail_title")
        v.status = -1
        for index,value in ipairs(v.list) do
            if value.status == 0 then
                v.status = 0
                break
            end
        end
        if activityData then
            if type(activityData) == "table" then
                v.isFirstRead = tonumber(activityData[tostring(v.id)]) == activityFirstRead
            else
                v.isFirstRead = tonumber(activityData) == activityFirstRead
            end
        else
            v.isFirstRead = false
        end
    end
end

function TimeLimitedLetterModel:GetCardNameByIndex(index)
    local cardId = self:GetCurrentTagData().list[index].contents.card[1].id 
    local playerCardStaticModel = StaticCardModel.new(cardId)
    return playerCardStaticModel:GetName()
end

function TimeLimitedLetterModel:GetCardIdByIndex(index)
    return self:GetCurrentTagData().list[index].contents.card[1].id 
end

function TimeLimitedLetterModel:GetBeginTime()
    return self:GetCurrentTagData().beginTime
end

function TimeLimitedLetterModel:GetEndTime()
    return self:GetCurrentTagData().endTime
end

function TimeLimitedLetterModel:GetShowType()
    return self:GetCurrentTagData().showType
end

function TimeLimitedLetterModel:GetLetterList()
    return self:GetCurrentTagData().list
end

function TimeLimitedLetterModel:GetCardInfoByIndex(index)
    return self:GetCurrentTagData().list[index].contents
end

function TimeLimitedLetterModel:GetCardConditionListByIndex(index)
    return self:GetCurrentTagData().list[index].condition
end

function TimeLimitedLetterModel:GetConditionDescByIndex(index)
    return self:GetCurrentTagData().list[index].conditionDesc 
end

function TimeLimitedLetterModel:GetSubIdByIndex(index)
    return self:GetCurrentTagData().list[index].subID 
end

function TimeLimitedLetterModel:GetQuestConditionDecListByIndex(index)
    return self:GetCurrentTagData().list[index].conditionDesc
end

function TimeLimitedLetterModel:GetQuestConditionParamListByIndex(index)
    return self:GetCurrentTagData().list[index].param
end

function TimeLimitedLetterModel:GetQuestConditionDecCountByIndex(index)
    local count = 0  
    for k,v in pairs(self:GetCurrentTagData().list[index].conditionDesc) do  
        count = count + 1  
    end  
    return count
end

function TimeLimitedLetterModel:GetRewardStatesByIndex(index)
    return self:GetCurrentTagData().list[index].status
end

function TimeLimitedLetterModel:SetRewardStatesByIndex(index, value)
    self:GetCurrentTagData().list[index].status = value
    self:RefreshTabData()
end

function TimeLimitedLetterModel:GetFinishedCountByIndex(index)
    return self:GetCurrentTagData().list[index].value
end

function TimeLimitedLetterModel:GetActivityType()
    return self:GetCurrentTagData().type    
end

function TimeLimitedLetterModel:SetSelectedTabTag(tag)
    if tag then
        self.currTag = tag
    end
end

function TimeLimitedLetterModel:GetSelectedTabTag()
    return self.currTag or DefaultTag
end

function TimeLimitedLetterModel:GetCurrentTagData()
    local tag = self:GetSelectedTabTag()
    local allData = self:GetActivitySingleData().allActivity or {}
    return allData[tag] or allData[DefaultTag] or self:GetActivitySingleData()
end

function TimeLimitedLetterModel:GetTabDataList()
    local allData = self:GetActivitySingleData()
    return allData.allActivity
end

function TimeLimitedLetterModel:GetActID()
    local data = self:GetCurrentTagData()
    return data.id
end

function TimeLimitedLetterModel:SetActFirstRead(isFirstRead)
    local tabTag = self:GetSelectedTabTag()
    local allData = self:GetActivitySingleData().allActivity or {}
    allData[tabTag].isFirstRead = isFirstRead
end

function TimeLimitedLetterModel:IsActFirstRead()
    local tabTag = self:GetSelectedTabTag()
    local allData = self:GetActivitySingleData().allActivity or {}
    return allData[tabTag].isFirstRead
end

return TimeLimitedLetterModel

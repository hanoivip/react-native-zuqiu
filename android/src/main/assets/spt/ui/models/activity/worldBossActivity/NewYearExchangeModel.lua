local ActivityModel = require("ui.models.activity.ActivityModel")
local CurrencyType = require("ui.models.itemList.CurrencyType")
local NewYearExchangeModel = class(ActivityModel)

function NewYearExchangeModel:InitWithProtocol()
end

function NewYearExchangeModel:InitResponseData(data)
    self.responseData = data
end

function NewYearExchangeModel:GetContents()
    return self.responseData.exchange
end

function NewYearExchangeModel:GetActivityDesc()
    return self:GetActivitySingleData().desc
end

function NewYearExchangeModel:GetID()
    return self:GetActivitySingleData().ID
end

function NewYearExchangeModel:GetEndTime()
    return self:GetActivitySingleData().endTime
end

function NewYearExchangeModel:GetBeginTime()
    return self:GetActivitySingleData().beginTime
end

function NewYearExchangeModel:GetName()
    return self:GetActivitySingleData().name
end

function NewYearExchangeModel:GetExchangeList()
    return self.responseData.exchangeItem
end

return NewYearExchangeModel
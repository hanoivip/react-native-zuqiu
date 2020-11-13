
local Model = require("ui.models.Model")

local CareerRaceModel = class(Model, "CareerRaceModel")

function CareerRaceModel:ctor(data, periodID)
    CareerRaceModel.super.ctor(self)

    self.data = data
    self.periodID = periodID or "1"
    self.isActivityEnd = false
end

function CareerRaceModel:GetRewardList()
    if not self.data.list then return {} end
    return self.data.list
end

function CareerRaceModel:GetActivityType()
    return self.data.type
end

function CareerRaceModel:GetPeriodID()
    return self.periodID
end

function CareerRaceModel:SetRewardStatusByCondition(condition, status)
    local rewardList = self:GetRewardList()
    for k, v in pairs(rewardList) do
        if v.condition == condition then
            v.status = status
        end
    end
end

function CareerRaceModel:GetResidualTime()
    local activityEndTime = self.data.endTime
    local serverTime = self:CalculateServerTime()
    local residualTime = activityEndTime - serverTime
    return residualTime
end

function CareerRaceModel:CalculateServerTime()
    local deltaTime = cache.getServerDeltaTimeValue()
    local clientTime = os.time()
    local serverTime = deltaTime + clientTime
    return serverTime
end

function CareerRaceModel:GetIsActivityEnd()
    return self.isActivityEnd
end

function CareerRaceModel:SetIsActivityEnd(boolFlag)
    self.isActivityEnd = boolFlag
end

function CareerRaceModel:ConvertSecondsToDayAndHour(seconds)
    local seconds = tonumber(seconds)
    if seconds <= 0 then return lang.transstr("time_limit_growthPlan_desc5") end

    local str = lang.transstr("residual_time")
    local timeString, timeStrDay = string.convertSecondToTimeHighlightDay(seconds)
    if timeStrDay then
        str = str .. timeStrDay
    end
    if timeString then
        if string.len(timeString) < 8 then
            timeString = "00:" .. timeString
        end
        str = str .. timeString
    end
    return str
end

return CareerRaceModel
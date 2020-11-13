local ActivityModel = require("ui.models.activity.ActivityModel")
local LoginModel = require("ui.models.login.LoginModel")
local GrowthPlanLoginModel = class(ActivityModel)

function GrowthPlanLoginModel:ctor(data)
    GrowthPlanLoginModel.super.ctor(self, data)

    self.rewardList = {}
    self.seventhRewardData = {}
    self.rewardCardID = ""
end

function GrowthPlanLoginModel:InitWithProtocol()
    local remainTime = self:GetRemainTime()
    local serverTime = self:GetServerTime()
    self.activityEndTime = serverTime + remainTime
end

function GrowthPlanLoginModel:DataListPretreatment()
    local singleData = self:GetActivitySingleData()
    if not singleData then 
        dump("error: singleData is null!!!!")
        return 
    end
    local rewardList = clone(singleData.list or {})
    local seven = 7
    local seventhIndex = nil
    for k, v in pairs(rewardList) do
        if v.condition == seven then
            self.seventhRewardData = v
            seventhIndex = k
        end
    end
    if seventhIndex then rewardList[seventhIndex] = nil end

    if self.seventhRewardData.contents.card then
        self.rewardCardID = self.seventhRewardData.contents.card[1].id
        self.seventhRewardData.contents.card = nil
    end
    self.rewardList = rewardList
end

function GrowthPlanLoginModel:IsActivityEnd()
    local residualTime = self:GetResidualTime()
    return residualTime <= 0
end

--- 获取活动说明
function GrowthPlanLoginModel:GetDesc()
    local singleData = self:GetActivitySingleData()
    return singleData.desc
end

--- 获取活动开始时间
function GrowthPlanLoginModel:GetStartTime()
    local singleData = self:GetActivitySingleData()
    return singleData.beginTime
end

--- 获取活动结束时间
function GrowthPlanLoginModel:GetActivityEndTime()
    local singleData = self:GetActivitySingleData()
    return singleData.activityEndTime
end

--- 获取活动下架时间
function GrowthPlanLoginModel:GetEndTime()
    local singleData = self:GetActivitySingleData()
    return singleData.endTime
end

function GrowthPlanLoginModel:GetRewardByRankList()
    self.rewardByRankList = self.data.rankData
    return self.rewardByRankList or {}
end

--- 获取总购买次数
function GrowthPlanLoginModel:GetTotalBuyTimes()
    local singleData = self:GetActivitySingleData()
    return singleData.times
end

--- 获取剩余购买次数
function GrowthPlanLoginModel:GetLastBuyTimes()
    if not self:IsLeagueUnlock() then
        return self:GetTotalBuyTimes()
    else
        local singleData = self:GetActivitySingleData()
        return singleData.base.l_buy
    end
end

--- 联赛是否已解锁
function GrowthPlanLoginModel:IsLeagueUnlock()
    local singleData = self:GetActivitySingleData()
    return type(singleData.base) == "table" and next(singleData.base) ~= nil
end

--- 获取联赛解锁等级
function GrowthPlanLoginModel:GetLeagueUnlockLevel()
    local LevelLimit = require("data.LevelLimit")
    return LevelLimit.league.playerLevel
end

function GrowthPlanLoginModel:GetRewardCardID()
    return self.rewardCardID
end

function GrowthPlanLoginModel:GetRewardList()
    return self.rewardList
end

function GrowthPlanLoginModel:GetSeventhRewardData()
    return self.seventhRewardData
end

function GrowthPlanLoginModel:GetPayType()
    return self.rewardList[1].currencyType
end

function GrowthPlanLoginModel:GetBuyPrice()
    return self.rewardList[1].diamond
end

function GrowthPlanLoginModel:GetActivityID()
    local singleData = self:GetActivitySingleData()
    return singleData.id
end

function GrowthPlanLoginModel:GetActivityType()
    local singleData = self:GetActivitySingleData()
    return singleData.type
end

function GrowthPlanLoginModel:GetIsBuy()
    local singleData = self:GetActivitySingleData()
    return tobool(singleData.isBuy)
end

function GrowthPlanLoginModel:SetIsBuy(isBuy)
    local singleData = self:GetActivitySingleData()
    singleData.isBuy = isBuy
end

function GrowthPlanLoginModel:SetRewardStatusByCondition(condition, status)
    local singleData = self:GetActivitySingleData()
    singleData.list[tonumber(condition)].status = status
    self:DataListPretreatment()
end

function GrowthPlanLoginModel:GetRemainTime()
    local isBuy = self:GetIsBuy()
    if not isBuy then
        return self:GetActivitySingleData().remainTime
    else
        return self:GetActivitySingleData().showRemainTime
    end
end

function GrowthPlanLoginModel:GetServerTime()
    return self:GetActivitySingleData().serverTime
end

function GrowthPlanLoginModel:GetResidualTime()
    if not self.activityEndTime then
        return self:GetRemainTime()
    end
    local serverTime = self:CalculateServerTime()
    local residualTime = self.activityEndTime - serverTime
    return residualTime
end

function GrowthPlanLoginModel:CalculateServerTime()
    local deltaTime = cache.getServerDeltaTimeValue()
    local clientTime = os.time()
    local serverTime = deltaTime + clientTime
    return serverTime
end

function GrowthPlanLoginModel:ConvertSecondsToDayAndHour(seconds)
    local day = 0
    local hour = 0
    local seconds = tonumber(seconds)
    if seconds <= 0 then return lang.transstr("time_limit_growthPlan_desc5") end

    local str = lang.transstr("residual_time")
    day = math.floor(seconds / 86400)
    if day > 0 then
        str = str .. tostring(day) .. lang.transstr("day")
    end 
    hour = math.ceil((seconds % 86400) / 3600)
    if hour > 0 then
        str = str .. tostring(hour) .. lang.transstr("hour")
    end
    return str
end

function GrowthPlanLoginModel:GetResidualTimeStr(seconds)
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

return GrowthPlanLoginModel

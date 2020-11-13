local ActivityModel = require("ui.models.activity.ActivityModel")
local CareerDoubleModel = class(ActivityModel)

function CareerDoubleModel:ctor(data)
    CareerDoubleModel.super.ctor(self, data)
end

function CareerDoubleModel:InitWithProtocol()

end

--- 获取活动说明
function CareerDoubleModel:GetDesc()
    local singleData = self:GetActivitySingleData()
    return singleData.desc
end

--- 获取活动开始时间
function CareerDoubleModel:GetStartTime()
    local singleData = self:GetActivitySingleData()
    return singleData.beginTime
end

--- 获取活动结束时间
function CareerDoubleModel:GetEndTime()
    local singleData = self:GetActivitySingleData()
    return singleData.endTime
end

--- 获取总购买次数
function CareerDoubleModel:GetTotalBuyTimes()
    local singleData = self:GetActivitySingleData()
    return singleData.times
end

--- 获取剩余购买次数
function CareerDoubleModel:GetLastBuyTimes()
    if not self:IsLeagueUnlock() then
        return self:GetTotalBuyTimes()
    else
        local singleData = self:GetActivitySingleData()
        return singleData.base.l_buy
    end
end

--- 联赛是否已解锁
function CareerDoubleModel:IsLeagueUnlock()
    local singleData = self:GetActivitySingleData()
    return type(singleData.base) == "table" and next(singleData.base) ~= nil
end

--- 获取联赛解锁等级
function CareerDoubleModel:GetLeagueUnlockLevel()
    local LevelLimit = require("data.LevelLimit")
    return LevelLimit.league.playerLevel
end

return CareerDoubleModel

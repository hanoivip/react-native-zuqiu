local ActivityModel = require("ui.models.activity.ActivityModel")
local LoginModel = require("ui.models.login.LoginModel")
local PasterSplitModel = class(ActivityModel)

local server = "server"
local client = "client"
function PasterSplitModel:InitWithProtocol()
    --默认从服务器获得数据
    self.dataSource = server

    self.data = self:GetActivitySingleData()
    if not self.data then self.data = {} end
    self.TLPRAR = self.data.cfgRecover or {}
    if type(self.TLPRAR) ~= "table" or not next (self.TLPRAR) then
        dump("warning:   server failed to send data, trying to read local json next!!!")
        self.dataSource = client
        self.staticJsonPath = "data.TimeLimitPasterRecover_recover_" .. self:GetUserPlatform()
        self.TLPRAR = require(self.staticJsonPath) or {}
    end
    self.currentPhase = tostring(self:GetCurrentPhase())
    self.residualTime = self:GetPermittedTime()
end

function PasterSplitModel:GetUserPlatform()
    local playerInfo = cache.getPlayerInfo()
    return playerInfo.platform or "ios"
end

function PasterSplitModel:GetCurrentPhase()
    return self.data.ID
end

function PasterSplitModel:GetSplitPriceList()
    if self.dataSource == server then
        return self.TLPRAR or {}
    else
        return self.TLPRAR[tostring(self.currentPhase)] or {}
    end
end

function PasterSplitModel:GetPermittedTime()
    local dailyCount = self.data.dailyCount or 0
    local splitTime = 0
    if self.data.p_data then
        splitTime = self.data.p_data.value
    else
        splitTime = 0
    end
    self.residualTime = tonumber(dailyCount) - tonumber(splitTime)
    return self.residualTime
end

function PasterSplitModel:GetTotalTimePerDay()
    return self.data.dailyCount or 0
end

function PasterSplitModel:ResetPermittedTime(p_data)
    local totalTimePerDay = tonumber(self:GetTotalTimePerDay())
    local value = 0
    if not p_data or type(p_data) ~= "table" then
        dump("server data error !!!")
    else
        value = p_data.value and p_data.value or 0
    end
    
    self.residualTime = totalTimePerDay - tonumber(value)
end

function PasterSplitModel:GetResidualTime()
    return self.residualTime
end

function PasterSplitModel:GetActivityEndTime()
    local singleData = self:GetActivitySingleData()
    return singleData.activityEndTime
end

function PasterSplitModel:GetActivityState()
    local deltaTimeValue = cache.getServerDeltaTimeValue()
    local serverTimeNow = tonumber(os.time()) + tonumber(deltaTimeValue)
    local endTime = tonumber(self:GetEndTime())
    local activityEndTime = tonumber(self:GetActivityEndTime())
    local startTime = tonumber(self:GetStartTime())

    if serverTimeNow > endTime or serverTimeNow < startTime then
        assert("server error!!!!")
        return false
    end
    return serverTimeNow < activityEndTime and serverTimeNow > startTime
end

function PasterSplitModel:GetStaticTableMaxId()
    assert(type(self.TLPRAR) == "table")
    local maxId = 0
    for k, v in pairs(self.TLPRAR) do
        if tonumber(k) > maxId then
            maxId = tonumber(k)
        end
    end
    return maxId
end

function PasterSplitModel:GetStaticTableName()
    return "TimeLimitPasterRecover_recover_"..self:GetUserPlatform()
end

function PasterSplitModel:GetStaticTableData()
    return self.TLPRAR or {}
end

--- 获取活动说明
function PasterSplitModel:GetDesc()
    local singleData = self:GetActivitySingleData()
    return singleData.desc
end

--- 获取活动开始时间
function PasterSplitModel:GetStartTime()
    local singleData = self:GetActivitySingleData()
    return singleData.beginTime
end

--- 获取活动结束时间
function PasterSplitModel:GetEndTime()
    local singleData = self:GetActivitySingleData()
    return singleData.endTime
end

--- 获取总购买次数
function PasterSplitModel:GetTotalBuyTimes()
    local singleData = self:GetActivitySingleData()
    return singleData.times
end

--- 获取剩余购买次数
function PasterSplitModel:GetLastBuyTimes()
    if not self:IsLeagueUnlock() then
        return self:GetTotalBuyTimes()
    else
        local singleData = self:GetActivitySingleData()
        return singleData.base.l_buy
    end
end

--- 联赛是否已解锁
function PasterSplitModel:IsLeagueUnlock()
    local singleData = self:GetActivitySingleData()
    return type(singleData.base) == "table" and next(singleData.base) ~= nil
end

--- 获取联赛解锁等级
function PasterSplitModel:GetLeagueUnlockLevel()
    local LevelLimit = require("data.LevelLimit")
    return LevelLimit.league.playerLevel
end

return PasterSplitModel

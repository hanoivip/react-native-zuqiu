local ActivityModel = require("ui.models.activity.ActivityModel")
local LoginModel = require("ui.models.login.LoginModel")
local RecruitRewardModel = class(ActivityModel)

function RecruitRewardModel:ctor(data)
    RecruitRewardModel.super.ctor(self, data)
end

local server = "server"
local client = "client"
function RecruitRewardModel:InitWithProtocol()
    --默认从服务器获得数据
    self.dataSource = server

    self.data = self:GetActivitySingleData()
    if not self.data then self.data = {} end
    self.ProgressRewardList = self.data.cfgCount or {}
    if type(self.ProgressRewardList) ~= "table" or not next (self.ProgressRewardList) then
        dump("warning:   server failed to send data, trying to read local json next!!!")
        self.dataSource = client
        self.staticJsonPath = "data.TimeLimitGacha_gacha_count_" .. self:GetUserPlatform()
        self.ProgressRewardList = require(self.staticJsonPath) or {}
    end
    self.currentPhase = tostring(self:GetCurrentPhase())
    local activityInfo = {}
    activityInfo.isActive = self:GetActivityState()
    activityInfo.activityEndTime = self:GetActivityEndTime()
    cache.setRecruitRewardPhase(activityInfo)
end

function RecruitRewardModel:GetUserPlatform()
    local playerInfo = cache.getPlayerInfo()
    return playerInfo.platform or "ios"
end

function RecruitRewardModel:GetCurrentPhase()
    return self.data.ID or "1"
end

function RecruitRewardModel:GetMyScore()
    if self.data.p_data then
        return self.data.p_data.score or 0
    else
        return 0
    end
end

function RecruitRewardModel:GetSpecialGacha()
    return self.data.specialGacha or {}
end

function RecruitRewardModel:GetRecruitTimeRewardState()
    if self.data.p_data then
        return self.data.p_data.bonus or {}
    else
        return {}
    end
end

function RecruitRewardModel:GetActivityState()
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

function RecruitRewardModel:GetRecruitTime()
    if not self.data.p_data then return 0 end
    return self.data.p_data.value or 0
end

function RecruitRewardModel:SetRewardCollectedByNum(num)
    self.data.p_data.bonus[tostring(num)] = true
end

--- 获取活动说明
function RecruitRewardModel:GetDesc()
    local singleData = self:GetActivitySingleData()
    return singleData.desc
end

--- 获取活动开始时间
function RecruitRewardModel:GetStartTime()
    local singleData = self:GetActivitySingleData()
    return singleData.beginTime
end

--- 获取活动结束时间
function RecruitRewardModel:GetActivityEndTime()
    local singleData = self:GetActivitySingleData()
    return singleData.activityEndTime
end

--- 获取活动下架时间
function RecruitRewardModel:GetEndTime()
    local singleData = self:GetActivitySingleData()
    return singleData.endTime
end

function RecruitRewardModel:GetRewardByRankList()
    self.rewardByRankList = self.data.rankData
    return self.rewardByRankList or {}
end

--- 获取总购买次数
function RecruitRewardModel:GetTotalBuyTimes()
    local singleData = self:GetActivitySingleData()
    return singleData.times
end

--- 获取剩余购买次数
function RecruitRewardModel:GetLastBuyTimes()
    if not self:IsLeagueUnlock() then
        return self:GetTotalBuyTimes()
    else
        local singleData = self:GetActivitySingleData()
        return singleData.base.l_buy
    end
end

--- 联赛是否已解锁
function RecruitRewardModel:IsLeagueUnlock()
    local singleData = self:GetActivitySingleData()
    return type(singleData.base) == "table" and next(singleData.base) ~= nil
end

--- 获取联赛解锁等级
function RecruitRewardModel:GetLeagueUnlockLevel()
    local LevelLimit = require("data.LevelLimit")
    return LevelLimit.league.playerLevel
end

function RecruitRewardModel:GetCurrentProgressNumber()
    return self.currentProgressNumber
end

function RecruitRewardModel:GetStaticTableData()
    return self.ProgressRewardList
end

function RecruitRewardModel:GetStaticTableName()
    return "TimeLimitGacha_gacha_count_"..self:GetUserPlatform()
end

function RecruitRewardModel:GetStaticTableMaxId()
    assert(type(self.ProgressRewardList) == "table")
    local maxId = 0
    for k, v in pairs(self.ProgressRewardList) do
        if tonumber(k) > maxId then
            maxId = tonumber(k)
        end
    end
    return maxId
end

function RecruitRewardModel:GetProgressDataList() --modify
    local progressDataList = self.ProgressRewardList
    if self.dataSource == client then
        progressDataList = self.ProgressRewardList[self.currentPhase] or {}
    end
    
    local pdl = {}
    for k, v in pairs(progressDataList) do
        v.count = tonumber(k)
        table.insert(pdl, v)
    end
    table.sort(pdl, function(a, b) 
        return a.count < b.count
    end)
    local progressList = {}
    for k, v in pairs(pdl) do
        if k ~= #pdl then 
            v.nextCount  = pdl[k + 1].count
        else
            v.nextCount = 0
        end
        table.insert(progressList, v)
    end
    return progressList
end

return RecruitRewardModel

local ActivityModel = require("ui.models.activity.ActivityModel")
local PlayerTeamsModel = require("ui.models.PlayerTeamsModel")
local PowerRankModel = class(ActivityModel)

PowerRankModel.RankState = {
    RANKING = 1, -- 排名中
    LOCK = 2, -- 结算中
    REWARD = 3, -- 领取奖励中
}

function PowerRankModel:InitWithProtocol()
    self.singleData = self:GetActivitySingleData()
end

-- 刷新玩家排行榜数据
function PowerRankModel:SetRankData(rankData)
    if rankData and next(rankData) then
        self.rankData = rankData
        if next(rankData.activityData) then
            self.singleData = rankData.activityData["1"]
        else
            self.singleData.showRemainTime = 0
        end
    end
end

-- 获取玩家排行榜数据
function PowerRankModel:GetRankData()
    return self.rankData.list
end

-- 获取自己排名
function PowerRankModel:GetSelfRankIndex()
    return self.rankData.rank
end

-- 设置已领奖状态
function PowerRankModel:SetGainState(state)
    self.rankData.canGain = state
end

-- 获取自己的排名数据
function PowerRankModel:GetSelfRankData()
    local selfRank = tostring(self:GetSelfRankIndex())
    return self.rankData.list[selfRank]
end

-- 奖励是否已领取 -1:不可领 0 :可领 1：已领取
function PowerRankModel:GetRewardState()
    if self.rankData.canGain then
        selfRankData = self:GetSelfRankData()
        if selfRankData then
            return 0
        else
            return -1
        end
    else
        return 1
    end
end

-- 获取排行榜数据
function PowerRankModel:GetRankListData()
    local rankState = self:GetTimeStateAndValue()
    rankDataList = {}
    if rankState == PowerRankModel.RankState.LOCK then
        local configListData = self.singleData.list
        for i,v in ipairs(configListData) do
            local rankHigh = tonumber(v.rankHigh)
            local rankLow = tonumber(v.rankLow)
            for i = rankHigh, rankLow do
                local tempData = {}
                tempData.contents = v.contents
                tempData.rank = i
                tempData.state = rankState
                table.insert(rankDataList, tempData)
            end
        end
    else
        local rankData = self:GetRankData()
        for i,v in pairs(rankData) do
            local tempData = {}
            local rank = v.rank
            tempData = v
            local contents = self:GetRewardByRankIndex(rank)
            tempData.contents = contents
            tempData.state = rankState
            table.insert(rankDataList, tempData)
        end
    end
    table.sort(rankDataList, function(a, b) return a.rank < b.rank end)
    return rankDataList
end

function PowerRankModel:GetActivityDesc()
    local state = self:GetTimeStateAndValue()
    if state == PowerRankModel.RankState.RANKING or state == PowerRankModel.RankState.LOCK then
        return lang.trans("power_rank_desc")
    else
        return lang.trans("power_rank_end_desc")
    end
end

function PowerRankModel:GetRewardByRankIndex(rankIndex)
    for i,v in ipairs(self.singleData.list) do
        local rankHigh = tonumber(v.rankHigh)
        local rankLow = tonumber(v.rankLow)
        if rankIndex >= rankHigh and rankIndex <= rankLow then
            return v.contents
        end
    end
end

function PowerRankModel:GetTimeStateAndValue()
    local endTime = self.singleData.endTime
    local serverTime = self.singleData.serverTime
    local remainTime = self.singleData.remainTime
    local showRemainTime = self.singleData.showRemainTime
    if serverTime < endTime and remainTime > 0 then  --计算排行的活动时间
        return PowerRankModel.RankState.RANKING, remainTime + 1
    elseif (endTime <= serverTime) and  (serverTime < endTime + 1800) then  --这是结算时间30分不允许玩家有操作
        return PowerRankModel.RankState.LOCK, endTime + 1810 - serverTime
    elseif (endTime + 1800 <= serverTime) and showRemainTime > 0 then  --玩家可以领取奖励
        return PowerRankModel.RankState.REWARD, showRemainTime + 1
    end
end

-- 自动转换为结算中的状态
function PowerRankModel:SetRemainTime(time)
    self.singleData.showRemainTime = self.singleData.showRemainTime - self.singleData.remainTime
    self.singleData.remainTime = tonumber(time)
    self.singleData.serverTime = self.singleData.endTime + 500
end

function PowerRankModel:GetSelfPower()
    local playerTeamsModel = PlayerTeamsModel.new()
    local power = playerTeamsModel:GetTotalPower()
    return power
end

return PowerRankModel
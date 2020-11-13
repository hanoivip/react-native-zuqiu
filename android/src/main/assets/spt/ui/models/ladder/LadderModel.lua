local Model = require("ui.models.Model")
local LadderDailyReward = require("data.LadderDailyReward")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local ItemContent = require("data.ItemContent")
local Item = require("data.Item")

local LadderModel = class(Model)

function LadderModel:ctor()
    LadderModel.super.ctor(self)
end

function LadderModel:InitWithProtocol(data)
    self.cacheData = clone(data)
    self:SetChallengeOpponents(data.rivals)
    self.cacheData.isCdDoing = self:GetCd() > 0 and true or false
end

-- 初始化排行榜的赛季列表
function LadderModel:InitRankSeasonList(seasonList)
    self.cacheData.rankSeasonList = {
        {
            name = lang.trans("ladder_realTimeRank"),
            type = "current",
            isSelect = true
        },
        {
            name = lang.trans("ladder_curSeasonRank"),
            type = "season",
            isSelect = false
        }
    }
    table.sort(seasonList, function(a, b)
        if a > b then
            return true
        else
            return false
        end
    end)
    for i, seasonName in ipairs(seasonList) do
        local seasonTable = {}
        seasonTable.name = lang.trans("ladder_oldSeasonRank", tostring(seasonName))
        seasonTable.type = tostring(seasonName)
        seasonTable.isSelect = false
        table.insert(self.cacheData.rankSeasonList, seasonTable)
    end
end

-- 获取排行榜的赛季列表
function LadderModel:GetRankSeasonList()
    return self.cacheData.rankSeasonList
end

-- 获取排行榜当前选中赛季
function LadderModel:GetCurRankSeason()
    local seasonList = self:GetRankSeasonList()
    for i, seasonData in ipairs(seasonList) do
        if seasonData.isSelect then
            return seasonData
        end
    end
    return nil
end

-- 初始化当前排行榜数据
function LadderModel:InitCurRankDataList(rankDataList)
    self.cacheData.curRankDataList = {}
    for id, data in pairs(rankDataList) do
        local rankData = {}
        rankData.id = id
        rankData.rank = data.rank
        rankData.name = data.name
        rankData.lvl = data.lvl
        rankData.logo = data.logo
        rankData.seasonScore = data.seasonScore
        rankData.worldTournamentLevel = data.worldTournamentLevel
        table.insert(self.cacheData.curRankDataList, rankData)
    end
    table.sort(self.cacheData.curRankDataList, function(a, b) return a.rank < b.rank end)
end

-- 获取当前排行榜数据
function LadderModel:GetCurRankDataList()
    return self.cacheData.curRankDataList
end

-- 初始化玩家自己的赛季排行信息
function LadderModel:InitMySeasonRankInfo(rankInfo)
    if rankInfo then
        self.cacheData.mySeasonRankInfo = {
            rank = rankInfo.rank,
            name = rankInfo.name,
            level = rankInfo.lvl,
            honorPoint = rankInfo.seasonScore
        }
    else
        self.cacheData.mySeasonRankInfo = nil
    end
end

-- 获取玩家自己的赛季排行信息
function LadderModel:GetMySeasonRankInfo()
    return self.cacheData.mySeasonRankInfo
end

-- 初始化玩家自己的实时排行信息
function LadderModel:InitMyRealTimeRankInfo(rankInfo)
    self.cacheData.myRealTimeRankInfo = {
        rank = rankInfo.rank,
        name = rankInfo.name,
        level = rankInfo.lvl,
        honorPoint = rankInfo.seasonScore
    }
end

-- 获取玩家自己的实时排行信息
function LadderModel:GetMyRealTimeRankInfo()
    return self.cacheData.myRealTimeRankInfo
end

-- 初始化当前赛季的CD
function LadderModel:InitCurSeasonCd(cd)
    self.cacheData.curSeasonCd = cd
end

-- 获取当前赛季的CD
function LadderModel:GetCurSeasonCd()
    return self.cacheData.curSeasonCd
end

-- 获取排名
function LadderModel:GetRank()
    return self.cacheData.rank
end

-- 设置CD
function LadderModel:SetCd(cd)
    self.cacheData.cd = cd
    EventSystem.SendEvent("Ladder_UpdateChallengeCd")
end

-- 获取比赛冷却时间
function LadderModel:GetCd()
    return self.cacheData.cd
end

-- 是否CD中
function LadderModel:IsCdDoing()
    return self:GetCd() > 0 and true or false
end

-- 获取今日剩余挑战次数
function LadderModel:GetRemainChallengeTimes()
    return self.cacheData.matchCount
end

-- 是否今日剩余挑战次数已经用完
function LadderModel:IsRemainChallengeTimesUseUp()
    return self:GetRemainChallengeTimes() == 0
end

-- 获取当前排名可累计奖励
function LadderModel:GetRewardWithCurRank()
    local rank = self:GetRank()
    for k, v in pairs(LadderDailyReward) do
        if rank >= v.rankHigh and rank <= v.rankLow then
            return v.reward
        end
    end
    return 0
end

-- 设置累计可领取奖励
function LadderModel:SetTotalReceiveReward(rewardPoint)
    self.cacheData.rewardPoint = rewardPoint
    EventSystem.SendEvent("Ladder_UpdateTotalReceiveReward")
end

-- 获取累计可领取奖励
function LadderModel:GetTotalReceiveReward()
    return self.cacheData.rewardPoint
end

-- 设置赛季累计奖励
function LadderModel:SetTotalSeasonReward(seasonScore)
    self.cacheData.seasonScore = seasonScore
end

-- 获取赛季累计奖励
function LadderModel:GetTotalSeasonReward()
    return self.cacheData.seasonScore
end

-- 设置玩家身上的天梯荣誉点数
function LadderModel:SetMyCurrentHonorPoint(honorPoint)
    self.cacheData.lp = honorPoint
    PlayerInfoModel.new():SetLadderPoint(honorPoint)
    EventSystem.SendEvent("LadderShopMainCtrl.RefreshMyCurHonorPoint")
end

-- 获取玩家身上的天梯荣誉点数
function LadderModel:GetMyCurrentHonorPoint()
    return self.cacheData.lp or 0
end

-- 获取为获得更多奖励需要提升的名次
function LadderModel:GetRaiseRankForHigherReward()
    local rank = self:GetRank()
    for k, v in pairs(LadderDailyReward) do
        if rank >= v.rankHigh and rank <= v.rankLow then
            return rank - v.rankHigh + 1
        end
    end
    return rank - 1000000
end

-- 获取挑战对手
function LadderModel:GetChallengeOpponents()
    return self.cacheData.rivals
end

-- 设置挑战对手
function LadderModel:SetChallengeOpponents(rivals)
    self.cacheData.rivals = {}
    for pid, info in pairs(rivals) do
        local opponent = {}
        opponent.pid = pid
        opponent.rank = info.rank
        opponent.name = info.name
        opponent.lvl = info.lvl
        opponent.logo = info.logo
        opponent.worldTournamentLevel = info.worldTournamentLevel
        table.insert(self.cacheData.rivals, opponent)
    end
    table.sort(self.cacheData.rivals, function(a, b) return a.rank > b.rank end)
    EventSystem.SendEvent("Ladder_UpdateChallengeOpponents")
end

-- 设置商店自动刷新时间
function LadderModel:SetShopAutoRefreshTime(refreshTime)
    self.cacheData.shopAutoRefreshTime = refreshTime
end

-- 获取商店自动刷新时间
function LadderModel:GetShopAutoRefreshTime()
    return self.cacheData.shopAutoRefreshTime
end

-- 设置商店付费刷新剩余次数
function LadderModel:SetShopCostRefreshRemainTimes(remainTimes)
    self.cacheData.shopCostRefreshRemainTimes = remainTimes
end

-- 获取商店付费刷新剩余次数
function LadderModel:GetShopCostRefreshRemainTimes()
    return self.cacheData.shopCostRefreshRemainTimes
end

-- 设置商店商品列表
function LadderModel:SetShopList(shopList)
    self.cacheData.shopList = clone(shopList)
end

-- 获取商店商品列表
function LadderModel:GetShopList()
    return self.cacheData.shopList
end

-- 刷新商店商品列表
function LadderModel:RefreshShopList(shopList)
    self:SetShopList(shopList)
    EventSystem.SendEvent("LadderShopMainCtrl.RefreshShopItems")
end

-- 初始化对战记录列表
function LadderModel:InitMatchRecordList(matchRecordList)
    self.cacheData.matchRecordList = clone(matchRecordList)
    table.sort(self.cacheData.matchRecordList, function(a, b) return a.c_t > b.c_t end)
end

-- 获取对战记录列表
function LadderModel:GetMatchRecordList()
    return self.cacheData.matchRecordList
end

-- 设置当前赛季名字
function LadderModel:SetCurSeasonName(seasonName)
    self.cacheData.curSeasonName = seasonName
end

-- 获取当前赛季名字
function LadderModel:GetCurSeasonName()
    return lang.trans("ladder_reward_seasonName", self.cacheData.curSeasonName)
end

-- 设置当前赛季奖励前三名的奖励卡牌cid
function LadderModel:SetRewardCardCid(cid)
    self.cacheData.rewardCardCid = cid
end

-- 获取当前赛季奖励前三名的奖励卡牌cid
function LadderModel:GetRewardCardCid()
    return self.cacheData.rewardCardCid
end

-- 设置当前赛季奖励数据
function LadderModel:SetSeasonRewardData(seasonRewardData)
    self.cacheData.seasonRewardData = clone(seasonRewardData)
end

-- 获取当前赛季奖励数据
function LadderModel:GetSeasonRewardData()
    return self.cacheData.seasonRewardData
end

-- 获取当前赛季奖励指定前几位卡牌数据
function LadderModel:GetAppointSeasonRewardByRankIndex(rankIndex)
    local seasonRewardData = self:GetSeasonRewardData()
    local rewardData = seasonRewardData[rankIndex].contents
    local kryTable = {}
    for k, v in pairs(rewardData) do
        table.insert(kryTable, k)
    end
    local randomKey = math.random(1, #kryTable)
    local key = kryTable[randomKey]
    local reward = rewardData[key]
    local randomReward = reward[math.random(1, #reward)]
    local rewardTable = {}
    rewardTable[key] = true
    rewardTable.value = randomReward
    return rewardTable
end

-- 获取我的赛季奖励数据
function LadderModel:GetMySeasonRewardData()
    local seasonRewardDataList = self.cacheData.seasonRewardData
    local myRank = self.cacheData.mySeasonRankInfo.rank
    for i = 1, #seasonRewardDataList do
        if myRank >= seasonRewardDataList[i].rankHigh and myRank <= seasonRewardDataList[i].rankLow then
            return seasonRewardDataList[i]
        end
    end
    return nil
end

-- 获取每日奖励数据
function LadderModel:GetDailyRewardData()
    local dailyRewardDataList = {}
    for index, data in pairs(LadderDailyReward) do
        local dailyRewardData = {}
        dailyRewardData.index = index
        dailyRewardData.rankHigh = data.rankHigh
        dailyRewardData.rankLow = data.rankLow
        dailyRewardData.reward = data.reward
        table.insert(dailyRewardDataList, dailyRewardData)
    end
    table.sort(dailyRewardDataList, function(a, b) return tonumber(a.index) < tonumber(b.index) end)
    return dailyRewardDataList
end

return LadderModel

local EventSystem = require ("EventSystem")
local Model = require("ui.models.Model")
local League = require("data.League")
local LeagueTeam = require("data.LeagueTeam")
local TeamTotal = require("data.TeamTotal")
local InitTeam = require("data.InitTeam")
local SponsorLvl = require("data.SponsorLvl")
local Sponsor = require("data.Sponsor")
local CommonCost = require("data.CommonCost")
local LeagueConstants = require("ui.scene.league.LeagueConstants")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local NPCCard = require("data.NPCCard")
local Card = require("data.Card")

-- 主线副本数据模型
local LeagueInfoModel = class(Model, "LeagueInfoModel")

function LeagueInfoModel:ctor()
    -- 联赛数据
    self.leagueData = nil
    -- 联赛基础信息
    self.baseInfo = nil
    -- 联赛控制器
    self.leagueCtrl = nil
    self.playerInfoModel = nil
    LeagueInfoModel.super.ctor(self)
end

function LeagueInfoModel:Init(data)
    if not data then
        data = cache.getLeagueInfo()
        self.leagueData = data
        if self.leagueData and self.leagueData.enter then
            self.baseInfo = self.leagueData.enter.base
        end
    end
    self.playerInfoModel = PlayerInfoModel.new()
end

function LeagueInfoModel:InitWithIndexProtocol(data)
    self.leagueData = self.leagueData or {}
    self.leagueData.index = data
    self.baseInfo = data.base
    cache.setLeagueInfo(self.leagueData)
end

function LeagueInfoModel:InitWithEnterProtocol(data)
    self.leagueData = self.leagueData or {}
    self.leagueData.enter = data
    self.baseInfo = data.base
    self:InitScoreboard()
    cache.setLeagueInfo(self.leagueData)
end

function LeagueInfoModel:InitWithScheduleProtocol(data)
    self.leagueData = self.leagueData or {}
    self.leagueData.schedule = data
    self.baseInfo = data.base
    self:InitScheduleList()
    cache.setLeagueInfo(self.leagueData)
end

function LeagueInfoModel:InitWithSeasonInfoProtocol(data)
    self.leagueData = self.leagueData or {}
    self.leagueData.report = data
    self.baseInfo = data.base
    cache.setLeagueInfo(self.leagueData)
end

function LeagueInfoModel:InitWithShootboardProtocol(data)
    self.leagueData = self.leagueData or {}
    self.leagueData.shootboard = data
    self:InitShootboard()
    cache.setLeagueInfo(self.leagueData)
end

function LeagueInfoModel:InitWithAssistboardProtocol(data)
    self.leagueData = self.leagueData or {}
    self.leagueData.assistboard = data
    self:InitAssistboard()
    cache.setLeagueInfo(self.leagueData)
end

function LeagueInfoModel:InitWithRankProtocol(data)
    self.leagueData = self.leagueData or {}
    self.leagueData.rank = data
    cache.setLeagueInfo(self.leagueData)
end

function LeagueInfoModel:InitWithSeasonRewardProtocol(data)
    self.leagueData = self.leagueData or {}
    self.leagueData.reward = data
    cache.setLeagueInfo(self.leagueData)
end

--- 初始化赛程列表
function LeagueInfoModel:InitScheduleList()
    local list = self:GetScheduleList()
    for roundIndex, roundData in ipairs(list) do
        for i, matchData in ipairs(roundData) do
            for i = 1, 2 do
                local teamData = matchData["t" .. i]
                if teamData.type == LeagueConstants.TeamType.NPC then
                    teamData.teamId = LeagueTeam[teamData.id].teamID
                    local teamStaticData = TeamTotal[teamData.teamId]
                    teamData.name = teamStaticData.teamName
                    teamData.logo = teamStaticData.robotID and InitTeam[teamStaticData.robotID].logo or teamStaticData.teamLogo
                end
            end
        end
    end
end

--- 初始化积分榜
function LeagueInfoModel:InitScoreboard()
    local scoreboardData = self:GetScoreboard()
    for i, teamData in ipairs(scoreboardData) do
        if teamData.type == LeagueConstants.TeamType.NPC then
            teamData.teamId = LeagueTeam[teamData.id].teamID
            local teamStaticData = TeamTotal[teamData.teamId]
            teamData.name = teamStaticData.teamName
        end
    end
end

--- 初始化射手榜
function LeagueInfoModel:InitShootboard()
    local shootboardData = self:GetShootboard()
    for i, playerData in ipairs(shootboardData) do
        local teamScoreData = self:GetTeamScoreData(playerData.tid)
        playerData.teamName = teamScoreData.name
        local cardStaticData = NPCCard[playerData.cid] or Card[playerData.cid]
        playerData.name = cardStaticData.name2
    end
end

--- 初始化助攻榜
function LeagueInfoModel:InitAssistboard()
    local assistboardData = self:GetAssistboard()
    for i, playerData in ipairs(assistboardData) do
        local teamScoreData = self:GetTeamScoreData(playerData.tid)
        playerData.teamName = teamScoreData.name
        local cardStaticData = NPCCard[playerData.cid] or Card[playerData.cid]
        playerData.name = cardStaticData.name2
    end
end

function LeagueInfoModel:GetNameByID(cid)
    local cardStaticData = NPCCard[cid] or Card[cid]
    return cardStaticData.name2
end

--- 设置基础信息
function LeagueInfoModel:SetBaseInfo(data)
    self.baseInfo = data
end

--- 获取基础信息
-- @return table
function LeagueInfoModel:GetBaseInfo()
    return self.baseInfo
end

--- 更新基础信息
function LeagueInfoModel:UpdateBaseInfo(data)
    for k, v in pairs(data) do
        self.baseInfo[k] = v
    end
end

--- 获取当前赛程
-- @return table
function LeagueInfoModel:GetNowSchedule()
    local scheduleContent = self.leagueData.enter.scheduleContent
    if scheduleContent then
        for i = 1, 2 do
            local teamData = scheduleContent["t" .. i]
            if teamData.type == LeagueConstants.TeamType.NPC then
                teamData.teamId = LeagueTeam[teamData.id].teamID
                local teamStaticData = TeamTotal[teamData.teamId]
                teamData.name = teamStaticData.teamName
                teamData.logo = teamStaticData.robotID and InitTeam[teamStaticData.robotID].logo or teamStaticData.teamLogo
            end
            local scoreData = self:GetTeamScoreData(teamData.id)
            if scoreData then
                teamData.rank = tonumber(scoreData.pos) + 1
                teamData.score = scoreData.score
            end
        end
    end
    return scheduleContent or {}
end

function LeagueInfoModel:HasData()
    return self.leagueData
end

--- 获取积分榜
-- @return table
function LeagueInfoModel:GetScoreboard()
    return self.leagueData.enter.scores.scores
end

--- 获取射手榜
-- @return table
function LeagueInfoModel:GetShootboard()
    return self.leagueData.shootboard
end

--- 获取助攻榜
-- @return table
function LeagueInfoModel:GetAssistboard()
    return self.leagueData.assistboard
end

--- 获取vip奖励次数
function LeagueInfoModel:GetVIPMaxTime()
    local baseInfo = self:GetBaseInfo()
    if not baseInfo then
        return false
    end
    return tonumber(baseInfo.extraMaxCount)
end

-- 获取vip已消耗次数
function LeagueInfoModel:GetVIPCurrTime()
    local baseInfo = self:GetBaseInfo()
    if not baseInfo then
        return false
    end
    return tonumber(baseInfo.extraCnt)
end

-- 获取剩余免费次数
function LeagueInfoModel:GetRemainFreeTime()
    local baseInfo = self:GetBaseInfo()
    if not baseInfo then
        return false
    end
    return tonumber(baseInfo.free)
end

-- 是否还有vip次数
function LeagueInfoModel:IsHasVIPTime()
    return self:GetVIPMaxTime() - self:GetVIPCurrTime()
end

--- 获取总购买次数
-- @return number
function LeagueInfoModel:GetTotalBuyTimes()
    return self:GetHaveBuyTimes() + self:GetLastBuyTimes()
end

--- 获取已购买次数
-- @return number
function LeagueInfoModel:GetHaveBuyTimes()
    local baseInfo = self:GetBaseInfo()
    return baseInfo.buy or 0
end

--- 获取剩余购买次数
-- @return number
function LeagueInfoModel:GetLastBuyTimes()
    local baseInfo = self:GetBaseInfo()
    return baseInfo.l_buy or 0
end

--- 获取购买次数花费的钻石数
-- @return number
function LeagueInfoModel:GetCostNum()
    local baseInfo = self:GetBaseInfo()
    if baseInfo.diamond == nil then
        return 0
    end
    local haveBuyTimes = self:GetHaveBuyTimes()
    local totalBuyTimes = self:GetTotalBuyTimes()
    if haveBuyTimes < totalBuyTimes  then
        return baseInfo.diamond[haveBuyTimes + 1]
    else
        return 0
    end
end

--- 获取队伍积分数据
-- @return table
function LeagueInfoModel:GetTeamScoreData(teamId)
    local scoreboard = self:GetScoreboard()
    for i, scoreData in ipairs(scoreboard) do
        if scoreData.id == teamId then
            return scoreData
        end
    end
end

--- 获取联赛等级
-- @return number
function LeagueInfoModel:GetLeagueLevel()
    local baseInfo = self:GetBaseInfo()
    if not baseInfo then
        return false
    end
    return tonumber(baseInfo.diff)
end

--- 获取联赛排行
-- @return number
function LeagueInfoModel:GetLeagueRanking()
    local baseInfo = self:GetBaseInfo()
    if not baseInfo then
        return false
    end
    return tonumber(baseInfo.leagueRanking)
end

--- 获取排名奖励
-- @return table
function LeagueInfoModel:GetRankReward()
    local leagueLevel = self:GetLeagueLevel()
    local nowLevelLeagueData = League[tostring(leagueLevel)]
    local rankReward = {}
    for i = 1, LeagueConstants.TeamSum do
        table.insert(rankReward, nowLevelLeagueData["rank" .. i .. "Income"])
    end
    return rankReward
end

--- 获取对手列表
-- @return table
function LeagueInfoModel:GetOpponentList()
    local opponentList = self.leagueData.index.opponentList
    for i, teamData in ipairs(opponentList) do
        if teamData.type == LeagueConstants.TeamType.NPC then
            teamData.teamId = LeagueTeam[teamData.id].teamID
            local teamStaticData = TeamTotal[teamData.teamId]
            teamData.name = teamStaticData.teamName
            teamData.logo = teamStaticData.robotID and InitTeam[teamStaticData.robotID].logo or teamStaticData.teamLogo
            teamData.lvl = self.playerInfoModel:GetLevel()
        end
    end
    return opponentList
end

--- 获取赞助商列表
-- @return table
function LeagueInfoModel:GetSponsorList()
    local sponsorList = {}
    local leagueLevel = self:GetLeagueLevel()
    local sponsorTable = SponsorLvl[tostring(leagueLevel)]
    for i = 1, 2 do
        table.insert(sponsorList, sponsorTable[tostring(i)])
    end
    return sponsorList
end

--- 获取当前赞助商的数据
function LeagueInfoModel:GetNowSponsorData()
    local baseInfo = self:GetBaseInfo()
    local sponsorId = baseInfo.sponserID
    return Sponsor[tostring(sponsorId)]
end

--- 设置联赛控制器
-- @param leagueCtrl 联赛控制器
function LeagueInfoModel:SetLeagueCtrl(leagueCtrl)
    self.leagueCtrl = leagueCtrl
end

--- 获取联赛控制器
-- @return table
function LeagueInfoModel:GetLeagueCtrl()
    return self.leagueCtrl
end

--- 获取赞助商Id
-- @return number
function LeagueInfoModel:GetSponsorId()
    local baseInfo = self:GetBaseInfo()
    return baseInfo.sponserID
end

--- 是否已签约赞助商
-- @return boolean
function LeagueInfoModel:IsSignedSponsor()
    local sponsorId = self:GetSponsorId()
    if sponsorId == nil or sponsorId == 0 then
        return false
    else
        return true
    end
end

function LeagueInfoModel:GetPlayerID()
    return self.playerInfoModel:GetID()
end

--- 获得奖励的赞助费
function LeagueInfoModel:GetRewardSponsorshipFee()
    return self.leagueData.enter.sponserMoney or 0
end

--- 获取赛程轮次
-- @return number
function LeagueInfoModel:GetScheduleRound()
    local baseInfo = self:GetBaseInfo()
    return baseInfo.currScheduleIndex + 1
end

--- 获取赛程列表
-- @return table
function LeagueInfoModel:GetScheduleList()
    if self.leagueData.schedule then
        return self.leagueData.schedule.list
    end
end

--- 更新赛程列表
-- @param roundIndex 轮次索引
-- @param roundData 轮次数据
function LeagueInfoModel:UpdateScheduleList(roundIndex, roundData)
    local scheduleList = self:GetScheduleList()
    scheduleList[tonumber(roundIndex)] = roundData
    self:InitScheduleList()
end

--- 获取赛程对应的联赛等级
-- @return number
function LeagueInfoModel:GetScheduleLeagueLevel()
    if self.leagueData.schedule then
        return self.leagueData.schedule.base.diff
    end
end

--- 获取最佳射手的数据
-- @return table
function LeagueInfoModel:GetBestShooterData()
    if self.leagueData.report then
        return self.leagueData.report.shooter[1]
    end
end

--- 获取最佳助攻手的数据
-- @return table
function LeagueInfoModel:GetBestAssisterData()
    if self.leagueData.report then
        return self.leagueData.report.assister[1]
    end
end

function LeagueInfoModel:GetPlayerListInOpponentList()
    local list = {}
    for i, teamData in ipairs(self.leagueData.index.opponentList) do
        if teamData.type == LeagueConstants.TeamType.PLAYER then
            list[teamData.id] = teamData
        end
    end
    local playerID = self.playerInfoModel:GetID()
    local playerTeamLogo = self.playerInfoModel:GetTeamLogo()
    list[playerID] = { logo = playerTeamLogo }
    return list
end

--- 获取赛季奖励最佳射手的数据
-- @return table
function LeagueInfoModel:GetSeasonRewardBestShooterData()
    local shooter = self.leagueData.reward.shooter[1]
    if shooter == nil then
        return shooter
    end
    if shooter.type == LeagueConstants.TeamType.NPC then
        shooter.teamId = LeagueTeam[shooter.tid].teamID
        local teamStaticData = TeamTotal[shooter.teamId]
        shooter.logo = teamStaticData.robotID and InitTeam[teamStaticData.robotID].logo or teamStaticData.teamLogo
        shooter.teamName = teamStaticData.teamName
    else
        local playerList = self:GetPlayerListInOpponentList()
        shooter.logo = playerList[shooter.tid].logo
        shooter.teamName = self.playerInfoModel:GetName()
    end
    local cardStaticData = NPCCard[shooter.cid] or Card[shooter.cid]
    shooter.name = cardStaticData.name2
    return shooter
end

--- 获取赛季奖励最佳助攻手的数据
-- @return table
function LeagueInfoModel:GetSeasonRewardBestAssisterData()
    local assister = self.leagueData.reward.assister[1]
    if assister == nil then
        return assister
    end
    if assister.type == LeagueConstants.TeamType.NPC then
        assister.teamId = LeagueTeam[assister.tid].teamID
        local teamStaticData = TeamTotal[assister.teamId]
        assister.logo = teamStaticData.robotID and InitTeam[teamStaticData.robotID].logo or teamStaticData.teamLogo
        assister.teamName = teamStaticData.teamName
    else
        local playerList = self:GetPlayerListInOpponentList()
        assister.logo = playerList[assister.tid].logo
        assister.teamName = self.playerInfoModel:GetName()
    end
    local cardStaticData = NPCCard[assister.cid] or Card[assister.cid]
    assister.name = cardStaticData.name2
    return assister
end

--- 获取赛季奖励数据
-- @return table
function LeagueInfoModel:GetSeasonReward()
    if self.leagueData.reward then
        return self.leagueData.reward
    end
end

--- 获取主场收入数目
-- @return number
function LeagueInfoModel:GetHomeIncomeNum()
    local leagueLevel = self:GetLeagueLevel()
    return League[tostring(leagueLevel)].homeIncome
end

--- 获取排行榜数据
-- @return table
function LeagueInfoModel:GetRankData()
    if not self.leagueData then
        return false
    end
    return self.leagueData.rank
end

--- 获取当前赛季是否可领奖
function LeagueInfoModel:GetSeasonIsCanAward()
    local baseInfo = self:GetBaseInfo()
    if baseInfo.isFinal == 1 then
        return true
    else
        return false
    end
end

--- 当前赛季是已领奖
function LeagueInfoModel:SetSeasonIsCanAwarded()
    local baseInfo = self:GetBaseInfo()
    baseInfo.isFinal = 0
end

--- 获取当前赛季是否已结束
-- @param boolean
function LeagueInfoModel:GetSeasonIsEnded()
    local baseInfo = self:GetBaseInfo()
    if baseInfo.isFinal == 1 or baseInfo.isFinal == 2 then
        return true
    else
        return false
    end
end

-- 是否开启新赛季 来选择回退步数
function LeagueInfoModel:GetBackStep()
    local isSignedSponsor = self:IsSignedSponsor()
    if isSignedSponsor then
        return 2
    else
        return 3
    end
end

-- 获取当前是否是月卡用户
function LeagueInfoModel:IsMonthCard()
    local monthCard = self.leagueData.enter.monthCard
    return tonumber(monthCard) == 1
end

-- 月卡用户状态改变
function LeagueInfoModel:SetMonthCardState(state)
    if state then
        self.leagueData.enter.monthCard = 1
    else
        self.leagueData.enter.monthCard = 0
    end
end

-- 联赛扫荡的非月卡用户的钻石消耗
function LeagueInfoModel:GetSweepCost()
    local leagueQuicklyMatch = CommonCost.leagueQuicklyMatch
    return leagueQuicklyMatch and leagueQuicklyMatch.price[1] or ""
end

return LeagueInfoModel
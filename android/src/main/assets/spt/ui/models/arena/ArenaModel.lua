local ArenaGrade = require("data.ArenaGrade")
local ArenaScore = require("data.ArenaScore")
local ArenaHelper = require("ui.scene.arena.ArenaHelper")
local Model = require("ui.models.Model")
local ArenaModel = class(Model, "ArenaModel")
local ArenaType = require("ui.scene.arena.ArenaType")
local ArenaIndexType = require("ui.scene.arena.ArenaIndexType")
local ReqEventModel = require("ui.models.event.ReqEventModel")
local Time = clr.UnityEngine.Time

function ArenaModel:ctor()
    ArenaModel.super.ctor(self)
end

function ArenaModel:Init(data)
    if not data then
        data = cache.getArenaInfo()
    end
    self.data = data or {}
    self.arena = self.data and self.data.arena or {}
    self.sign = self.data and self.data.sign or {}
    local time = Time.realtimeSinceStartup
    if self.sign.common then
        self.sign.common.startTime = time
    end
    if self.sign.advanceData then
        self.sign.advanceData.startTime = time
    end
    self.startTime = time
end

function ArenaModel:InitWithProtocol(data)
    assert(type(data) == "table")
    cache.setArenaInfo(data)
    self:Init(data)
    EventSystem.SendEvent("ArenaModelInfo", self)
end

function ArenaModel:GetMatchType(arenaType)
    if arenaType == ArenaType.SilverStage or arenaType == ArenaType.GoldStage or arenaType == ArenaType.BlackGoldStage or arenaType == ArenaType.PlatinumStage then
        return 'common'
    else
        return 'advance'
    end
end

function ArenaModel:GetSignData(arenaType)
    local matchType = ArenaModel:GetMatchType(arenaType)
    if matchType == 'common' then
        return self.sign.common
    else
        return self.sign.advanceData
    end
end

function ArenaModel:GetMatchData(arenaType)
    local matchType = ArenaModel:GetMatchType(arenaType)
    if matchType == 'common' then
        return self.arena
    else
        return self.arena.advanceData
    end
end

-- 是否已参赛
function ArenaModel:IsMatch(arenaType)
    local matchData = self:GetMatchData(arenaType)
    return matchData.groupID and matchData.groupID ~= ""
end

-- 白银币
function ArenaModel:GetSilverMoney()
    return self.data.silverM or 0
end
-- 黄金币
function ArenaModel:GetGoldMoney()
    return self.data.goldenM or 0
end
-- 黑金币
function ArenaModel:GetBlackGoldMoney()
    return self.data.blackM or 0
end
-- 白金币
function ArenaModel:GetPlatinaMoney()
    return self.data.platinumM or 0
end
-- 红金币
function ArenaModel:GetPeakChampionMoney()
    return self.data.peakChampionM or 0
end

function ArenaModel:GetArenaMedal(medalType)
    return self.data[medalType] or 0
end

function ArenaModel:SetSilverMoney(silverM)
    self.data.silverM = silverM
    EventSystem.SendEvent("ArenaModelInfo", self)
end

function ArenaModel:SetGoldMoney(goldenM)
    self.data.goldenM = goldenM
    EventSystem.SendEvent("ArenaModelInfo", self)
end

function ArenaModel:SetBlackGoldMoney(blackM)
    self.data.blackM = blackM
    EventSystem.SendEvent("ArenaModelInfo", self)
end

function ArenaModel:SetPlatinaMoney(platinumM)
    self.data.platinumM = platinumM
    EventSystem.SendEvent("ArenaModelInfo", self)
end

function ArenaModel:SetPeakChampionMoney(peakChampionM)
    self.data.peakChampionM = peakChampionM
    EventSystem.SendEvent("ArenaModelInfo", self)
end

-- 获取参赛的竞技场（分组后才有）
function ArenaModel:GetMatchArena(arenaType)
    local matchData = self:GetMatchData(arenaType)
    return matchData.zone
end

-- 竞技场状态 2：赛程中 3：有奖励未领奖 4：已领奖
function ArenaModel:GetMatchState(arenaType)
    local matchData = self:GetMatchData(arenaType)
    return matchData.state
end

function ArenaModel:IsMatchOverNotRecieve(arenaType)
    local matchData = self:GetMatchData(arenaType)
    return tobool(matchData.state == 3)
end

function ArenaModel:IsMatchOverRecieved(arenaType)
    local matchData = self:GetMatchData(arenaType)
    return tobool(matchData.state == 4)
end

function ArenaModel:IsMatchOngoing(arenaType)
    local matchData = self:GetMatchData(arenaType)
    return tobool(matchData.state == 2)
end

function ArenaModel:SetMatchState(arenaType, state)
    local matchData = self:GetMatchData(arenaType)
    matchData.state = state
    EventSystem.SendEvent("ArenaRewardStateChange", self)
end

-- 对应表中ranking
function ArenaModel:IsMatchRank(arenaType)
    local matchData = self:GetMatchData(arenaType)
    return matchData.rank
end

-- 对应比赛轮次
function ArenaModel:IsMatchOrder(arenaType)
    local matchData = self:GetMatchData(arenaType)
    return matchData.order
end

-- 比赛进度
function ArenaModel:GetGameOrder(arenaType)
    local matchData = self:GetMatchData(arenaType)
    return matchData.gameOrder
end

-- 比赛进度时间
function ArenaModel:GetGameTime(arenaType)
    local matchData = self:GetMatchData(arenaType)
    return self.startTime + matchData.lastTime - Time.realtimeSinceStartup
end

function ArenaModel:GetMatchRankId(ranking, order)
    for rankId, v in pairs(ArenaScore) do
        if v.ranking == ranking and v.gameOrder == order then 
            return rankId
        end
    end
    return -1
end

-- 判断竞技场比赛数据是否存在
function ArenaModel:IsMatchValid(arenaType)
    local matchData = self:GetMatchData(arenaType)
    return matchData.valid
end

-- 获取当前参赛的分组段位（分组后才有）
function ArenaModel:GetMatchStage(arenaType)
    local matchData = self:GetMatchData(arenaType)
    if not matchData.stage or matchData.stage == "" then 
        return 1
    end
    return matchData.stage 
end

-- 获取当前参赛的同组选手段位数据
function ArenaModel:GetMatchTeamsStage(arenaType)
    local matchData = self:GetMatchData(arenaType)
    return matchData.matchTeamsStage
end

-- 保存当前参赛的同组选手段位(奖励根据选手标准段位计算)
function ArenaModel:SetMatchTeamsStage(arenaType, teamsStage)
    local matchData = self:GetMatchData(arenaType)
    matchData.matchTeamsStage = teamsStage
end

-- 是否首次进入分组(read 1 表示已分配完成， 0 表示首次进入)
function ArenaModel:IsFirstGroup(arenaType)
    local matchData = self:GetMatchData(arenaType)
    return tobool(matchData.read == 0)
end

function ArenaModel:IsSelectArea(arenaType)
    return tobool(self:GetMatchArena(arenaType) == arenaType)
end

-- 未参赛的状态(false 未报名，true 分配中)
function ArenaModel:IsSign(arenaType)
    local signData = self:GetSignData(arenaType)
    return signData.isSign
end

-- 获取正在分配的竞技场
function ArenaModel:GetAllotArena(arenaType)
    local signData = self:GetSignData(arenaType)
    return signData.zone
end

-- 获取正在分配的时间
function ArenaModel:GetAllotTime(arenaType)
    local signData = self:GetSignData(arenaType)
    return signData.cd + signData.startTime - Time.realtimeSinceStartup 
end

-- 是否正在分配的竞技场
function ArenaModel:IsAllotArea(arenaType)
    return tobool(self:GetAllotArena(arenaType) == arenaType)
end

-- 获取是否可领取奖励
function ArenaModel:IsShowRedPoint(arenaType)
    local matchType = ArenaModel:GetMatchType(arenaType)
    if matchType == 'common' then
        return tonumber(ReqEventModel.GetInfo("arenaZone")) == ArenaIndexType[arenaType]
    else
        return tonumber(ReqEventModel.GetInfo("arenaZoneAdvance")) == ArenaIndexType[arenaType]
    end
end

-- 当前积分
function ArenaModel:GetAreaScore(arenaType)
    if not self.arena[arenaType] then return 0 end
    return self.arena[arenaType].score
end

-- 最大积分
function ArenaModel:GetAreaMaxScore(arenaType)
    if not self.arena[arenaType] then return 0 end
    return self.arena[arenaType].h_score
end

-- 经历赛季
function ArenaModel:GetAreaSeasons(arenaType)
    if not self.arena[arenaType] then return 0 end
    return self.arena[arenaType].seasons or 0
end

-- 经历冠军次数
function ArenaModel:GetAreaChampion(arenaType)
    if not self.arena[arenaType] then return 0 end
    return self.arena[arenaType].champCnt or 0
end

-- stage 段位
-- 用段位反推段位名
function ArenaModel:GetGradeName(stage)
    local name = ""
    for k, v in pairs(ArenaGrade) do
        if stage == v.stage then
            name = v.gradeName
            break
        end
    end
    return name
end

-- 获取每个段位上下限
function ArenaModel:GetStageScoreLimit(stage)
    local minScore, maxScore = 0, 0
    for k, v in pairs(ArenaGrade) do
        if stage == v.stage then 
            if v.maxScore > maxScore then 
                maxScore = v.maxScore
            end
            if v.minScore < minScore or minScore == 0 then 
                minScore = v.minScore
            end
        end
    end
    return minScore, maxScore
end

-- 用积分反推竞技场等级及星级(风云球队以下用段位表示，达到风云球队则改为数字星星表示)
function ArenaModel:GetAreaState(score)
    local minStageScore, maxStageScore = self:GetStageScoreLimit(ArenaHelper.StageType.StoryStage)
    if score > maxStageScore then -- 大于最高段位重置为最高积分
        score = maxStageScore
    elseif score <= 0 then
        score = 1
    end
    local stage, star, openStar, minStage, miniStage  = 0, 0, 0, 0, -1
    for k, v in pairs(ArenaGrade) do
        if v.minScore <= score and v.maxScore >= score then 
            stage = v.stage
            miniStage = v.miniStage
            if tonumber(stage) < ArenaHelper.StageType.StoryStage then 
                minStage = ArenaHelper.GetMinStageNum[v.miniStage]
                star = score - v.minScore + 1
                openStar = v.maxScore - v.minScore + 1
            else
                minStage = score - minStageScore + 1
            end
            break
        end
    end

    return stage, star, openStar, minStage, miniStage
end

function ArenaModel:SetSign(isSign, arenaType, cd)
    local signData = self:GetSignData(arenaType)
    signData.zone = arenaType
    signData.isSign = isSign
    signData.cd = cd
    signData.startTime = Time.realtimeSinceStartup
end

function ArenaModel:SetUnSign(isSign, arenaType)
    local signData = self:GetSignData(arenaType)
    signData.zone = arenaType
    signData.isSign = isSign
end

-- stage 段位
-- 用段位反推段位名
function ArenaModel:GetGradeName(stage)
    local name = ""
    for k, v in pairs(ArenaGrade) do
        if stage == v.stage then
            name = v.gradeName
            break
        end
    end
    return name
end

function ArenaModel:GetPayerSid()
    return self.data.arena.sid
end

return ArenaModel
local Nation = require("data.Nation")
local DreamLeagueCardBaseModel = require("ui.models.dreamLeague.DreamLeagueCardBaseModel")
local PlayerDreamCardsMapModel = require("ui.models.dreamLeague.PlayerDreamCardsMapModel")
local DreamLeagueCardModel = require("ui.models.dreamLeague.DreamLeagueCardModel")
local Model = require("ui.models.Model")
local DreamHallModel = class(Model, "DreamHallModel")

function DreamHallModel:InitWithProtocol(data)
    self.data = data
end

function DreamHallModel:GetMyScoreText()
    return lang.trans("dream_my_score", self.data.todayScore)
end

function DreamHallModel:GetYesterdayScoreText()
    return lang.trans("dream_yesterday_score", self.data.lastScore)
end

function DreamHallModel:GetBoardTitleText()
    return next(self.data.todayMatchList) and self.data.todayMatchList[1].tabName or ""
end

function DreamHallModel:GetyesterdayTitleText()
    return next(self.data.lastMatchList) and self.data.lastMatchList[1].tabName or ""
end

function DreamHallModel:GetBoardMatchScrollData()
    return self.data.todayMatchList
end

function DreamHallModel:GetYesterdayMatchScrollData()
    return self.data.lastMatchList
end

-- 是否可以设置阵容（用于按钮的灰态与否）
function DreamHallModel:IsCanSetFormation()
    local todayMatchList = self.data.todayMatchList
    if not next(todayMatchList) then
        return false
    end

    local participateTime = todayMatchList[1].participateTime
    return participateTime > os.time()
end

function DreamHallModel:GetYesterdayMatchScore(matchId)
    local scoreData = {}
    for i,v in pairs(self.data.lastMatchList) do
        if v.matchId == matchId then
            scoreData.homeTeam = v.homeTeam
            scoreData.homeTeamEn = v.homeTeamEn
            scoreData.awayTeam = v.awayTeam
            scoreData.awayTeamEn = v.awayTeamEn
            scoreData.homeScore = v.homeScore
            scoreData.homePenaltyScore = v.homePenaltyScore
            scoreData.awayScore = v.awayScore
            scoreData.awayPenaltyScore = v.awayPenaltyScore
        end
    end
    return scoreData
end

function DreamHallModel:GetTeamData()
    return self.data.team
end

function DreamHallModel:GetAllLightNation()
    local nations = {}
    for k,v in ipairs(self.data.todayMatchList) do
        nations[v.homeTeamEn] = true
        nations[v.awayTeamEn] = true
    end
    return nations
end

function DreamHallModel:GetAllLightDcids()
    local playerDreamCardsMapModel = PlayerDreamCardsMapModel.new()
    local allDcids = playerDreamCardsMapModel:GetCardList()
    local allNations = self:GetAllLightNation()
    local allLightDcids = {}
    for i,v in ipairs(allDcids) do
        local dreamLeagueCardModel = DreamLeagueCardModel.new(v)
        local nation = dreamLeagueCardModel:GetNation()
        if allNations[nation] then
            table.insert(allLightDcids, v)
        end
    end
    return allLightDcids, allNations
end

return DreamHallModel

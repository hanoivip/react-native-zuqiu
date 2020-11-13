local Model = require("ui.models.Model")
local Formation = require("data.Formation")

local PeakMatchDetailsModel = class(Model)

function PeakMatchDetailsModel:ctor()
    PeakMatchDetailsModel.super.ctor(self)
end

function PeakMatchDetailsModel:InitWithParentProtocol(data)
    assert(data)
    self.data = data
    --两种情况
    self.data.selfIsAttacker = self.data.selfIsAttacker or self.data.list
end

function PeakMatchDetailsModel:GetMatchTitleData()
    local matchTitleRawData = self.data
    self.matchTitleData = {}

    --两种情况
    local mAttackerData = matchTitleRawData.selfIsAttacker and matchTitleRawData.attacker or matchTitleRawData.defender
    local mDefenderData = matchTitleRawData.selfIsAttacker and matchTitleRawData.defender or matchTitleRawData.attacker
    self.matchTitleData.EnemyName = mDefenderData.name
    self.matchTitleData.EnemyZone = mDefenderData.serverName
    self.matchTitleData.EnemyFaceId = mDefenderData.logo
    self.matchTitleData.OurName = mAttackerData.name
    self.matchTitleData.OurZone = mAttackerData.serverName
    self.matchTitleData.OurFaceId = mAttackerData.logo
    self.matchTitleData.win = self.winCount > 1
    self.matchTitleData.fail = self.failCount > 1
    return self.matchTitleData
end

function PeakMatchDetailsModel:GetMatchResultDataList()
    self.winCount = 0
    self.failCount = 0
    self.matchResultDataList = {}
    local  tempData = {}
    if self.data.match then
        tempData = self.data.match
    else
        tempData = self.data.list
    end
    tempData.selfIsAttacker = self.data.selfIsAttacker
    self:GetSingleMatchData(tempData,"1")
    self:GetSingleMatchData(tempData,"2")
    self:GetSingleMatchData(tempData,"3")
    return self.matchResultDataList
end

function PeakMatchDetailsModel:GetSingleMatchData(match, index)
    --左侧防守，右侧进攻
    if not match[index] then
        return
    end
    local matchRawData = match[index]
    local matchResultData = {}
    matchResultData.vid = matchRawData.vid
    matchResultData.version = matchRawData.version
    local mAttackerData = match.selfIsAttacker and matchRawData.attacker or matchRawData.defender
    local mDefenderData = match.selfIsAttacker and matchRawData.defender or matchRawData.attacker
    local mAttackerScore = (mAttackerData.score or 0) + (mAttackerData.penaltyScore or 0)
    local mDefenderScore = (mDefenderData.score or 0) + (mDefenderData.penaltyScore or 0)
    matchResultData.Score = (mAttackerData.team and (mDefenderData.team and mAttackerScore or 3) or 0) .. " : " ..(mDefenderData.team and mDefenderScore or (mAttackerData.team and 0 or 3)) 
    matchResultData.defender = {}
    matchResultData.defender.win = mDefenderData.win
    matchResultData.defender.team = mDefenderData.team
    matchResultData.defender.formationID = mDefenderData.team and Formation[tostring(mDefenderData.formationID)].name or lang.trans("peak_incomplete_formation")
    matchResultData.defender.captain = mDefenderData.captain
    matchResultData.defender.GiveUp = not mDefenderData.team and (not mDefenderData.win)
    matchResultData.attacker = {}
    matchResultData.attacker.win = mAttackerData.win
    matchResultData.attacker.team =mAttackerData.team
    matchResultData.attacker.formationID = mAttackerData.team and Formation[tostring(mAttackerData.formationID)].name or  lang.trans("peak_incomplete_formation")
    matchResultData.attacker.captain = mAttackerData.captain
    matchResultData.attacker.GiveUp = not mAttackerData.team
    self.winCount = self.winCount + (matchResultData.attacker.win and 1 or 0)
    self.failCount = self.failCount + (matchResultData.attacker.win and 0 or 1)
    matchResultData.MatchSession = lang.trans("peak_num_scene",index)
    table.insert(self.matchResultDataList, matchResultData)
end

function PeakMatchDetailsModel:GetUrlData()
    local  flagData = {}
    flagData.flag = true
    local tempData = self.data.list
    if not tempData then
        flagData.flag = false
        return flagData
    end
    --有三局比赛或者有两句比赛，第一场和第二场结果相同
    if tempData["3"] or tempData["1"] and tempData["2"] and tempData["1"].attacker.win == tempData["2"].attacker.win then
        flagData.flag = false
    end
    flagData.pid = self.data.defender.pid
    flagData.challengeId = self.data.challengeId
    flagData.Order = tempData["2"] and 3 or 2
    return flagData
end

return PeakMatchDetailsModel
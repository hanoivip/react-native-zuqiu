local ActivityModel = require("ui.models.activity.ActivityModel")
local WorldBossSeverRank = require("data.WorldBossSeverRank")
local WorldBossSingleRank = require("data.WorldBossSingleRank")
local TeamTotal = require("data.TeamTotal")
local WorldBossActivityModel = class(ActivityModel)

function WorldBossActivityModel:InitWithProtocol()
end

function WorldBossActivityModel:InitResponseData(data)
    self.responseData = data
end

function WorldBossActivityModel:InitNPCData(data)
    self.responseNPCData = data
end

function WorldBossActivityModel:GetMainViewState()
    return self:GetActivitySingleData().showType
end

function WorldBossActivityModel:GetTeamNames()
    local tempData = {}
    local tempList = self:GetTeamData()
    for k,v in pairs(tempList) do
        tempData[k] = TeamTotal[v.opponentName]["teamName"]
    end
    return tempData
end

--死数据
function WorldBossActivityModel:GetTeamData()
    if not self.teamData then
        local tempList = self.responseNPCData.npcInfo
        table.sort(tempList, function(a, b) return a.opponentId > b.opponentId end )
        self.teamData = tempList
    end
    return self.teamData
end

local RedPackType = { Will = 1, Proceed = 2, Over = 3}
function WorldBossActivityModel:GetRedPackData()
    local tempRedPackData = {}
    if self.responseData.grabDiamond > 0 then
        tempRedPackData.state = RedPackType.Over
    elseif self.responseData.grabRemainTime then
        tempRedPackData.state = RedPackType.Will
    elseif self.responseData.grabEndRemainTime then
        tempRedPackData.state = RedPackType.Proceed
    end
    tempRedPackData.baseCount = self.responseData.serverDiamond
    for k,v in pairs(WorldBossSeverRank) do
        if v.rankDown == 0 then
            tempRedPackData.baseRank = v.rankScore
        end
        if self.responseData.serverRank >= v.rankTop and self.responseData.serverRank <= v.rankDown then
            tempRedPackData.baseRank = v.rankScore
            break
        end
    end
    if tempRedPackData.baseRank then
        tempRedPackData.baseRank = tempRedPackData.baseRank * 0.01
    end
    tempRedPackData.diamond = "  X" .. (tempRedPackData.state == RedPackType.Over and self.responseData.grabDiamond or (tempRedPackData.state == RedPackType.Will and self.responseData.serverDiamond or math.ceil(self.responseData.serverDiamond * tempRedPackData.baseRank)))
    tempRedPackData.playerCount = self.responseData.matchCount
    tempRedPackData.time = self.responseData.grabRemainTime or self.responseData.grabEndRemainTime
    return tempRedPackData
end

function WorldBossActivityModel:GetGrabResultData(resultDiamond)
    local resultData = {}
    resultData.rank = self.responseData.playerRank
    for k,v in pairs(WorldBossSingleRank) do
        if v.rankDown == 0 then
            resultData.numK = v.rankScore
        end
        if self.responseData.playerRank >= v.rankTop and self.responseData.playerRank <= v.rankDown then
            resultData.numK = v.rankScore
            break
        end
    end
    --系数 0.01
    resultData.numK = resultData.numK * 0.01
    resultData.baseCount = math.floor(resultDiamond / resultData.numK)
    resultData.resultCount = resultDiamond
    return resultData
end

function WorldBossActivityModel:GetRankData()
    return self.responseData
end

function WorldBossActivityModel:SetRewardStatusByIndex(index, value)
    self:GetActivitySingleData().list[index].status = value
end

function WorldBossActivityModel:GetEndTime()
    return self:GetActivitySingleData().endTime
end

function WorldBossActivityModel:GetBeginTime()
    return self:GetActivitySingleData().beginTime
end

function WorldBossActivityModel:GetName()
    return self:GetActivitySingleData().name
end

function WorldBossActivityModel:GetFreeTime()
    return self.responseData.matchTimes > 0 and self.responseData.matchTimes or 0
end

function WorldBossActivityModel:GetActivityDesc()
    return self:GetActivitySingleData().desc
end

function WorldBossActivityModel:GetBuyChallengeInfo()
    local tempList = {}
    tempList.matchTimes = self.responseData.matchTimes
    tempList.price = self:GetActivitySingleData().price
    tempList.canMatch = not self.responseData.isGrabTime
    return tempList
end

return WorldBossActivityModel
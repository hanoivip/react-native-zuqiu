local Model = require("ui.models.Model")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")

local PeakRankModel = class(Model)

function PeakRankModel:ctor()
    PeakRankModel.super.ctor(self)
    self.cacheData = {}
    self.cacheData.rankSeasonList = {
        {
            name = lang.trans("peak_realTimeRank"),
            type = "current",
            isSelect = true
        }
    }
    self.cacheData.mySeasonRankInfo = {}
end

function PeakRankModel:InitMyRealTimeRankInfo(rankInfo)
    if rankInfo then
        self.cacheData.myRealTimeRankInfo = {
            rank = rankInfo.rank,
            name = rankInfo.name,
            level = rankInfo.lvl,
        }
    else
        self.cacheData.myRealTimeRankInfo = nil
    end
end

function PeakRankModel:GetMyRealTimeRankInfo()
    return self.cacheData.myRealTimeRankInfo
end

function PeakRankModel:InitRealTimeRankList(rankDataList)
    self.cacheData.realTimeRankList = {}
    for id, data in pairs(rankDataList) do
        local rankData = {}
        rankData.id = id
        rankData.pid = data.pid
        rankData.sid = data.sid
        rankData.name = data.name
        rankData.logo = data.logo
        rankData.lvl = data.lvl
        rankData.rank = data.rank
        rankData.serverName = data.serverName
        rankData.displayId = data.displayId
        rankData.worldTournamentLevel = data.worldTournamentLevel
        table.insert(self.cacheData.realTimeRankList, rankData)
    end
    table.sort(self.cacheData.realTimeRankList, function(a, b) return a.rank < b.rank end)
end

function PeakRankModel:GetRealTimeRankList()
    return self.cacheData.realTimeRankList
end

function PeakRankModel:InitRankSeasonList(seasonList)
    if seasonList then
        self.cacheData.historySeasonRankDataList = {}
        for seasonName, rankDataList in pairs(seasonList) do
            local seasonTable = {}
            seasonTable.name = lang.trans("peak_oldSeasonRank", tostring(seasonName))
            seasonTable.type = tostring(seasonName)
            seasonTable.isSelect = false
            table.insert(self.cacheData.rankSeasonList, seasonTable)

            --初始化历史赛季排行榜
            self:InitHistorySeasonRankList(rankDataList, tostring(seasonName))
        end
    end
end

function PeakRankModel:GetRankSeasonList()
    return self.cacheData.rankSeasonList
end

function PeakRankModel:GetCurRankSeason()
    local seasonList = self:GetRankSeasonList()
    if seasonList then
        for i, seasonData in ipairs(seasonList) do
            if seasonData.isSelect then
                return seasonData
            end
        end
    end
    return nil
end

function PeakRankModel:InitHistorySeasonRankList(rankDataList, seasonType)
    local tempDataList = {}
    for id, data in pairs(rankDataList) do
        local rankData = {}
        rankData.id = id
        rankData.pid = data.pid
        rankData.sid = data.sid
        rankData.peakCount = data.peakCount
        rankData.rank = data.rank
        rankData.name = data.name
        rankData.logo = data.logo
        rankData.lvl = data.lvl
        rankData.serverName = data.serverName
        rankData.displayId = data.displayId
        rankData.worldTournamentLevel = data.worldTournamentLevel
        table.insert(tempDataList, rankData)
    end
    table.sort(tempDataList, function(a, b) return a.rank < b.rank end)
    self.cacheData.historySeasonRankDataList[seasonType] = tempDataList
end

function PeakRankModel:GetHistorySeasonRankDataListBySeason(seasonType)
    return self.cacheData.historySeasonRankDataList[seasonType]
end

function PeakRankModel:InitCurRankDataList(rankDataList)
    if rankDataList and #rankDataList > 0 then
        local curSeasonData = {}
        curSeasonData.name = lang.trans("peak_curSeasonRank")
        curSeasonData.type = tostring("season")
        curSeasonData.isSelect = false
        table.insert(self.cacheData.rankSeasonList, curSeasonData)

        self.cacheData.curRankDataList = {}
        for id, data in pairs(rankDataList) do
            local rankData = {}
            rankData.id = id
            rankData.pid = data.pid
            rankData.sid = data.sid
            rankData.peakCount = data.peakCount
            rankData.rank = data.rank
            rankData.name = data.name
            rankData.logo = data.logo
            rankData.lvl = data.lvl
            rankData.serverName = data.serverName
            rankData.displayId = data.displayId
            table.insert(self.cacheData.curRankDataList, rankData)
        end
        table.sort(self.cacheData.curRankDataList, function(a, b) return a.rank < b.rank end)
    end
end

function PeakRankModel:GetCurRankDataList()
    return self.cacheData.curRankDataList
end

function PeakRankModel:InitMyRankInfo(rankInfo)
    if rankInfo then
        self.cacheData.myRankInfo = {
            peakCount = rankInfo.peakCount,
            rank = rankInfo.rank,
            name = rankInfo.name,
            level = rankInfo.lvl,
        }
    else
        self.cacheData.myRankInfo = nil
    end
end

function PeakRankModel:GetMySeasonRankInfo(seasonType)
    if not self.cacheData.mySeasonRankInfo[seasonType] then
        local list = self:GetHistorySeasonRankDataListBySeason(seasonType)
        local mPid = PlayerInfoModel.new():GetID()
        for K,v in pairs(list) do
            if mPid == v.pid then
                self.cacheData.mySeasonRankInfo[seasonType] = {
                    peakCount = v.peakCount,
                    rank = v.rank,
                    name = v.name,
                    level = v.lvl,
                }
                break
            end
        end
    end
    return self.cacheData.mySeasonRankInfo[seasonType]
end

function PeakRankModel:GetMyRankInfo()
    return self.cacheData.curSelectRankBar
end

function PeakRankModel:InitCurRankDataBySelectType(seasonType)
    self.cacheData.curSelectRankData = {}
    if seasonType == "current" then
        self.cacheData.curSelectRankData = self:GetRealTimeRankList()
    elseif seasonType == "season" then
        self.cacheData.curSelectRankData = self:GetCurRankDataList()
        self.cacheData.curSelectRankBar = self.cacheData.myRankInfo
    else
        self.cacheData.curSelectRankData = self:GetHistorySeasonRankDataListBySeason(seasonType)
        self.cacheData.curSelectRankBar = self:GetMySeasonRankInfo(seasonType)
    end
end

function PeakRankModel:GetCurSelectRankData()
    return self.cacheData.curSelectRankData
end

function PeakRankModel:SetPrePeakDailyCount(prePeakDailyCount)
    self.cacheData.prePeakDailyCount = prePeakDailyCount
end

function PeakRankModel:GetPrePeakDailyCount()
    return self.cacheData.prePeakDailyCount
end

return PeakRankModel
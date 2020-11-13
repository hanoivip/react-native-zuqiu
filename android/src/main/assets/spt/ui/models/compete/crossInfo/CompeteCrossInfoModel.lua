local Model = require("ui.models.Model")

local CompeteCrossInfoModel = class(Model, "CompeteCrossInfoModel")

local CompeteMatchTypeList = {
    ["1"] = "compete_crossInfo_districtScore",
    ["2"] = "compete_crossInfo_bigEar_shooter",
    ["3"] = "compete_crossInfo_smallEar_shooter",
    ["4"] = "compete_crossInfo_bigEar_assister",
    ["5"] = "compete_crossInfo_smallEar_assister"
}

local arenaScoreLabel = "1"
local arenaScoreLabelNum = 1

function CompeteCrossInfoModel:ctor()
    self.seasonList = {}
    self.currSeason = ""
    self.rankLabel = {}
    self.currLabel = -1
    self.data = {}
    self.fourSeasons = {}
end

function CompeteCrossInfoModel:InitWithProtocol(season, matchType, data)
    if not data then
        dump("error:    data is null!!!")
        data = {}
    end

    local sl = {}
    if data.seasonList then
        for k, v in pairs(data.seasonList) do
            local tempData = {}
            tempData.seasonName = k
            tempData.tag = v
            table.insert(sl, tempData)
        end
    end
    self.seasonList = sl or {}
    table.sort(self.seasonList, function(a, b)
        return tonumber(a.tag) > tonumber(b.tag)
    end)
    if not season and self.seasonList and next(self.seasonList) then
        season = self.seasonList[1].tag
    end
    self:InitSeasons(self.seasonList)
    self:InitRankLabels(season)

    self:AddDataWithProtocol(season, matchType, data)
end

function CompeteCrossInfoModel:InitSeasons(seasonList)
    for k, seasonData in pairs(seasonList) do 
        self.data[seasonData.tag] = {}
    end
end

--[[
@ season 赛季
]]
function CompeteCrossInfoModel:InitRankLabels(season)
    self.rankLabel = {}
    for k, v in pairs(CompeteMatchTypeList) do
        local labelData = {}
        labelData.matchType = k
        labelData.nameLoc = v
        labelData.sort = tonumber(k)
        labelData.tag = k

        table.insert(self.rankLabel, labelData)
    end

    table.sort(self.rankLabel, function(a, b)
        return a.sort < b.sort
    end)
end

function CompeteCrossInfoModel:AddDataWithProtocol(season, matchType, data)
    if not season then return end
    
    if tonumber(matchType) ~= arenaScoreLabelNum then
        if not data.rankList then
            dump("error:   rankList is null!")
            data.rankList = {}
        end
    else
        if not data.serverRank then
            dump("error:   serverRank is null!")
            data.serverRank = {}
        end
    end
    local labelTypeList = self.data[season] or {}
    local tempData = nil
    if tonumber(matchType) == arenaScoreLabelNum then 
        tempData = data.serverRank
    else
        tempData = data.rankList
    end
    labelTypeList[tostring(matchType)] = tempData
    if season then
        self.data[season] = labelTypeList
    end
end

function CompeteCrossInfoModel:GetSeasonList()
    return self.seasonList
end

function CompeteCrossInfoModel:GetRankLabel()
    return self.rankLabel
end

function CompeteCrossInfoModel:GetDefaultMatchType()
    return arenaScoreLabel
end

function CompeteCrossInfoModel:SetCurrSeasonTag(season)
    self.currSeason = season
end

function CompeteCrossInfoModel:SetCurrLabelTag(label)
    self.currLabel = label
end

function CompeteCrossInfoModel:GetCurrSeasonTag()
    return self.currSeason
end

function CompeteCrossInfoModel:GetCurrLabelTag()
    return self.currLabel
end

function CompeteCrossInfoModel:GetFourSeasons()
    return self.fourSeasons
end

function CompeteCrossInfoModel:IsDataExist(season, matchType)
    if not season or not matchType or not self.data[season] then
        return true
    else
        return tobool(self.data[season][matchType])
    end
end

function CompeteCrossInfoModel:GetRankList()
    if not self.currSeason or self.currSeason == "" or not self.data[self.currSeason] then
        local empty = {}
        return empty
    end
    local labelTypeList = self.data[self.currSeason]
    local tempData = labelTypeList[self.currLabel or arenaScoreLabel]

    self.fourSeasons = {}
    if tostring(self.currLabel) == arenaScoreLabel and tempData.seasonData then  --获得四个赛季信息
        for k, v in pairs(tempData.seasonData) do
            local tempSeasonData = {}
            tempSeasonData.seasonName = k
            tempSeasonData.tag = v
            table.insert(self.fourSeasons, tempSeasonData)
        end
        if table.nums(self.fourSeasons) > 0 then
            table.sort(self.fourSeasons, function(a, b)
                return tonumber(a.tag) > tonumber(b.tag)
            end)
        end
    end
    local indexTable = {}

    if not tempData or not next(tempData) then return {} end
    if tostring(self.currLabel) == arenaScoreLabel and tempData.seasonData then     
        local index = 1
        for k, v in pairs(tempData) do      --将数据table表的索引转化为连续数字
            if k ~= "seasonData" then
                table.insert(indexTable, tempData[tostring(index)])
                index = index + 1
            end
        end
    else
        for k, v in pairs(tempData) do
            table.insert(indexTable, v)
        end
    end
    if #indexTable == 0 then
         dump("error:   table data is null!")
    end
    for k, v in pairs(indexTable) do      --排名由服务器处理
        v.pos = k
    end

    return indexTable
end

return CompeteCrossInfoModel
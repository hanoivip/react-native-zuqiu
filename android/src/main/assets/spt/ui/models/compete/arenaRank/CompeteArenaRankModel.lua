local Model = require("ui.models.Model")
local WorldTournamentUpgrade = require("data.WorldTournamentUpgrade")

local CompeteArenaRankModel = class(Model, "CompeteArenaRankModel")

local CompeteMatchTypeList = {
    ["7"] = "compete_match_type1",      -- 超级联赛
    ["8"] = "compete_match_type2",      -- 冠军联赛
    ["9"] = "compete_match_type3",      -- 甲级联赛
    ["10"] = "compete_match_type4",     -- 乙级联赛
    ["11"] = "compete_match_type5"      -- 地区联赛，有多个地区分组
}

local local_match_type_key = "11"
local default_match_type_key = "7"

function CompeteArenaRankModel:ctor()
    self.seasonList = {}
    self.currSeason = nil
    self.rankLabel = {}
    self.currLabel = -1
    self.data = {}
    self.data.myRank = {}
    self.data.localMatchCount = {}
end

function CompeteArenaRankModel:InitWithProtocol(season, matchType, data)
    assert(data ~= nil, "data is nil")

    if data.localMatchCount == 0 then data.localMatchCount = 1 end

    self.data.myRank = data.myRank

    self.seasonList = {}
    if data.seasonList then
        for k, v in pairs(data.seasonList) do
            local tempData = {}
            tempData.seasonName = k
            tempData.tag = v
            table.insert(self.seasonList, tempData)
        end
    end

    table.sort(self.seasonList, function(a, b)
        return tonumber(a.tag) > tonumber(b.tag)
    end)
    if not season and self.seasonList and next(self.seasonList) and self.seasonList[1] then
        season = self.seasonList[1].tag
    end
    self:InitSeasons(self.seasonList)
    self:InitRankLabels(season, data.localMatchCount)

    self:AddDataWithProtocol(season, matchType, data)
end

function CompeteArenaRankModel:InitSeasons(seasonList)
    for k, seasonData in pairs(seasonList) do 
        self.data[seasonData.tag] = {}
    end
end

--[[
@ season 赛季
@ localMatchCount 地区联赛数目
]]
function CompeteArenaRankModel:InitRankLabels(season, localMatchCount)
    self.rankLabel = {}
    local specialKey = nil
    for k, v in pairs(CompeteMatchTypeList) do
        if k ~= local_match_type_key then
            local labelData = {}
            labelData.matchType = k
            labelData.nameLoc = v
            labelData.sort = tonumber(k)
            labelData.group = 0       -- 非地区联赛group为0
            labelData.tag = k

            table.insert(self.rankLabel, labelData)
        else
            specialKey = k
        end
    end

    local sort = 0
    for i = 1, tonumber(localMatchCount) do
        local labelData = {}
        labelData.matchType = specialKey
        labelData.nameLoc = CompeteMatchTypeList[specialKey]
        labelData.sort = tonumber(specialKey) + sort        
        labelData.group = i
        labelData.tag = local_match_type_key .. "." .. tostring(i)
        table.insert(self.rankLabel, labelData)

        sort = sort + 1
    end
    table.sort(self.rankLabel, function(a, b)
        return a.sort < b.sort
    end)
end

function CompeteArenaRankModel:AddDataWithProtocol(season, matchType, data)
    if not season then return end

    if not data.rankList then 
        dump("error： data.rankList is nil!!!")
        data.rankList = {} 
    end
    if data.myRank and season then
        self.data.myRank[tostring(season)] = {}
        self.data.myRank[tostring(season)].matchType = data.myRank.matchType
        self.data.myRank[tostring(season)].rank = data.myRank.rank
        self.data.myRank[tostring(season)].score = data.myRank.score
        self.data.myRank[tostring(season)].subType = data.myRank.subType        
    end

    self:SetLocalMatchCount(season, data.localMatchCount)
    if data.rankList.group ~= nil then    -- 地区联赛数据
        self.data[season][local_match_type_key] = {}
        if data.rankList.group then
            for k, v in pairs(data.rankList.group) do 
                local matchTypeList = self.data[season] or {}
                local matchTypeKey = tostring(matchType) .. "." .. tostring(k)
                matchTypeList[matchTypeKey] = v
                self.data[season] = matchTypeList
            end
        end
    else
        local matchTypeList = self.data[season] or {}
        matchTypeList[tostring(matchType)] = data.rankList
        self.data[season] = matchTypeList
    end
end

function CompeteArenaRankModel:GetLocalMatchCount(season)
    return self.data.localMatchCount[season]
end

function CompeteArenaRankModel:SetLocalMatchCount(season, localMatchCount)
    self.data.localMatchCount[season] = localMatchCount
end

function CompeteArenaRankModel:GetSeasonList()
    return self.seasonList
end

function CompeteArenaRankModel:GetRankLabel()
    return self.rankLabel
end

function CompeteArenaRankModel:GetMyRankSubType(season)
    return  self.data.myRank[tostring(season)].subType
end

function CompeteArenaRankModel:GetDefaultMatchType()
    return "7"
end

function CompeteArenaRankModel:SetCurrSeasonTag(season)
    self.currSeason = season
end

function CompeteArenaRankModel:SetCurrLabelTag(label)
    self.currLabel = label
end

function CompeteArenaRankModel:GetCurrSeasonTag()
    return self.currSeason 
end

function CompeteArenaRankModel:GetCurrLabelTag()
    return self.currLabel
end

function CompeteArenaRankModel:IsDataExist(season, matchType)
    if not season or not matchType or not self.data[season] then
        return true
    else
        return tobool(self.data[season][matchType])
    end
end

function CompeteArenaRankModel:GetRankList()
    if not self.currSeason or self.currSeason == "" or not self.data[self.currSeason] then
        return {}
    end

    local matchTypeList = self.data[self.currSeason]
    local tempData = matchTypeList[self.currLabel or "7"] --将数据table表的索引转化为连续数字，并排序
    tempData = tempData or matchTypeList[self.currLabel..".1"] ---兼容

    if not tempData or not next(tempData) then return {} end

    local indexTable = {}
    for k, v in pairs(tempData) do
        table.insert(indexTable, v)
    end

    for k, v in pairs(indexTable) do      --排名是否需要手动处理？
        v.pos = k
    end

    if self.seasonList and next(self.seasonList) and self.seasonList[1] then
        if self.currSeason == self.seasonList[1].tag then
            self:SetUpgradeInfo(indexTable)
        end
    end

    return indexTable
end

function CompeteArenaRankModel:GetCurrMatchType(season)
    local myMatchType = self.data.myRank[tostring(season)].matchType
    if myMatchType == "" or myMatchType == 0 or not myMatchType then
        return "share_leagueNone"
    else
        return CompeteMatchTypeList[tostring(myMatchType)]
    end
end

function CompeteArenaRankModel:GetMyRank(season)
    return self.data.myRank[tostring(season)].rank
end

function CompeteArenaRankModel:GetMyScore(season)
    return self.data.myRank[tostring(season)].score
end

function CompeteArenaRankModel:SetUpgradeInfo(rankList)
    if tonumber(self.currLabel) > tonumber(local_match_type_key) then self.currLabel = local_match_type_key end
    local upgradeInfo = WorldTournamentUpgrade[self.currLabel]
    local upgradeNum = upgradeInfo.upgradeNum
    local reduceNum = upgradeInfo.reduceNum
    local currLocalMatchCount = self:GetLocalMatchCount(self.currSeason)
    if self.currLabel == local_match_type_key then
        upgradeNum = math.floor(upgradeNum / currLocalMatchCount)
        reduceNum = math.floor(reduceNum / currLocalMatchCount)
    end

    local totalNum = table.nums(rankList)
    local finalNum = totalNum - reduceNum + 1
    if upgradeNum > totalNum then return end
    if finalNum <= 0 then return end

    for i = 1, upgradeNum, 1 do
        rankList[i].isUpgrade = true
    end

    for i = totalNum, finalNum, -1 do
        rankList[i].isReduce = true
    end
end

return CompeteArenaRankModel
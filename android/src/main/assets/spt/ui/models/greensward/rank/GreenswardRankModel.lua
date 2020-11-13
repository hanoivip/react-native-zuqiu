local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local AdventureRegion = require("data.AdventureRegion")
local Model = require("ui.models.Model")
local GreenswardRankModel = class(Model, "GreenswardRankModel")

GreenswardRankModel.defaultSeasonTag = 1
GreenswardRankModel.defaultRegionTag = "1"

function GreenswardRankModel:ctor()
    GreenswardRankModel.super.ctor(self)
    self.playerInfoModel = PlayerInfoModel.new()
end

function GreenswardRankModel:Init()
    GreenswardRankModel.super.Init(self)
end

function GreenswardRankModel:InitWithProtocol(data)
    self.data = data
    local rankData = {}
    local season = data.season
    local region = tostring(self:GetMyRegion())
    rankData[season] = {}
    rankData[season].seasonID = season
    rankData[season].isCurrent = true
    rankData[season][region] = data.rankBoard
    for i, v in ipairs(data.historySeason) do
        if not rankData[v] then
            rankData[v] = {}
            rankData[v].seasonID = v
        end
    end
    self.rankData = rankData
    self:SetSeasonAndRegionTag(season, region)
end

function GreenswardRankModel:GetSeasonList()
    local seasonList = {}
    local currentSeason = self:GetMySeason()
    -- 当前赛季特殊显示
    local tc = {}
    tc.seasonID = currentSeason
    tc.isCurrent = true
    table.insert(seasonList, tc)
    local historySeason = self.data.historySeason
    table.sort(historySeason, function(a, b)
            return tonumber(a) > tonumber(b)
    end)
    for i, v in ipairs(historySeason) do
        if v ~= currentSeason then
            table.insert(seasonList, {["seasonID"] = v})
        end
    end
    return seasonList
end

function GreenswardRankModel:GetAllRegion()
    local r = {}
    for i, v in pairs(AdventureRegion) do
        local index = tonumber(i)
        v.regionID = i
        r[index] = v
    end
    return r
end

function GreenswardRankModel:GetCurrentTag()
    local seasonTag = self.seasonTag or GreenswardRankModel.defaultSeasonTag
    local regionTag = self.regionTag or GreenswardRankModel.defaultRegionTag
    return seasonTag, regionTag
end

function GreenswardRankModel:SetSeasonAndRegionTag(seasonTag, regionTag)
    self.seasonTag = seasonTag or GreenswardRankModel.defaultSeasonTag
    self.regionTag = regionTag or GreenswardRankModel.defaultRegionTag
end

function GreenswardRankModel:SetGreenswardBuildModel(greenswardBuildModel)
    self.greenswardBuildModel = greenswardBuildModel
end

function GreenswardRankModel:GetGreenswardBuildModel()
    return self.greenswardBuildModel
end

function GreenswardRankModel:GetMyPoint()
    local point = self.greenswardBuildModel:GetPoint()
    return point
end

function GreenswardRankModel:GetMySeason()
    return self.data.season
end

function GreenswardRankModel:GetMyRegion()
    return self.data.region
end

function GreenswardRankModel:GetMyRank()
    return self.data.myRank
end

function GreenswardRankModel:SetRegionData(season, region, data)
    if not self.rankData[season] then
        self.rankData[season] = {}
        self.rankData[season].seasonID = season
    end
    if not self.rankData[season][region] then
        self.rankData[season][region] = {}
    end
    self.rankData[season][region] = data
end

function GreenswardRankModel:GetDataByTag(seasonTag, regionTag)
    return self.rankData[seasonTag] and self.rankData[seasonTag][regionTag]
end

return GreenswardRankModel

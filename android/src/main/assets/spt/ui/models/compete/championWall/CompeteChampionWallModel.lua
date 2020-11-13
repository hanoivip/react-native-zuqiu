local CompeteSchedule = require("ui.models.compete.main.CompeteSchedule")
local FilterModel = require("ui.models.compete.championWall.CompeteChampionWallFilterModel")
local OverviewModel = require("ui.models.compete.championWall.CompeteChampionWallOverviewModel")
local WorldTournamentSeason = require("data.WorldTournamentSeason")
local Model = require("ui.models.Model")

local CompeteChampionWallModel = class(Model, "CompeteChampionWallModel")

-- 每组有多少item
local Default_Group_Num = 20

local fixIdxCounter = 1

CompeteChampionWallModel.FilterTypeGroup = "Group"

function CompeteChampionWallModel:ctor()
    self.bigEarList = {}
    self.smallEarList = {}
    self.bigEarOverviewList = {} -- 获得冠军次数统计
    self.smallEarOverviewList = {}
    -- 当前页签
    self.currTag = nil
    -- 当前分组，每20个1组，默认第一个分组
    self.currBigEarGroup = nil
    self.currSmallEarGroup = nil
    -- 当前tag与group条件下的右侧列表
    self.currList = {}
    -- 当前选中的右侧列表中索引
    self.currFixIdx = nil
end

function CompeteChampionWallModel:InitWithProtocol(data)
    self.themeCache = {}
    for k, v in pairs(WorldTournamentSeason or {}) do
        self.themeCache[tostring(v.period)] = tostring(v.name)
    end
    self.bigEarList = data.bigEar or {}
    self.smallEarList = data.smallEar or {}
    self.bigEarOverviewList = {}
    self.smallEarOverviewList = {}
    fixIdxCounter = 1

    self:PolishData(self.bigEarList, CompeteSchedule.Big_Ear_Match, self.bigEarOverviewList)
    self:PolishData(self.smallEarList, CompeteSchedule.Small_Ear_Match, self.smallEarOverviewList)
    if table.nums(self.bigEarList) > 0 and self.currFixIdx == nil then
        self:SetCurrFixIdx(self.bigEarList[1].fixIdx)
    end
end

function CompeteChampionWallModel:PolishData(rawData, matchType, overviewList)
    -- 倒序
    table.sort(rawData, function(a, b)
        return tonumber(a.season) > tonumber(b.season)
    end)
    local idx = 1
    local rawCount = #rawData
    local group = math.ceil((rawCount) / Default_Group_Num) -- 计算一共分多少组
    -- 生成筛选栏名字数据
    local filterNames = {}
    for k = 1, group do
        filterNames[k] = {}
        local startNameIdx = k * Default_Group_Num
        local endNameIdx = (k - 1) * Default_Group_Num + 1
        if startNameIdx > rawCount then
            startNameIdx = rawCount
        end
        if endNameIdx > rawCount then
            endNameIdx = rawCount
        end
        filterNames[k].startName = rawData[startNameIdx].seasonName
        filterNames[k].endName = rawData[endNameIdx].seasonName
    end
    for k, v in ipairs(rawData) do
        v.fixIdx = fixIdxCounter
        v.idx = (k - 1) % Default_Group_Num + 1 -- 组内索引
        v.group = math.floor((k - 1) / Default_Group_Num) + 1 -- 属于第几组
        v.matchType = matchType
        v.theme = self.themeCache[tostring(v.season)] or lang.transstr("compete_champion_wall_no_theme")

        fixIdxCounter = fixIdxCounter + 1

        -- 获得冠军次数统计
        if overviewList[v.pid] == nil then
            local overviewData = {}
            overviewData.pid = v.pid
            overviewData.sid = v.sid
            overviewData.serverName = v.serverName
            overviewData.name = v.name
            overviewData.count = 0
            overviewList[v.pid] = overviewData
        end
        overviewList[v.pid].count = overviewList[v.pid].count + 1
    end

    self:PolishFilterModel(matchType, group, filterNames)
end

function CompeteChampionWallModel:PolishFilterModel(matchType, group, filterNames)
    local filterModel = nil
    if matchType == CompeteSchedule.Big_Ear_Match then
        FilterModel.BigEar[self.FilterTypeGroup] = {}
        filterModel = FilterModel.BigEar[self.FilterTypeGroup]
    elseif matchType == CompeteSchedule.Small_Ear_Match then
        FilterModel.SmallEar[self.FilterTypeGroup] = {}
        filterModel = FilterModel.SmallEar[self.FilterTypeGroup]
    end

    if table.nums(filterNames) <= 0 then return end

    if filterModel ~= nil then
        local season_str = lang.transstr("ladder_oldSeasonRank")
        for i = 1, group do
            local name = ""
            if filterNames[i].startName == filterNames[i].endName then -- 当前group只有一个赛季
                name = lang.transstr("ladder_oldSeasonRank", filterNames[i].endName)
            else
                name = lang.transstr("ladder_oldSeasonRank", filterNames[i].endName) .. "-" .. lang.transstr("ladder_oldSeasonRank", filterNames[i].startName)
            end
            local filterData = {
                id = i,
                name = name,
                filterVar = i
            }
            table.insert(filterModel, filterData)
        end
    end
end

function CompeteChampionWallModel:GetStatusData()
    return self.currTag, self.currBigEarGroup, self.currSmallEarGroup, self.currFixIdx
end

function CompeteChampionWallModel:GetItemDataByFixIdx(fixIdx)
    local result = nil
    if fixIdx == nil then
        return result
    end
    for k, v in pairs(self.bigEarList) do
        if v.fixIdx == fixIdx then
            result = v
            break
        end
    end
    if result == nil then
        for k, v in pairs(self.smallEarList) do
            if v.fixIdx == fixIdx then
                result = v
                break
            end
        end
    end

    return result
end

function CompeteChampionWallModel:GetSelectItemData()
    return self:GetItemDataByFixIdx(self.currFixIdx)
end

function CompeteChampionWallModel:SetCurrTag(tag)
    self.currTag = tag
end

function CompeteChampionWallModel:GetCurrTag()
    return self.currTag
end

function CompeteChampionWallModel:GetCurrMatchType()
    return tonumber(self:GetCurrTag())
end

function CompeteChampionWallModel:GetCurrGroup()
    if self.currTag == tostring(CompeteSchedule.Big_Ear_Match) then
        return self:GetCurrBigEarGroup()
    elseif self.currTag == tostring(CompeteSchedule.Small_Ear_Match) then
        return self:GetCurrSmallEarGroup()
    end
end

function CompeteChampionWallModel:SetCurrGroup(group)
    if self.currTag == tostring(CompeteSchedule.Big_Ear_Match) then
        self:SetCurrBigEarGroup(group)
    elseif self.currTag == tostring(CompeteSchedule.Small_Ear_Match) then
        self:SetCurrSmallEarGroup(group)
    end
end

function CompeteChampionWallModel:SetCurrBigEarGroup(group)
    self.currBigEarGroup = group
end

function CompeteChampionWallModel:GetCurrBigEarGroup()
    return self.currBigEarGroup or 1
end

function CompeteChampionWallModel:SetCurrSmallEarGroup(group)
    self.currSmallEarGroup = group
end

function CompeteChampionWallModel:GetCurrSmallEarGroup()
    return self.currSmallEarGroup or 1
end

function CompeteChampionWallModel:SetCurrFixIdx(fixIdx)
    if self.currFixIdx ~= nil then
        self:SetSelectByFixIdx(self.currFixIdx, false)
    end
    self.currFixIdx = fixIdx
    if self.currFixIdx ~= nil then
        self:SetSelectByFixIdx(self.currFixIdx, true)
    end
end

function CompeteChampionWallModel:GetCurrFixIdx()
    return self.currFixIdx
end

function CompeteChampionWallModel:GetCurrIdx()
    local itemData = self:GetItemDataByFixIdx(self.currFixIdx)
    if itemData then
        return itemData.idx
    else
        return nil
    end
end

function CompeteChampionWallModel:IsCurrItemInCurrList()
    return self:IsItemInCurrList(self.currFixIdx)
end

function CompeteChampionWallModel:IsItemInCurrList(fixIdx)
    local itemData = self:GetItemDataByFixIdx(fixIdx)
    if itemData then
        return (not (self.currList[itemData.idx] ~= nil)) or self.currList[itemData.idx].fixIdx == fixIdx
    end
end

-- TO DO
function CompeteChampionWallModel:GetChampionList(tag, group)
    if group == nil then group = 1 end
    self.currList = {}
    local rawList = {}
    if tag == tostring(CompeteSchedule.Big_Ear_Match) then
        rawList = self.bigEarList
    elseif tag == tostring(CompeteSchedule.Small_Ear_Match) then
        rawList = self.smallEarList
    end
    for k, v in ipairs(rawList) do
        if v.group == group then
            table.insert(self.currList, v)
        end
    end
    return self.currList
end

function CompeteChampionWallModel:GetCurrChampionList()
    return self:GetChampionList(self:GetCurrTag(), self:GetCurrFilterVar())
end

function CompeteChampionWallModel:SetSelectByFixIdx(fixIdx, isSelect)
    if fixIdx ~= nil then
        local itemData = self:GetItemDataByFixIdx(fixIdx)
        if itemData then
            itemData.isSelect = isSelect
        end
    end
end

function CompeteChampionWallModel:GetCurrList()
    return self.currList
end

function CompeteChampionWallModel:GetFilterModel()
    if self.currTag == tostring(CompeteSchedule.Big_Ear_Match) then
        return self:GetBigEarFilterModel()
    elseif self.currTag == tostring(CompeteSchedule.Small_Ear_Match) then
        return self:GetSmallEarFilterModel()
    end
end

function CompeteChampionWallModel:GetBigEarFilterModel()
    return FilterModel.BigEar
end

function CompeteChampionWallModel:GetSmallEarFilterModel()
    return FilterModel.SmallEar
end

function CompeteChampionWallModel:GetCurrFilterVar()
    local filterModel = self:GetFilterModel()
    if filterModel ~= nil then
        if filterModel[self.FilterTypeGroup][tonumber(self:GetCurrGroup())] ~= nil then
            return filterModel[self.FilterTypeGroup][tonumber(self:GetCurrGroup())].filterVar
        else
            return -1
        end
    end
end

function CompeteChampionWallModel:GetOverviewModel()
    local overviewModel = OverviewModel.new()
    overviewModel:InitWithParent(self.bigEarOverviewList, self.smallEarOverviewList)
    return overviewModel
end

return CompeteChampionWallModel

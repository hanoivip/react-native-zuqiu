local CrossContentOrder = require("ui.scene.compete.cross.CrossContentOrder")
local CompeteFrameModel = require("ui.models.compete.main.CompeteFrameModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CompeteSchedule = require("ui.models.compete.main.CompeteSchedule")
local CompeteGuessSchedule = require("ui.models.compete.guess.CompeteGuessSchedule")
local Model = require("ui.models.Model")

local CompeteMainModel = class(Model, "CompeteMainModel")

function CompeteMainModel:ctor()
    CompeteMainModel.super.ctor(self)
    local playerInfoModel = PlayerInfoModel.new()
    self.playerId = playerInfoModel:GetID()
end

function CompeteMainModel:Init(data)
    self.data = data or {}
end

function CompeteMainModel:InitWithProtocol(data)
    assert(type(data) == "table")
    self:Init(data)
    self:InitMatchFrameModel()
    self:SetSortBorderData(data.sortBorder)
    self:InitMatchTypes()
end

function CompeteMainModel:GetMatchData()
    return self.data.matchList or {}
end

function CompeteMainModel:InitMatchFrameModel()
    local matchList = self:GetMatchData()
    self.competeFrameModels = {}
    for i, v in ipairs(matchList) do
        local competeFrameModel = CompeteFrameModel.new()
        competeFrameModel:Init(v)
        competeFrameModel:SetRoleId(self.playerId)
        table.insert(self.competeFrameModels, competeFrameModel)
    end
    table.sort(self.competeFrameModels, function(aModel, bModel)
        local aTime = aModel:GetBeginTime()
        local bTime = bModel:GetBeginTime()

        if aModel ~= bModel and aTime == bTime then 
            local aStatus = aModel:GetStatus()
            local bStatus = bModel:GetStatus()
            return aStatus > bStatus
        else
            return tonumber(aTime) < tonumber(bTime)
        end
    end)
    -- sort round
    local sort = {}
    for i, model in ipairs(self.competeFrameModels) do
        local matchType = model:GetMatchType()
        local currentRound = sort[matchType]
        local nextRound = 1
        if currentRound then 
            nextRound = currentRound + 1
        end
        sort[matchType] = nextRound
        model:SortMatchRound(nextRound)
    end
end

function CompeteMainModel:GetMatchFrameModel()
    return self.competeFrameModels
end

function CompeteMainModel:IsFirstFrame(index)
    return tobool(index == 1)
end

function CompeteMainModel:IsMidFrame(index)
    local matchList = self:GetMatchData()
    local totalCompeteMatch = #matchList
    return tobool(index > 1 and index < totalCompeteMatch)
end

function CompeteMainModel:IsFinalFrame(index)
    local matchList = self:GetMatchData()
    local totalCompeteMatch = #matchList
    return tobool(index == totalCompeteMatch)
end

-- 获取比赛第几轮
function CompeteMainModel:GetProgress()
    local competeFrameModels = self:GetMatchFrameModel()
    local progress = 0
    for i, CompeteFrameModel in ipairs(competeFrameModels) do
        if CompeteFrameModel:IsNotOpenMatch() then 
            progress = i - 1
            break
        elseif CompeteFrameModel:IsMatching() or CompeteFrameModel:IsWaitMatch() then
            progress = i
            break
        elseif CompeteFrameModel:IsMatchOver() then
            progress = i
        end
    end
    return progress
end

function CompeteMainModel:GetNextMatchIndex()
    local index = 1
    local maxNum = table.nums(self.competeFrameModels)
    for i, model in ipairs(self.competeFrameModels) do
        if model:IsMatching() or model:IsWaitMatch() then 
            index = i
            break
        elseif model:IsNotOpenMatch() then 
            index = i - 1
            break
        elseif i == maxNum then 
            index = i
        end
    end
    if index <= 0 then index = 1 end
    return index
end

local MatchTypeIndex = 
{
    CrossContentOrder.UniverseSortOrder[CrossContentOrder.Universe_Knockout],
    CrossContentOrder.UniverseSortOrder[CrossContentOrder.Universe_Team],
    CrossContentOrder.UniverseSortOrder[CrossContentOrder.Universe_Additional],
    CrossContentOrder.GalaxySortOrder[CrossContentOrder.Galaxy_Knockout],
    CrossContentOrder.GalaxySortOrder[CrossContentOrder.Galaxy_Team],
    CrossContentOrder.GalaxySortOrder[CrossContentOrder.Galaxy_Additional],
}
-- 获取当前所处界面（赛程调整至当前界面）
function CompeteMainModel:GetCurrentPageIndex()
    local nextMatchIndex = self:GetNextMatchIndex()
    local competeFrameModel = self.competeFrameModels[nextMatchIndex]
    if competeFrameModel then
        local matchType = competeFrameModel:GetMatchType()
        nextMatchIndex = MatchTypeIndex[tonumber(matchType)] or 1
    end
    return nextMatchIndex
end

-- 获取赛季数据
function CompeteMainModel:GetMatchSeason()
    return self.data.season or ""
end

function CompeteMainModel:SetSortBorderData(sortBorderData)
    self.sortBorderData = sortBorderData
end

function CompeteMainModel:CheckIsShowSortBorder()
    local isHasData = self.sortBorderData and self.sortBorderData[tostring(CompeteSchedule.Big_Ear_Match)] and self.sortBorderData[tostring(CompeteSchedule.Small_Ear_Match)]
    if isHasData then
        local isToDayShow = self:GetToDayShowState()
        if isToDayShow then
            return true
        else
            return false
        end
    end
    return false
end

function CompeteMainModel:GetBigEarSortBorder()
    local bigEarData = self.sortBorderData[tostring(CompeteSchedule.Big_Ear_Match)]
    table.sort(bigEarData, function(a, b)
        return a.subType > b.subType
    end)
    return bigEarData
end

function CompeteMainModel:GetSmallEarSortBorder()
    local smallEarData = self.sortBorderData[tostring(CompeteSchedule.Small_Ear_Match)]

    table.sort(smallEarData, function(a, b)
        return a.subType > b.subType
    end)
    return smallEarData
end

function CompeteMainModel:SetToDayShowState()
    local date = os.date("%Y-%m-%d", os.time())
    cache.setCompeteSortBorderDaily(date)
end

function CompeteMainModel:GetToDayShowState()
    local cacheDaily = cache.getCompeteSortBorderDaily()
    local date = os.date("%Y-%m-%d", os.time())
    return cacheDaily ~= date
end

function CompeteMainModel:GetSeasonID()
    return self.sortBorderData.season
end

-- 判断是否显示竞猜确认弹板
function CompeteMainModel:CheckShowGuessConfirm()
    if not self.matchTypes then
        self:InitMatchTypes()
    end
    local isBigEar = 0 -- 是否有大耳朵杯
    local isSmallEar = 0 -- 是否有小耳朵杯
    if self.matchTypes ~= nil and table.nums(self.matchTypes) > 0 then
        for k, v in pairs(self.matchTypes) do
            if v >= CompeteSchedule.Big_Ear_Match and v <= CompeteSchedule.Big_Ear_Match_Kick_Off then
                isBigEar = 1
            elseif v >= CompeteSchedule.Small_Ear_Match and v <= CompeteSchedule.Small_Ear_Match_Kick_Off then
                isSmallEar = 1
            end
        end
    end
    return tonumber(self:GetCurrSeasonGuessConfirm()) == CompeteGuessSchedule.Confirm.noconfirm and (isBigEar + isSmallEar) == 1
end

function CompeteMainModel:InitMatchTypes()
    self.matchTypes = self:GetMatchTypes()
end

function CompeteMainModel:GetMatchTypes()
    local matchTypes = {}
    if self.data.matchList ~= nil and table.nums(self.data.matchList) > 0 then
        for k, match in pairs(self.data.matchList) do
            matchTypes[tostring(match.matchType)] = match.matchType
        end
    end
    return matchTypes
end

function CompeteMainModel:GetGuessConfirm()
    return self.data.guessConfirm
end

function CompeteMainModel:GetCurrSeasonGuessConfirm()
    return self:GetGuessConfirm() and self:GetGuessConfirm()[self:GetMatchSeason()]
end

-- 获得确认竞猜参与奖励
function CompeteMainModel:GetGuessData()
    local guessData = {}
    guessData.guessConfirm = self.data.guessConfirm
    guessData.guessReward = self.data.guessReward
    guessData.season = self.data.season
    guessData.matchTypes = self:GetMatchTypes()
    return guessData
end

return CompeteMainModel
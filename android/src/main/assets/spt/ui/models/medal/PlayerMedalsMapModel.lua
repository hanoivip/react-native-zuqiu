local EventSystem = require ("EventSystem")
local PlayerMedalModel = require("ui.models.medal.PlayerMedalModel")
local Model = require("ui.models.Model")
local PlayerMedalsMapModel = class(Model, "PlayerMedalsMapModel")

function PlayerMedalsMapModel:ctor()
    PlayerMedalsMapModel.super.ctor(self)
end

function PlayerMedalsMapModel:Init(data)
    if not data then
        data = cache.getPlayerMedalsMap() or {}
    end
    self.data = data
end

function PlayerMedalsMapModel:InitWithProtocol(data)
    local medalsMap = {}
    if data then 
        medalsMap = data
    end
    cache.setPlayerMedalsMap(medalsMap)
    self:Init(medalsMap)
end

-- 重置某一个球员勋章的model数据 返回勋章是否改变了
function PlayerMedalsMapModel:ResetMedalData(pmid, data)
    assert(type(data) == "table")

    pmid = tostring(pmid)
    local bChange = false
    if self.data[pmid] and self.data[pmid].medalId ~= data.medalId then
        bChange = true
    end
    self.data[tostring(pmid)] = data

    EventSystem.SendEvent("MedalsMapModel_ResetMedalModel", pmid)
    return bChange
end

-- 添加一张球员勋章
function PlayerMedalsMapModel:AddMedalData(pmid, data)
    assert(pmid and data and self.data[tostring(pmid)] == nil)
    data.isNew = true
    self.data[tostring(pmid)] = data
    EventSystem.SendEvent("MedalsMapModel_AddMedalData", pmid)
end

-- 设置new缓存
function PlayerMedalsMapModel:SetMedalNew(pmid, isNew)
    assert(pmid and self.data[tostring(pmid)] ~= nil)

    self.data[tostring(pmid)].isNew = isNew
end

-- 删除一个球员勋章数据
function PlayerMedalsMapModel:RemoveMedalData(pmid)
    self.data[tostring(pmid)] = nil

    EventSystem.SendEvent("MedalsMapModel_RemoveMedalData", pmid)
end

-- 删除一组球员勋章数据
function PlayerMedalsMapModel:RemoveMedalsData(pmids)
    for i, pmid in ipairs(pmids) do
        self.data[tostring(pmid)] = nil
    end

    EventSystem.SendEvent("MedalsMapModel_RemoveMedalsData", pmids)
end

-- 获取某个球员贴纸的碎片数据
function PlayerMedalsMapModel:GetMedalData(pmid)
    return self.data[tostring(pmid)]
end

function PlayerMedalsMapModel:GetMedalMap()
    return self.data
end

local function sortMedalAsc(Medal)
    table.sort(Medal, function(a, b) 
        if a:GetQuality() == b:GetQuality() then 
            return tonumber(a:GetMedalId()) > tonumber(b:GetMedalId())
        else
            return tonumber(a:GetQuality()) > tonumber(b:GetQuality())
        end
    end)
end

function PlayerMedalsMapModel:GetSameTypeMedalMap(medalType)
    local sameTypeMedal = {}
    for pmid, v in pairs(self.data) do
        local playerMedalModel = PlayerMedalModel.new(v.pmid)
        playerMedalModel:InitWithCache(v)
        if tonumber(playerMedalModel:GetMedalType()) == tonumber(medalType) then 
            table.insert(sameTypeMedal, playerMedalModel)
        end
    end
    sortMedalAsc(sameTypeMedal)
    return sameTypeMedal
end

function PlayerMedalsMapModel:GetAllMedalMap()
    local allMedal = {}
    for pmid, v in pairs(self.data) do
        local playerMedalModel = PlayerMedalModel.new(v.pmid)
        playerMedalModel:InitWithCache(v)
        table.insert(allMedal, playerMedalModel)
    end
    sortMedalAsc(allMedal)
    return allMedal
end

function PlayerMedalsMapModel:GetSingleMedalModel(pmid)
    local playerMedalModel = PlayerMedalModel.new(pmid)
    local medalData = self:GetMedalData(pmid)
    playerMedalModel:InitWithCache(medalData)
    return playerMedalModel
end

function PlayerMedalsMapModel:UpdateFromReward(rewardTable)
    assert(rewardTable and type(rewardTable) == "table")
    if not rewardTable.medal then return end

    for i, v in ipairs(rewardTable.medal) do
        self:AddMedalData(v.pmid, v)
    end

    EventSystem.SendEvent("MedalsMapModel_UpdateFromReward")
end

function PlayerMedalsMapModel:GetMedalByQuality(qualitys)
    local selectMedal = {}
    for pmid, v in pairs(self.data) do
        local playerMedalModel = PlayerMedalModel.new(v.pmid)
        playerMedalModel:InitWithCache(v)
        local quality = playerMedalModel:GetQuality() 
        if qualitys[tostring(quality)] then 
            table.insert(selectMedal, playerMedalModel)
        end
    end
    return selectMedal
end

return PlayerMedalsMapModel

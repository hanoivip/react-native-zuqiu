local EventSystem = require ("EventSystem")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local CardPasterModel = require("ui.models.cardDetail.CardPasterModel")
local Card = require("data.Card")
local Model = require("ui.models.Model")
local CardPastersMapModel = class(Model, "CardPastersMapModel")

function CardPastersMapModel:ctor(playerCardsMapModel)
    CardPastersMapModel.super.ctor(self)
    self.playerCardsMapModel = playerCardsMapModel or PlayerCardsMapModel.new()
end

function CardPastersMapModel:Init(data)
    if not data then
        data = cache.getPlayerPastersMap() or {}
    end
    self.data = data
end

function CardPastersMapModel:InitWithProtocol(data)
    local pastersMap = {}
    if data then 
        for i, v in ipairs(data) do
            pastersMap[tostring(v.ptid)] = v
        end
    end
    cache.setPlayerPastersMap(pastersMap)
    self:Init(pastersMap)
end

-- 重置某一个球员贴纸的model数据
function CardPastersMapModel:ResetPasterData(ptid, data)
    assert(type(data) == "table")
    self.data[tostring(ptid)] = data

    EventSystem.SendEvent("CardPastersMapModel_ResetPasterModel", ptid)
end

-- 添加一张球员贴纸
function CardPastersMapModel:AddPasterData(ptid, data)
    assert(ptid and data and self.data[tostring(ptid)] == nil)
    self.data[tostring(ptid)] = data

    EventSystem.SendEvent("CardPastersMapModel_AddPasterData", ptid)
end

-- 删除一个球员贴纸数据(使用在对应球员身上)
function CardPastersMapModel:RemovePasterData(ptid)
    self.data[tostring(ptid)] = nil

    EventSystem.SendEvent("CardPastersMapModel_RemovePasterData", ptid)
end

-- 删除一组球员贴纸数据(使用在对应球员身上)
function CardPastersMapModel:RemovePastersData(ptids)
    local ptidsMap = {}
    for i, ptid in ipairs(ptids) do
        self.data[tostring(ptid)] = nil
    end

    EventSystem.SendEvent("CardPastersMapModel_RemovePastersData", ptids)
end

-- 获取某个球员的贴纸数据
function CardPastersMapModel:GetPasterData(ptid)
    return self.data[tostring(ptid)]
end

function CardPastersMapModel:GetPasterMap()
    return self.data
end

function CardPastersMapModel:GetPasterNum(ptid)
    local pasterData = self:GetPasterData(ptid)
    return pasterData and tonumber(pasterData.num) or 0
end

function CardPastersMapModel:UpdateFromReward(rewardTable)
    assert(rewardTable and type(rewardTable) == "table")
    if not rewardTable.paster then return end

    for i, v in ipairs(rewardTable.paster) do
        self:ResetPasterData(v.ptid, v)
    end

    EventSystem.SendEvent("CardPastersMapModel_UpdateFromReward")
end

-- 使用荣耀贴纸所有球员都可以用不算标记
function CardPastersMapModel:HasPasterAvailable(cid, existPasterIds, skillsData)
    local hasPaster, hasPasterUsedByAll = false, false
    if not next(self.data) then return hasPaster, hasPasterUsedByAll end

    local skillsMap = {}
    if skillsData then
        for k, v in ipairs(skillsData) do
            skillsMap[v.sid] = true
        end
    elseif Card[cid] then
        local skills = Card[cid].skill or {}
        for k, sid in ipairs(skills) do
            skillsMap[sid] = true
        end
    end

    for ptid, v in pairs(self.data) do
        local cardPasterModel = CardPasterModel.new(ptid)
        cardPasterModel:InitWithCache(v)
        if cardPasterModel:GetPasterUsedByAll() then
            -- 争霸贴纸特殊处理，有相应加成技能才判断为可用
            if cardPasterModel:IsCompetePaster() then
                local competeSid = cardPasterModel:GetCompetePasterSkill()
                if skillsMap[competeSid] then
                    hasPasterUsedByAll = true
                end
            else
                hasPasterUsedByAll = true
            end
        else
            local isSamePaster = false
            if existPasterIds then
                local ptcid = cardPasterModel:GetPasterId()
                for i, data in ipairs(existPasterIds) do
                    if data.ptcid == ptcid then
                        isSamePaster = true
                        break
                    end
                end
            end
            if not isSamePaster then
                if cardPasterModel:IsPasterUsedByPosition() then -- 同位置球员可用贴纸
                    local availablePositions = cardPasterModel:GetPasterUsedByPosition()
                    local playerPositions = Card[cid].position
                    for i, availablePosition in ipairs(availablePositions) do
                        for i, playerPosition in ipairs(playerPositions) do
                            if playerPosition == availablePosition then
                                hasPaster = true
                            end
                        end
                    end
                else
                    local cardIDs = cardPasterModel:GetPasterUsedByCard() or {}
                    for i, availableCid in ipairs(cardIDs) do
                        if availableCid == cid then
                            hasPaster = true
                            return hasPaster, hasPasterUsedByAll
                        end
                    end
                end
            end
        end
    end
    return hasPaster, hasPasterUsedByAll
end

function CardPastersMapModel:GetPasterAvailableModel(cid, skills)
    local availableModel = {}
    local sidMapCache = {}
    for ptid, v in pairs(self.data) do
        local cardPasterModel = CardPasterModel.new(ptid)
        cardPasterModel:InitWithCache(v)
        if cardPasterModel:GetPasterUsedByAll() then
            -- 争霸贴纸特殊处理，有相应加成技能才显示在选择装配界面
            if cardPasterModel:IsCompetePaster() then
                local competeSid = cardPasterModel:GetCompetePasterSkill()
                local hasSkill = false
                if sidMapCache[competeSid] ~= nil then
                    hasSkill = true
                else
                    for k, v in pairs(skills) do
                        if v.sid == competeSid then
                            hasSkill = true
                            sidMapCache[competeSid] = true
                            break
                        end
                    end
                end
                if hasSkill then table.insert(availableModel, cardPasterModel) end
            else
                table.insert(availableModel, cardPasterModel)
            end
        elseif cardPasterModel:IsPasterUsedByPosition() then -- 同位置球员可用贴纸
            local availablePositions = cardPasterModel:GetPasterUsedByPosition()
            local playerPositions = Card[cid].position
            local canUse = false
            for i, availablePosition in ipairs(availablePositions) do
                for i, playerPosition in ipairs(playerPositions) do
                    if playerPosition == availablePosition then
                        table.insert(availableModel, cardPasterModel)
                        canUse = true
                        break
                    end
                end
                if canUse then
                    break
                end
            end
        else
            local cardIDs = cardPasterModel:GetPasterUsedByCard() or {}
            for i, availableCid in ipairs(cardIDs) do 
                if availableCid == cid then 
                    table.insert(availableModel, cardPasterModel)
                    break
                end
            end
        end
    end
    return availableModel
end

-- 是否有同样的贴纸(可使用所有球员的荣耀贴纸不作为相同贴纸)
function CardPastersMapModel:HasSamePaster(cardPasterModel)
    if cardPasterModel:GetPasterUsedByAll() then 
        return false
    end

    local ptcid = cardPasterModel:GetPasterId()
    self.data = cache.getPlayerPastersMap() or {}
    for ptid, v in pairs(self.data) do
        if tostring(ptid) ~= cardPasterModel:GetId() then 
            if tostring(v.ptcid) == tostring(ptcid) then 
                return true
            end
        end
    end

    local cardIDs = cardPasterModel:GetPasterUsedByCard()
    if type(cardIDs) == "table" then
        for i, cid in ipairs(cardIDs) do
            local isExist = self.playerCardsMapModel:IsExistPasterID(cid, ptcid)
            if isExist then 
                return true
            end
        end
    end

    return false
end

return CardPastersMapModel

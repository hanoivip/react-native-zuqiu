local EventSystem = require ("EventSystem")
local Model = require("ui.models.Model")
local DreamLeagueCard = require("data.DreamLeagueCard")
local PlayerDreamCardsMapModel = class(Model, "PlayerDreamCardsMapModel")

function PlayerDreamCardsMapModel:ctor()
    PlayerDreamCardsMapModel.super.ctor(self)
end

function PlayerDreamCardsMapModel:Init(data, dcidsMap)
    if not data then
        data = cache.getPlayerDreamCardsMap() or {}
    end
    self.data = data
    if not dcidsMap then
        dcidsMap = cache.getPlayerDcidsMap() or {}
    end
    self.dcidsMap = dcidsMap
end

-- dcidsMap 优化计算
function PlayerDreamCardsMapModel:InitWithProtocol(data)
    -- assert(type(data) == "table")
    if data then
        local dreamCardsMap = {}
        local dcidsMap = {}
        for i, v in pairs(data) do
            dreamCardsMap[tostring(v.dcid)] = v
            if not dcidsMap[v.dreamCardId] then 
                dcidsMap[v.dreamCardId] = {}
            end
            dcidsMap[v.dreamCardId][v.dcid] = true
        end
        cache.setPlayerDreamCardsMap(dreamCardsMap)
        cache.setPlayerDcidsMap(dcidsMap)
        self:Init(dreamCardsMap, dcidsMap)
    end
end

-- 重置某一个球员卡牌的model数据
function PlayerDreamCardsMapModel:ResetCardData(dcid, data)
    assert(type(data) == "table")
    self.data[tostring(dcid)] = data

    EventSystem.SendEvent("PlayerDreamCardsMapModel_ResetCardModel", dcid)
end

-- 重置某一个球员卡牌的lock数据
function PlayerDreamCardsMapModel:ResetCardLock(dcid, lock)
    assert(lock)
    self.data[tostring(dcid)].lock = lock
end

-- 添加一张球员卡牌
function PlayerDreamCardsMapModel:AddCardData(dcid, data)
    assert(dcid and data and self.data[tostring(dcid)] == nil)
    data.isNew = true
    self.data[tostring(dcid)] = data

    local dreamCardId = data.dreamCardId
    if not self.dcidsMap[dreamCardId] then
        self.dcidsMap[dreamCardId] = {}
    end
    self.dcidsMap[dreamCardId][tostring(dcid)] = true

    EventSystem.SendEvent("PlayerDreamCardsMapModel_AddCardData", dcid)
end

-- 删除一个球员卡牌数据
function PlayerDreamCardsMapModel:RemoveSingleCardData(dcid)
    self.data[tostring(dcid)] = nil
    for dreamCardId, v in pairs(self.dcidsMap) do
        for k, data in pairs(v) do
            if k == tostring(dcid) then 
                self.dcidsMap[dreamCardId][dcid] = nil
            end
        end
    end
    EventSystem.SendEvent("PlayerDreamCardsMapModel_RemoveSingleCardData", dcid)
end

-- 删除一组球员卡牌数据
function PlayerDreamCardsMapModel:RemoveCardData(dcids)
    local dreamCardIdsMap = {}
    for i, dcid in ipairs(dcids) do
        dreamCardIdsMap[tostring(dcid)] = dcid
        self.data[tostring(dcid)] = nil
    end

    for dreamCardId, v in pairs(self.dcidsMap) do
        for dcid, data in pairs(v) do
            if dreamCardIdsMap[tostring(dcid)] then 
                self.dcidsMap[dreamCardId][dcid] = nil
            end
        end
    end
    EventSystem.SendEvent("PlayerDreamCardsMapModel_RemoveCardData", dcids)
end

-- 获取某个球员的卡牌数据
function PlayerDreamCardsMapModel:GetCardData(dcid)
    return self.data[tostring(dcid)]
end

-- 默认获取一个球员的卡牌数据
function PlayerDreamCardsMapModel:GetCarddreamCardIdDefault()
    for dreamCardId, v in pairs(self.data) do
        return dreamCardId
    end
end

function PlayerDreamCardsMapModel:GetCarddcidMaps()
    return self.dcidsMap
end

-- 返回一个由dcid组成的列表
function PlayerDreamCardsMapModel:GetCardList()
    local cardList = {}
    for dcid, v in pairs(self.data) do
        table.insert(cardList, dcid)
    end
    return cardList
end

-- 是否存在dreamCardId的卡牌
function PlayerDreamCardsMapModel:IsExistCardcid(dreamCardId)
    assert(dreamCardId)
    return tobool(self.dcidsMap[dreamCardId])
end

-- 返回相同dreamCardId的卡牌列表
function PlayerDreamCardsMapModel:GetSameCardList(dreamCardId)
    return self.dcidsMap[dreamCardId] or {}
end

-- 返回不同dreamCardId的卡牌列表
function PlayerDreamCardsMapModel:GetDifferenceCardList()
    local cardListMap = {}
    local cardList = {}
    for dcid, v in pairs(self.data) do
        if not cardListMap[v.dreamCardId] then 
            cardListMap[v.dreamCardId] = dcid
            table.insert(cardList, dcid)
        end
    end
    return cardList, cardListMap
end

-- 获取相同卡牌数目
function PlayerDreamCardsMapModel:GetSameCardNum(dreamCardId)
    local cardNum = 0
    for dcid, v in pairs(self.data) do
        if v.dreamCardId == dreamCardId then
            cardNum = cardNum + 1
        end
    end
    return cardNum
end

-- 奖励刷新
function PlayerDreamCardsMapModel:UpdateFromReward(rewardTable)
    assert(rewardTable and type(rewardTable) == "table")
    if not rewardTable.card then return end

    for i, v in ipairs(rewardTable.dreamCard) do
        self:AddCardData(v.dcid, v)
    end

    EventSystem.SendEvent("PlayerDreamCardsMapModel_UpdateFromReward")
end

function PlayerDreamCardsMapModel:GetDreamCardIdBydcid(dcid)
    dcid = tonumber(dcid)
    for k, v in pairs(self.data) do
        if v.dcid == dcid then
            return v.dreamCardId
        end
    end
    return nil
end

--获取球员是否是新获得的状态
function PlayerDreamCardsMapModel:GetCardNewTag(dcid)
    dcid = tostring(dcid)
    return self.data[dcid].isNew
end

--设置球员是否是新获得的状态
function PlayerDreamCardsMapModel:SetCardNewTag(dcid, newState)
    dcid = tostring(dcid)
    local tempData = self.data[dcid]
    if tempData then
        tempData.isNew = newState
    end
end

--设置球员卡的上锁状态
function PlayerDreamCardsMapModel:SetCardLockState(dcid, lockState)
    dcid = tostring(dcid)
    local tempData = self.data[dcid]
    if tempData then
        tempData.lock = lockState
    end
end

return PlayerDreamCardsMapModel

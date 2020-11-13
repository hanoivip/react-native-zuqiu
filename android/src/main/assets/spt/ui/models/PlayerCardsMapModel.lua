local EventSystem = require ("EventSystem")
local Model = require("ui.models.Model")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local PasterMainType = require("ui.scene.paster.PasterMainType")
-- static data 
local Card = require("data.Card")

local PlayerCardsMapModel = class(Model, "PlayerCardsMapModel")

PlayerCardsMapModel.ModelProtoMap = {
}

function PlayerCardsMapModel:ctor()
    PlayerCardsMapModel.super.ctor(self)
end

function PlayerCardsMapModel:Init(data, cidsMap)
    if not data then
        data = cache.getPlayerCardsMap() or {}
    end
    self.data = data
    if not cidsMap then
        cidsMap = cache.getPlayerCidsMap() or {}
    end
    self.cidsMap = cidsMap
end

-- cidsMap 优化计算
function PlayerCardsMapModel:InitWithProtocol(data)
    assert(type(data) == "table")
    local cardsMap = {}
    local cidsMap = {}
    for i, v in ipairs(data) do
        cardsMap[tostring(v.pcid)] = v
        if not cidsMap[v.cid] then 
            cidsMap[v.cid] = {}
        end
        cidsMap[v.cid][v.pcid] = true
    end
    cache.setPlayerCardsMap(cardsMap)
    cache.setPlayerCidsMap(cidsMap)
    self:Init(cardsMap, cidsMap)
end

-- 重置某一个球员卡牌的model数据
function PlayerCardsMapModel:ResetCardData(pcid, data, noEvent)
    assert(type(data) == "table")
    self.data[tostring(pcid)] = data

    if noEvent then
        return
    end
    EventSystem.SendEvent("PlayerCardsMapModel_ResetCardModel", pcid)
end

-- 重置某一个球员卡牌的lock数据
function PlayerCardsMapModel:ResetCardLock(pcid, lock)
    assert(lock)
    self.data[tostring(pcid)].lock = lock
end

function PlayerCardsMapModel:ResetCardSkillData(pcid, skillPoint, skillsData)
    assert(self.data[tostring(pcid)])
    self.data[tostring(pcid)].skillPoint = skillPoint
    self.data[tostring(pcid)].skills = skillsData

    EventSystem.SendEvent("PlayerCardsMapModel_ResetCardSkillData", pcid)

    -- 球员殿堂即时更新
    local heroHallMapModel = require("ui.models.heroHall.main.HeroHallMapModel").new()
    heroHallMapModel:UpdateQualityImproveByPcid(pcid)
    heroHallMapModel:UpdateUpgradeImproveByPcid(pcid)
    heroHallMapModel:UpdateAscendImproveByPcid(pcid)
    heroHallMapModel:UpdateTrainingBaseImproveByPcid(pcid)
end

function PlayerCardsMapModel:ResetCardLevelData(pcid, level, exp)
    assert(self.data[tostring(pcid)])
    self.data[tostring(pcid)].lvl = level
    self.data[tostring(pcid)].exp = exp

    EventSystem.SendEvent("PlayerCardsMapModel_ResetCardLevelData", pcid)
end

function PlayerCardsMapModel:ResetCardTrainingLevel(pcid, trainId)
    assert(self.data[tostring(pcid)])
    self.data[tostring(pcid)].trainId = trainId

    EventSystem.SendEvent("PlayerCardsMapModel_ResetCardTrainingLevel", pcid)
end

-- 添加一张球员卡牌
function PlayerCardsMapModel:AddCardData(pcid, data)
    assert(pcid and data and self.data[tostring(pcid)] == nil)
    self.data[tostring(pcid)] = data

    local cid = data.cid
    if not self.cidsMap[cid] then
        self.cidsMap[cid] = {}
    end
    self.cidsMap[cid][tostring(pcid)] = true

    EventSystem.SendEvent("PlayerCardsMapModel_AddCardData", pcid)

    -- 球员殿堂即时更新
    local heroHallMapModel = require("ui.models.heroHall.main.HeroHallMapModel").new()
    heroHallMapModel:UpdateQualityImproveByPcid(pcid)
end

-- 删除一组球员卡牌数据
function PlayerCardsMapModel:RemoveCardData(pcids)
    -- 球员殿堂即时更新
    local heroHallMapModel = require("ui.models.heroHall.main.HeroHallMapModel").new()
    local hallIDs = heroHallMapModel:GetHallIDsByPcids(pcids)

    local pcidsMap = {}
    for i, pcid in ipairs(pcids) do
        pcidsMap[tostring(pcid)] = pcid
        self.data[tostring(pcid)] = nil
    end

    for cid, v in pairs(self.cidsMap) do
        for pcid, data in pairs(v) do
            if pcidsMap[tostring(pcid)] then 
                self.cidsMap[cid][pcid] = nil
            end
        end
    end
    EventSystem.SendEvent("PlayerCardsMapModel_RemoveCardData", pcids)

    for baseID, list in pairs(hallIDs) do
        for k, hallID in pairs(list) do
            heroHallMapModel:UpdateQualityImprove(hallID, baseID)
            heroHallMapModel:UpdateUpgradeImprove(hallID, baseID)
            heroHallMapModel:UpdateAscendImprove(hallID, baseID)
            heroHallMapModel:UpdateTrainingBaseImprove(hallID, baseID)
        end
    end
end

-- 获取某个球员的卡牌数据
function PlayerCardsMapModel:GetCardData(pcid)
    return self.data[tostring(pcid)]
end

-- 默认获取一个球员的卡牌数据
function PlayerCardsMapModel:GetCardPcidDefault()
    for pcid, v in pairs(self.data) do
        return pcid
    end
end

function PlayerCardsMapModel:GetCardCidMaps()
    return self.cidsMap
end

-- 返回一个由pcid组成的列表
function PlayerCardsMapModel:GetCardList()
    local cardList = {}
    for pcid, v in pairs(self.data) do
        table.insert(cardList, pcid)
    end
    return cardList
end

-- 是否存在baseID的卡牌
function PlayerCardsMapModel:IsExistCardBaseID(baseID)
    assert(baseID)
    for pcid, v in pairs(self.data) do
        if Card[tostring(v.cid)].baseID == baseID then
            return true
        end
    end
    return false
end

-- 是否存在cid的卡牌
function PlayerCardsMapModel:IsExistCardID(cid)
    assert(cid)
    return tobool(self.cidsMap[cid])
end

-- 返回相同cid的卡牌列表
function PlayerCardsMapModel:GetSameCardList(cid)
    return self.cidsMap[cid] or {}
end

-- 返回不同cid的卡牌列表
function PlayerCardsMapModel:GetDifferenceCardList()
    local cardListMap = {}
    local cardList = {}
    for pcid, v in pairs(self.data) do
        if not cardListMap[v.cid] then 
            cardListMap[v.cid] = pcid
            table.insert(cardList, pcid)
        end
    end
    return cardList, cardListMap
end

-- 获取相同卡牌数目
function PlayerCardsMapModel:GetSameCardNum(cid)
    local cardNum = 0
    for pcid, v in pairs(self.data) do
        if v.cid == cid then
            cardNum = cardNum + 1
        end
    end
    return cardNum
end

function PlayerCardsMapModel:WearEquipForCard(pcid, slot)
    local equips = self.data[tostring(pcid)].equips
    for i, v in ipairs(equips) do
        if tostring(slot) == tostring(v.slot) then
            v.isEquip = true
            EventSystem.SendEvent("PlayerCardsMapModel_WearEquipForCard", pcid, slot)
            return
        end
    end
end

function PlayerCardsMapModel:UpdateFromReward(rewardTable)
    assert(rewardTable and type(rewardTable) == "table")
    if not rewardTable.card then return end

    for i, v in ipairs(rewardTable.card) do
        self:AddCardData(v.pcid, v)
    end

    EventSystem.SendEvent("PlayerCardsMapModel_UpdateFromReward")
end

function PlayerCardsMapModel:GetPcidByCid(cid)
    local pcid = nil
    local cardLevel = 0
    for k, v in pairs(self.data) do
        if v.cid == cid and v.lvl > cardLevel then
            pcid = k
            cardLevel = v.lvl
        end
    end
    return pcid
end

function PlayerCardsMapModel:IsHighestReborn(cid)
    local cardList = self:GetSameCardList(cid)
    local ascends = require("ui.models.cardDetail.StaticCardModel").new(cid):GetMaxAscendNum()
    local sameCardList = {}
    if cardList and next(cardList) then
        for k, v in pairs(cardList) do 
            table.insert(sameCardList,self:GetCardData(k).ascend)
        end
    else 
        return false
    end
    table.sort(sameCardList, function(a, b) return a > b end)
    local maxReborn = sameCardList[1]
    local cardNum = #sameCardList
    local index = maxReborn + cardNum - 1 
    local falg = index >= ascends
    if ascends == 0 then
        return false
    elseif falg then
        return true
    else
        return false
    end
end

-- 是否在球员身上有需要的贴纸
function PlayerCardsMapModel:IsExistPasterID(cid, pasterId)
    local pcidsMap = self:GetSameCardList(cid)
    for pcid, v in pairs(pcidsMap) do
        local data = self:GetCardData(pcid)
        local pasterData = data.paster or {}
        for m, n in ipairs(pasterData) do
            if tostring(n.ptcid) == tostring(pasterId) then 
                return true
            end
        end
    end
    return false
end

-- 根据球员baseId获得玩家身上该球员多品质的cidsMap
function PlayerCardsMapModel:GetCidsMapByBaseID(baseID)
    local cids = {}
    for pcid, v in pairs(self.data) do
        if Card[tostring(v.cid)].baseID == baseID then
            cids[v.cid] = self.cidsMap[v.cid]
        end
    end
    if table.nums(cids) > 0 then
        return cids
    else
        return nil
    end
end

-- 根据球员baseId获得球员名字
function PlayerCardsMapModel:GetCardNameByBaseID(baseID)
    for cid, v in pairs(Card) do
        if v.baseID == baseID then
            return v.name2
        end
    end
end

-- 根据球员baseId获得配置表中【投放或未投放】的该球员最大品质的cid，默认投放
function PlayerCardsMapModel:GetMaxQualityCidByBaseID(baseID, valid)
    if valid == nil then
        valid = 1
    end

    local cids = {}
    for cid, v in pairs(Card) do
        if v.baseID == baseID and v.valid == valid then
            local temp = {}
            temp.cid = v.ID
            temp.fixQuality = CardHelper.GetCardFixQualityNum(v.quality, v.qualitySpecial)
            table.insert(cids, temp)
        end
    end

    if table.nums(cids) > 0 then
        table.sort(cids, function(a, b)
            return a.fixQuality > b.fixQuality
        end)
        return cids[1].cid
    else
        return nil
    end
end

-- 英雄殿堂技能等级更新
function PlayerCardsMapModel:UpdateCardSkillHeroHall(cid, hlvl)
    local pcids = self:GetSameCardList(cid)
    for pcid, v in pairs(pcids) do
        self:UpdateCardSkillHeroHallByPcid(pcid, hlvl)
    end
end

function PlayerCardsMapModel:UpdateCardSkillHeroHallByPcid(pcid, hlvl)
    for k, v in pairs(self.data[tostring(pcid)].skills) do
        if v.pType ~= nil then-- 贴纸技能筛选
            if PasterMainType.CanPasterSkillUpgrade(v.pType) then
                v.hlvl = hlvl
            end
        else-- 其它技能均增加
            v.hlvl = hlvl
        end
    end
end

return PlayerCardsMapModel

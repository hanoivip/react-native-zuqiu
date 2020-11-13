local Model = require("ui.models.Model")
local HeroHallEffectType = require("ui.models.heroHall.main.HeroHallEffectType")
local HeroHallDataModel = require("ui.models.heroHall.main.HeroHallDataModel")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local FootballHall = require("data.FootballHall")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local AttributeType = require("ui.models.heroHall.main.HeroHallAttributeType")
local ImproveType = require("ui.models.heroHall.main.HeroHallImproveType")
local Card = require("data.Card")
local Nation = require("data.Nation")

local HeroHallMapModel = class(Model, "HeroHallMapModel")

function HeroHallMapModel:ctor()
    HeroHallMapModel.super.ctor(self)

    self.heroHallDataModel = HeroHallDataModel.new()
    self.playerCardsMapModel = PlayerCardsMapModel.new()
end

function HeroHallMapModel:Init(footballHall, heroHallEffectMap, herohallAttrsMap)
    -- 原始数据
    if not footballHall then
        self.footballHall = cache.getPlayerFootballHall() or {}
    else
        self.footballHall = footballHall
    end
    -- cid与激活殿堂列表map
    if not heroHallEffectMap then
        self.heroHallEffectMap = cache.getPlayerHeroHallEffectMap() or {}
    else
        self.heroHallEffectMap = heroHallEffectMap
    end
    -- 殿堂id与目前增益属性
    if not herohallAttrsMap then
        self.herohallAttrsMap = cache.getPlayerHeroHallAttrsMap() or {}
    else
        self.herohallAttrsMap = herohallAttrsMap
    end
end

-- heroHallEffectMap 优化计算
function HeroHallMapModel:InitWithProtocol(footballHall)
    self.playerCardsMapModel:Init()
    if type(footballHall) == "table" then
        local heroHallEffectMap = {}
        local herohallAttrsMap = {}
        for hallID, hallData in pairs(footballHall) do
            if hallData.activate == 1 then        -- 雕像已激活
                local cidList = self:GetEffectCidList(hallID)
                self:MergeCidListToMap(heroHallEffectMap, cidList, hallID)
                herohallAttrsMap[hallID] = self.heroHallDataModel:GetHallAttributes(hallID, hallData)
            end
        end

        cache.setPlayerFootballHall(footballHall)
        cache.setPlayerHeroHallEffectMap(heroHallEffectMap)
        cache.setPlayerHeroHallAttrsMap(herohallAttrsMap)
        self:Init(footballHall, heroHallEffectMap, herohallAttrsMap)
    end
end

function HeroHallMapModel:GetHeroHallMap()
    return self.heroHallEffectMap
end

function HeroHallMapModel:GetHallIDListByCid(cid)
    return self.heroHallEffectMap[cid]
end

-- 根据cid获得该卡牌所有殿堂属性加成
function HeroHallMapModel:GetHallAttrByCid(cid)
    local attrs = {}
    if self:CheckExist(cid) then
        for hallID, v in pairs(self.heroHallEffectMap[cid]) do
            if self.herohallAttrsMap[hallID] ~= nil then
                local tempAttrs = self.herohallAttrsMap[hallID]
                for attrName, attrValue in pairs(tempAttrs) do
                    if not attrs[attrName] then
                        attrs[attrName] = 0
                    end
                    attrs[attrName] = attrs[attrName] + attrValue
                end
            end
        end
    end
    return attrs
end

-- 该卡牌是否有殿堂加成
function HeroHallMapModel:CheckExist(cid)
    return self.heroHallEffectMap[cid] ~= nil
end

-- 在【获得卡牌】、【删除卡牌】后更新当前球员与品质相关的额外属性加成
function HeroHallMapModel:UpdateQualityImproveByPcid(pcid)
    local cardModel = require("ui.models.cardDetail.PlayerCardModel").new(pcid)
    local baseID = cardModel:GetBaseID()
    self:UpdateQualityImproveByBaseID(baseID)
end

function HeroHallMapModel:UpdateQualityImproveByCid(cid)
    local cardModel = require("ui.models.cardDetail.StaticCardModel").new(cid)
    local baseID = cardModel:GetBaseID()
    self:UpdateQualityImproveByBaseID(baseID)
end

function HeroHallMapModel:UpdateQualityImproveByBaseID(baseID)
    local isStatueCard, hallIDList = self.heroHallDataModel:IsStatueCard(baseID)
    if isStatueCard then
        for k, hallID in pairs(hallIDList) do
            self:UpdateQualityImprove(hallID, baseID)
        end
    end
end

function HeroHallMapModel:UpdateQualityImprove(hallID, baseID)
    if not self.footballHall[hallID] then
        return
    end
    if self.footballHall[hallID].activate == 1 then
        local SimpleCardModel = require("ui.models.cardDetail.SimpleCardModel")
        local statueData = self.footballHall[hallID].list[baseID]
        local cidsMap = self.playerCardsMapModel:GetCidsMapByBaseID(baseID)
        if cidsMap ~= nil then
            local cardModelList = {}
            for cid, pcids in pairs(cidsMap) do
                for pcid, v in pairs(pcids) do
                    local tempCardModel = SimpleCardModel.new(pcid)
                    table.insert(cardModelList, tempCardModel)
                end
            end
            -- 获得品质最高的卡牌
            local maxIndex = -1
            local maxValue = -1
            for k, cardModel in pairs(cardModelList) do
                local fixQualityNum = cardModel:GetCardFixQualityNum()
                if fixQualityNum >= maxValue then
                    maxValue = fixQualityNum
                    maxIndex = k
                end
            end
            if maxIndex > 0 then
                local quality = cardModelList[maxIndex]:GetCardQuality()
                local qualitySpecail = cardModelList[maxIndex]:GetCardQualitySpecial()
                local newID = self.heroHallDataModel:GetImproveConfigIdByQuality(quality, qualitySpecail)
                statueData.list[ImproveType.quality.improveType] = newID
            end
        else-- 卡牌列表为空说明当前球员被删空了，额外属性不增加
            for imprvoeType, v in pairs(statueData.list) do
                statueData.list[imprvoeType] = -1
            end
        end
        local hallData = self.footballHall[hallID]
        self.herohallAttrsMap[hallID] = self.heroHallDataModel:GetHallAttributes(hallID, hallData)
    end
end

-- 在卡牌【升阶】后更新当前球员与升阶相关的额外属性加成
function HeroHallMapModel:UpdateUpgradeImproveByPcid(pcid, cardCacheData)
    local cardModel = require("ui.models.cardDetail.PlayerCardModel").new(pcid)
    local baseID = cardModel:GetBaseID()
    self:UpdateUpgradeImproveByBaseID(baseID, cardCacheData)
end

function HeroHallMapModel:UpdateUpgradeImproveByCid(cid, cardCacheData)
    local cardModel = require("ui.models.cardDetail.StaticCardModel").new(cid)
    local baseID = cardModel:GetBaseID()
    self:UpdateUpgradeImproveByBaseID(baseID, cardCacheData)
end

function HeroHallMapModel:UpdateUpgradeImproveByBaseID(baseID, cardCacheData)
    local isStatueCard, hallIDList = self.heroHallDataModel:IsStatueCard(baseID)
    if isStatueCard then
        for k, hallID in pairs(hallIDList) do
            self:UpdateUpgradeImprove(hallID, baseID)
        end
    end
end

function HeroHallMapModel:UpdateUpgradeImprove(hallID, baseID)
    if not self.footballHall[hallID] then
        return
    end
    if self.footballHall[hallID].activate == 1 then
        local SimpleCardModel = require("ui.models.cardDetail.SimpleCardModel")
        local statueData = self.footballHall[hallID].list[baseID]
        local cidsMap = self.playerCardsMapModel:GetCidsMapByBaseID(baseID)
        if cidsMap ~= nil then
            local cardModelList = {}
            for cid, pcids in pairs(cidsMap) do
                for pcid, v in pairs(pcids) do
                    local tempCardModel = SimpleCardModel.new(pcid)
                    table.insert(cardModelList, tempCardModel)
                end
            end
            -- 获得升阶最高的卡牌
            local maxIndex = -1
            local maxValue = -1
            for k, cardModel in pairs(cardModelList) do
                local upgrade = cardModel:GetUpgrade() 
                if upgrade >= maxValue then
                    maxValue = upgrade
                    maxIndex = k
                end
            end
            if cardCacheData then
                if cardCacheData.upgrade > maxValue then
                    maxValue = cardCacheData.upgrade
                end
            end
            if maxIndex > 0 then
                local newID = self.heroHallDataModel:GetImproveConfigIdByUpgrade(maxValue)
                statueData.list[ImproveType.upgrade.improveType] = newID
            end
        else-- 卡牌列表为空说明当前球员被删空了，额外属性不增加
            for imprvoeType, v in pairs(statueData.list) do
                statueData.list[imprvoeType] = -1
            end
        end
        local hallData = self.footballHall[hallID]
        self.herohallAttrsMap[hallID] = self.heroHallDataModel:GetHallAttributes(hallID, hallData)
    end
end

-- 在卡牌【转生】后更新当前球员与转生相关的额外属性加成
function HeroHallMapModel:UpdateAscendImproveByPcid(pcid, cardCacheData)
    local cardModel = require("ui.models.cardDetail.PlayerCardModel").new(pcid)
    local baseID = cardModel:GetBaseID()
    self:UpdateAscendImproveByBaseID(baseID, cardCacheData)
end

function HeroHallMapModel:UpdateAscendImproveByCid(cid, cardCacheData)
    local cardModel = require("ui.models.cardDetail.StaticCardModel").new(cid)
    local baseID = cardModel:GetBaseID()
    self:UpdateAscendImproveByBaseID(baseID, cardCacheData)
end

function HeroHallMapModel:UpdateAscendImproveByBaseID(baseID, cardCacheData)
    local isStatueCard, hallIDList = self.heroHallDataModel:IsStatueCard(baseID)
    if isStatueCard then
        for k, hallID in pairs(hallIDList) do
            self:UpdateAscendImprove(hallID, baseID)
        end
    end
end

function HeroHallMapModel:UpdateAscendImprove(hallID, baseID)
    if not self.footballHall[hallID] then
        return
    end
    if self.footballHall[hallID].activate == 1 then
        local SimpleCardModel = require("ui.models.cardDetail.SimpleCardModel")
        local statueData = self.footballHall[hallID].list[baseID]
        local cidsMap = self.playerCardsMapModel:GetCidsMapByBaseID(baseID)
        if cidsMap ~= nil then
            local cardModelList = {}
            for cid, pcids in pairs(cidsMap) do
                for pcid, v in pairs(pcids) do
                    local tempCardModel = SimpleCardModel.new(pcid)
                    table.insert(cardModelList, tempCardModel)
                end
            end
            -- 获得转生次数最高的卡牌
            local maxIndex = -1
            local maxValue = -1
            for k, cardModel in pairs(cardModelList) do
                local ascend = cardModel:GetAscend() 
                if ascend >= maxValue then
                    maxValue = ascend
                    maxIndex = k
                end
            end
            if cardCacheData then
                if cardCacheData.ascend > maxValue then
                    maxValue = cardCacheData.ascend
                end
            end
            if maxIndex > 0 then
                local newID = self.heroHallDataModel:GetImproveConfigIdByAscend(maxValue)
                statueData.list[ImproveType.ascend.improveType] = newID
            end
        else-- 卡牌列表为空说明当前球员被删空了，额外属性不增加
            for imprvoeType, v in pairs(statueData.list) do
                statueData.list[imprvoeType] = -1
            end
        end
        local hallData = self.footballHall[hallID]
        self.herohallAttrsMap[hallID] = self.heroHallDataModel:GetHallAttributes(hallID, hallData)
    end
end

-- 在卡牌【解锁特训】、【完成特训】后更新当前球员与特训相关的额外属性加成
-- 实际上此代码插在特训界面关闭处
function HeroHallMapModel:UpdateTrainingBaseImproveByPcid(pcid)
    local cardModel = require("ui.models.cardDetail.PlayerCardModel").new(pcid)
    local baseID = cardModel:GetBaseID()
    self:UpdateTrainingBaseImproveByBaseID(baseID)
end

function HeroHallMapModel:UpdateTrainingBaseImproveByCid(cid)
    local cardModel = require("ui.models.cardDetail.StaticCardModel").new(cid)
    local baseID = cardModel:GetBaseID()
    self:UpdateTrainingBaseImproveByBaseID(baseID)
end

function HeroHallMapModel:UpdateTrainingBaseImproveByBaseID(baseID)
    local isStatueCard, hallIDList = self.heroHallDataModel:IsStatueCard(baseID)
    if isStatueCard then
        for k, hallID in pairs(hallIDList) do
            self:UpdateTrainingBaseImprove(hallID, baseID)
        end
    end
end

function HeroHallMapModel:UpdateTrainingBaseImprove(hallID, baseID)
    if not self.footballHall[hallID] then
        return
    end
    if self.footballHall[hallID].activate == 1 then
        local SimpleCardModel = require("ui.models.cardDetail.SimpleCardModel")
        local statueData = self.footballHall[hallID].list[baseID]
        local cidsMap = self.playerCardsMapModel:GetCidsMapByBaseID(baseID)
        if cidsMap ~= nil then
            local cardModelList = {}
            for cid, pcids in pairs(cidsMap) do
                for pcid, v in pairs(pcids) do
                    local tempCardModel = SimpleCardModel.new(pcid)
                    table.insert(cardModelList, tempCardModel)
                end
            end
            -- 获得特训关卡数最高的卡牌
            local maxIndex = -1
            local maxValue = -1
            local maxChapter = -1
            local maxStage = -1
            for k, cardModel in pairs(cardModelList) do
                local TrainingBase, chapter, stage = cardModel:GetTrainingBase()
                if TrainingBase >= maxValue then
                    maxValue = TrainingBase
                    maxChapter = chapter
                    maxStage = stage
                    maxIndex = k
                end
            end
            if maxIndex > 0 then
                local newID = self.heroHallDataModel:GetImproveConfigIdByTrainingBase(maxChapter, maxStage)
                statueData.list[ImproveType.TrainingBase.improveType] = newID
            end
        else-- 卡牌列表为空说明当前球员被删空了，额外属性不增加
            for imprvoeType, v in pairs(statueData.list) do
                statueData.list[imprvoeType] = -1
            end
        end
        local hallData = self.footballHall[hallID]
        self.herohallAttrsMap[hallID] = self.heroHallDataModel:GetHallAttributes(hallID, hallData)
    end
end

function HeroHallMapModel:GetHallIDsByPcids(pcids)
    local SimpleCardModel = require("ui.models.cardDetail.SimpleCardModel")
    local baseIDs = {}
    for k, pcid in pairs(pcids) do
        local cardModel = SimpleCardModel.new(pcid)
        local baseID = cardModel:GetBaseID()
        baseIDs[baseID] = true
    end
    return self:GetHallIDsByBaseIDs(baseIDs)
end

function HeroHallMapModel:GetHallIDsByCids(cids)
    local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
    local baseIDs = {}
    for k, cid in pairs(cids) do
        local cardModel = StaticCardModel.new(cid)
        local baseID = cardModel:GetBaseID()
        baseIDs[baseID] = true
    end
    return self:GetHallIDsByBaseIDs(baseIDs)
end

-- 删除卡牌是缩减计算量用
-- @paras：无重复baseIDs
function HeroHallMapModel:GetHallIDsByBaseIDs(baseIDs)
    local hallIDs = {}
    for baseID, v in pairs(baseIDs) do
        local isStatueCard, hallIDList = self.heroHallDataModel:IsStatueCard(baseID)
        hallIDs[baseID] = hallIDList
    end
    return hallIDs
end

-- 遍历卡牌，获取当前baseID球员中最高的特训章数
function HeroHallMapModel:GetTrainingBaseStatusByBaseID(baseID)
    local SimpleCardModel = require("ui.models.cardDetail.SimpleCardModel")
    local cidsMap = self.playerCardsMapModel:GetCidsMapByBaseID(baseID)
    local maxValue = -1
    if cidsMap ~= nil then
        for cid, pcids in pairs(cidsMap) do
            for pcid, v in pairs(pcids) do
                local tempCardModel = SimpleCardModel.new(pcid)
                local TrainingBase = tonumber(tempCardModel:GetTrainID())
                if TrainingBase >= maxValue then
                    maxValue = TrainingBase
                end
            end
        end
    end
    return maxValue
end

-- 进入殿堂页面、解锁殿堂，刷新三个map，HeroHallMainModel中调用
function HeroHallMapModel:UpdateCacheAfterEnter(footballHall)
    for hallID, hallData in pairs(footballHall) do
        local oldHallData = self.footballHall[hallID]
        oldHallData.activate = hallData.activate
        oldHallData.score = hallData.score
        for baseID, statueData in pairs(hallData.list) do
            local oldStatueData = oldHallData.list[baseID]
            oldStatueData.activate = statueData.activate
            oldStatueData.level = statueData.level
            oldStatueData.score = statueData.score
            oldStatueData.list = statueData.list
        end
    end
    self:InitWithProtocol(self.footballHall)
end

-- 雕像升级后更新map，HeroHallStatueModel中调用
function HeroHallMapModel:UpdateCacheAfterUpgrade(hallID, statueList)
    if self.footballHall[hallID].activate == 1 then
        -- 更新原始数据缓存
        for k, statueData in pairs(statueList) do
            local oldStatueData = self.footballHall[hallID].list[statueData.baseId]
            oldStatueData.activate = statueData.activate
            oldStatueData.level = statueData.level
            oldStatueData.list = statueData.list
            oldStatueData.score = statueData.score
        end
        -- 更新球员技能
        for cid, hallIDList in pairs(self.heroHallEffectMap) do
            for cacheHallID, v in pairs(hallIDList) do
                if hallID == cacheHallID then
                    local hlvl = self:GetSkillImproveByCid(cid)
                    self.playerCardsMapModel:UpdateCardSkillHeroHall(cid, hlvl)
                    break
                end
            end
        end
        -- 更新属性Map缓存
        local hallData = self.footballHall[hallID]
        self.herohallAttrsMap[hallID] = self.heroHallDataModel:GetHallAttributes(hallID, hallData)
    end
end

-- 根据球员cid获得所有殿堂的hlvl加成
function HeroHallMapModel:GetSkillImproveByCid(cid)
    local hlvl = 0
    local hallIDList = self.heroHallEffectMap[cid]
    for hallID, v in pairs(hallIDList) do
        hlvl = hlvl + self.heroHallDataModel:GetHallSkillImprove(self.footballHall[tostring(hallID)].list, cid)
    end
    return hlvl
end

-- 将cidList变成以cid为key，hallID列表为value的heroHallMap
function HeroHallMapModel:MergeCidListToMap(heroHallEffectMap, cidList, hallID)
    for cid, v in pairs(cidList) do
        if not heroHallEffectMap[cid] then
            heroHallEffectMap[cid] = {}
        end
        heroHallEffectMap[cid][hallID] = true
    end
end

-- 根据hallID获得玩家身上需要增益的球员cid列表
-- @parameter -->> hallID：殿堂ID
-- @return -->> cidList：需要增益的球员cid列表
--[[
    cidList = {
        Lmessi = true,
        Ghiguain = true
    }
]]--
function HeroHallMapModel:GetEffectCidList(hallID)
    local hallEffect = self.heroHallDataModel:GetHallEffect(hallID)
    local playerCids = self.playerCardsMapModel:GetCardCidMaps()
    local cidList = {}
    for cid, pcids in pairs(playerCids) do
        cidList[cid] = true
    end

    -- 多项效果配置之间取交集
    for effectType, effect in pairs(hallEffect) do
        local tempCidList = {}
        if effectType == HeroHallEffectType.nation then
            tempCidList = self:GetCidListByNation(playerCids, effect)
        elseif effectType == HeroHallEffectType.position then
            tempCidList = self:GetCidListByPosition(playerCids, effect)
        elseif effectType == HeroHallEffectType.quality then
            tempCidList = self:GetCidListByQuality(playerCids, effect)
        elseif effectType == HeroHallEffectType.skill then
            tempCidList = self:GetCidListBySkill(playerCids, effect)
        else
            dump("illegal effect type " .. effectType .. ", please check the config")
        end
        cidList = self:IntersectionTable(cidList, tempCidList)
    end
    return cidList
end

-- 根据球员国籍，获得cidList
function HeroHallMapModel:GetCidListByNation(playerCids, effect)
    local cidList = {}
    for cid, pcids in pairs(playerCids) do
        for k, configNation in pairs(effect) do
            local cardNation = Card[cid].nation
            local configTransNation = Nation[configNation].nation
            if cardNation == configTransNation then
                cidList[cid] = true
            end
        end
    end
    return cidList
end

-- 根据球员位置，获得cidList
function HeroHallMapModel:GetCidListByPosition(playerCids, effect)
    local cidList = {}
    for cid, pcids in pairs(playerCids) do
        for k, configPosition in pairs(effect) do
            local cardPositions = Card[cid].hallPosition
            for i, cardPosition in pairs(cardPositions) do
                if cardPosition == configPosition then
                    cidList[cid] = true
                end
            end
        end
    end
    return cidList
end

-- 根据球员品质，获得cidList
function HeroHallMapModel:GetCidListByQuality(playerCids, effect)
    local cidList = {}
    for cid, pcids in pairs(playerCids) do
        for k, configQuality in pairs(effect) do
            local configFixQuality = CardHelper.GetQualityFixedByConfig(configQuality)
            local cardFixQuality = CardHelper.GetQualityFixed(Card[cid].quality, Card[cid].qualitySpecial)
            if cardFixQuality == configFixQuality then
                cidList[cid] = true
            end
        end
    end
    return cidList
end

-- 根据球员技能，获得cidList
function HeroHallMapModel:GetCidListBySkill(playerCids, effect)
    local cidList = {}
    for cid, pcids in pairs(playerCids) do
        for k, configSkill in pairs(effect) do
            local cardSkills = Card[cid].skill
            for i, cardSkill in pairs(cardSkills) do
                if cardSkill == configSkill then
                    cidList[cid] = true
                end
            end
        end
    end
    return cidList
end

-- 两个列表取交集，返回一个新列表
function HeroHallMapModel:IntersectionTable(desc, src)
    local result = {}
    for k, v in pairs(src) do
        if desc[k] ~= nil then
            result[k] = v
        end
    end
    return result
end

-- 检查球员是否在殿堂中(baseid)
function HeroHallMapModel:CheckCardIsInside(cardId)
	for k, v in pairs(FootballHall) do
		local playerHall = v.playerHall or {}
		for i, baseId in ipairs(playerHall)	do
			if cardId == baseId then
                -- 越南版本单独处理，因为功能还没上
                if luaevt.trig("__VN__VERSION__") then
                    return false
                end
				return true
			end
		end	
	end
	return false
end

return HeroHallMapModel
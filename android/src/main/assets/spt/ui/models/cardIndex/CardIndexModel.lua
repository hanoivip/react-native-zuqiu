local EventSystem = require ("EventSystem")
local Model = require("ui.models.Model")
local Card = require("data.Card")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local CardBuilder = require("ui.common.card.CardBuilder")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local PlayerGenericModel = require("ui.models.playerGeneric.PlayerGenericModel")
local PosType = require("ui.controllers.playerList.PosType")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local CardOpenFromType = require("ui.controllers.cardDetail.CardOpenFromType")

local CardIndexModel = class(Model, "CardIndexModel")

local function GetSelectPosOrder(model, selectPos)
    local isSelect = false
    if selectPos and next(selectPos) then
        local selectPosArray = {}
        for k, v in pairs(selectPos) do
            selectPosArray[PosType[k]] = true
        end

        local posArray = model:GetPosition()
        for i, v in ipairs(posArray) do
            if selectPosArray[v] then
                isSelect = true
                break
            end
        end
    else
        isSelect = true
    end

    return isSelect
end

function CardIndexModel:ctor()
    -- 图鉴数据
    self.data = nil
    -- 通信数据
    self.protocolData = {}
    CardIndexModel.super.ctor(self)
end

function CardIndexModel:Init(selectTypeIndex, selectPos, selectQuality, selectNationality, selectName, selectSkill)
    self.cardModelMap = {}
    self.qualityCidList = {}
    self.nationalityCidList = {}
    self.totalCardCount = 0
    self.sortCardList = self:GetCardList()
    self:InitCardModelMap()
    self:SetDefaultSelectIndex(selectTypeIndex, selectPos, selectQuality, selectNationality, selectName, selectSkill)
    self:InitData()
end

function CardIndexModel:InitWithProtocol(data)
    self.protocolData = {}
    for i, cid in ipairs(data) do
        self.protocolData[cid] = true
    end
end

function CardIndexModel:InitData()
    self.data = {
        cardDict = {},
    }
    for cardId, cardStaticData in pairs(Card) do
        if cardStaticData.valid == 1 then
            local playerCardStaticModel = StaticCardModel.new(cardId)
            playerCardStaticModel:SetOpenFromPageType(CardOpenFromType.HANDBOOK)
            self.data.cardDict[cardId] = playerCardStaticModel
        end
    end
    cache.setCardIndexInfo(self.data)
end

function CardIndexModel:SetDefaultSelectIndex(selectTypeIndex, selectPos, selectQuality, selectNationality, selectName, selectSkill)
    self.selectTypeIndex = selectTypeIndex
    self.selectPos = selectPos
    self.selectQuality = selectQuality
    self.selectNationality = selectNationality
    self.selectName = selectName
    self.selectSkill = selectSkill
end

function CardIndexModel:GetSelectTypeIndex()
    return self.selectTypeIndex or 1 -- 默认选第一个出场顺序
end
--- 位置筛选条件
-- return table(default {})
function CardIndexModel:GetSelectPos()
    return self.selectPos or {}
end
--- 质量筛选条件
-- return table(default {})
function CardIndexModel:GetSelectQuality()
    return self.selectQuality or {}
end
--- 名字筛选条件
-- return string(default "")
function CardIndexModel:GetSeletName()
    return self.selectName or ""
end
--- 国籍筛选条件
-- return string(default "")
function CardIndexModel:GetSeletNationality()
    return self.selectNationality or ""
end
--- 技能筛选条件
-- return table(default {})
function CardIndexModel:GetSeletSkill()
    return self.selectSkill or {}
end
--- 获取CardModel
function CardIndexModel:GetCardModel(cid)
    return self.cardModelMap[tostring(cid)]
end
--- 构建CardModelMap
function CardIndexModel:InitCardModelMap()
    local qualityIndex = nil
    for cid, cardStaticData in pairs(Card) do
        if cardStaticData.valid == 1 then
            local playerCardStaticModel = StaticCardModel.new(cid)
            self.cardModelMap[cid] = playerCardStaticModel
            playerCardStaticModel:SetOpenFromPageType(CardOpenFromType.HANDBOOK)
            -- 国籍
            if self.nationalityCidList[tostring(cardStaticData.nationIcon)] == nil then
                self.nationalityCidList[tostring(cardStaticData.nationIcon)] = {}
            end
            table.insert(self.nationalityCidList[tostring(cardStaticData.nationIcon)], cid)
            -- 质量
            qualityIndex = CardHelper.GetQualityFixed(cardStaticData.quality, cardStaticData.qualitySpecial)
            if self.qualityCidList[qualityIndex] == nil then
                self.qualityCidList[qualityIndex] = {}
            end
            table.insert(self.qualityCidList[qualityIndex], cid)
        end
    end
end
--- 获取全部卡牌cid列表
function CardIndexModel:GetCardList()
    local cardList = {}
    for cid, cardStaticData in pairs(Card) do
        if cardStaticData.valid == 1 then
            table.insert(cardList, cid)
        end
    end
    self.sortCardList = cardList
    self.totalCardCount = #self.sortCardList
    return self.sortCardList
end
--- 已获得卡牌数
function CardIndexModel:GetOwnCardsCount()
    return table.nums(self.protocolData)
end

--- 全部卡牌数
function CardIndexModel:GetTotalCardsCount()
    return self.totalCardCount
end
--- 获取排序后cid列表
function CardIndexModel:GetSortCardList()
    return self.sortCardList
end
--- 筛选 & 排序
function CardIndexModel:SortCardList(typeIndex, pos, quality, nationality, name, skill)
    typeIndex = typeIndex or 1
    self.selectTypeIndex = typeIndex
    pos = pos or {}
    self.selectPos = pos
    self.selectQuality = quality or {}
    quality = (quality ~= nil and quality ~= {}) and table.keys(quality) or {}
    nationality = nationality or ""
    self.selectNationality = nationality
    name = name or ""
    self.selectName = name
    skill = skill or {}
    self.selectSkill = skill
    local rootCidList = {}
    local allCidList = table.keys(self.cardModelMap)
    -- 国籍：唯一
    if nationality ~= "" then
        if self.nationalityCidList[nationality] ~= nil then
            table.imerge(rootCidList, self.nationalityCidList[nationality])
            if #rootCidList == 0 then
                self:FinishSelectWithNoCard()
                return
            end
        else
            self:FinishSelectWithNoCard()
            return
        end
    end
    -- 质量：或
    if #quality > 0 then
        local quaCidList = {}
        for i, v in ipairs(quality) do
            table.imerge(quaCidList, self.qualityCidList[tostring(v)] or {})
        end
        if #rootCidList > 0 then
            local commonCid = {}
            for i, v in ipairs(rootCidList) do
                if table.isArrayInclude(quaCidList, v) then
                    table.insert(commonCid, v)
                end
            end
            rootCidList = commonCid
        else
            table.imerge(rootCidList, quaCidList)
        end

        if #rootCidList == 0 then
            self:FinishSelectWithNoCard()
            return
        end
    end
    -- 名字筛选
    if name ~= "" then
        local nameCidList = {}
        if #rootCidList == 0 then
            rootCidList = allCidList
        end
        for i, v in ipairs(rootCidList) do
            if string.find(self.cardModelMap[v]:GetName(), name) or string.find(string.upper(self.cardModelMap[v]:GetNameByEnglish()), string.upper(name)) then
                table.insert(nameCidList, v)
            end
        end
        rootCidList = nameCidList

        if #rootCidList == 0 then
            self:FinishSelectWithNoCard()
            return
        end
    end
    -- 技能：且
    if skill ~= {} then
        local skillCidList = {}
        if #rootCidList == 0 then
           rootCidList = allCidList
        end
        for i, v in ipairs(rootCidList) do
            local skills = self.cardModelMap[v]:GetSkills()
            local hasSkill = true
            for iSid, vSid in ipairs(skill) do
                for iSkill, vSkill in ipairs(skills) do
                    if vSkill.sid == vSid then
                        break
                    else
                        if iSkill == #skills then
                            hasSkill = false
                        end
                    end
                end
            end
            if hasSkill then
                table.insert(skillCidList, v)
            end
        end
        rootCidList = skillCidList
        if #rootCidList == 0 then
            self:FinishSelectWithNoCard()
            return
        end
    end
    -- 无以上筛选
    if #rootCidList == 0 then
        rootCidList = allCidList
    end
    -- 位置筛选
    if table.nums(pos) > 0 then
        local posList = {}
        for i, cid in ipairs(rootCidList) do
            local isSelect = GetSelectPosOrder(self.cardModelMap[cid], pos)
            if isSelect then
                table.insert(posList, cid)
            end
        end
        rootCidList = posList
    end
    -- 排序
    table.sort(rootCidList, function(a, b)
        local cardA = self.cardModelMap[a]
        local cardB = self.cardModelMap[b]

        if cardA:GetCardFixQualityNum() > cardB:GetCardFixQualityNum() then
            return true
        elseif cardA:GetCardFixQualityNum() < cardB:GetCardFixQualityNum() then
            return false
        else
            return cardA:GetCid() < cardB:GetCid()
        end
    end)
    self.sortCardList = rootCidList
    EventSystem.SendEvent("CardIndexModel.SortCardList")
end
--- 筛选结果为空
function CardIndexModel:FinishSelectWithNoCard()
    self.sortCardList = {}
    EventSystem.SendEvent("CardIndexModel.SortCardList")
end

--- 是否获得过该卡牌
-- @param cardId 卡牌Id
-- @return bool
function CardIndexModel:IsCardGeted(cardId)
    return self.protocolData[cardId] or false
end

return CardIndexModel
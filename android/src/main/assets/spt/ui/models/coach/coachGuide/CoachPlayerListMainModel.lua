local EventSystem = require ("EventSystem")
local Model = require("ui.models.Model")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local PlayerPiecesMapModel = require("ui.models.PlayerPiecesMapModel")
local PasterPiecesMapModel = require("ui.models.PasterPiecesMapModel")
local CardPieceModel = require("ui.models.cardDetail.CardPieceModel")
local CardPasterPieceModel = require("ui.models.cardDetail.CardPasterPieceModel")
local EquipPieceMapModel = require("ui.models.EquipPieceMapModel")
local EquipsMapModel = require("ui.models.EquipsMapModel")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local CardBuilder = require("ui.common.card.CardBuilder")
local PlayerTeamsModel = require("ui.models.PlayerTeamsModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local PlayerGenericModel = require("ui.models.playerGeneric.PlayerGenericModel")
local PlayerSortModel = require("ui.models.playerList.PlayerSortModel")
local SortType = require("ui.controllers.playerList.SortType")
local PosType = require("ui.controllers.playerList.PosType")
local CoachPlayerListMainModel = class(Model, "CoachPlayerListMainModel")
local CardHelper = require("ui.scene.cardDetail.CardHelper")

-- 缓存数据
local PlayerTeamsTempModel = nil
local PlayerSortTempModel = nil

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

-- 排序函数
local function StartOrderComp(aModel, bModel)
    local aRarity = PlayerSortTempModel:GetRarity(aModel)
    local bRarity = PlayerSortTempModel:GetRarity(bModel)

    local aRaritySpecial = PlayerSortTempModel:GetQualitySpecial(aModel)
    local bRaritySpecial = PlayerSortTempModel:GetQualitySpecial(bModel)
  
    local aBaseID = aModel:GetBaseID()
    local bBaseID = bModel:GetBaseID()

    if aRarity == bRarity then
        if (aRaritySpecial and bRaritySpecial) or (not aRaritySpecial and not bRaritySpecial) then
            local aPower = PlayerSortTempModel:GetPower(aModel)
            local bPower = PlayerSortTempModel:GetPower(bModel)
            if aPower == bPower then
                if aBaseID == bBaseID then
                    local aObtainTime = tonumber(aModel:GetObtainTime())
                    local bObtainTime = tonumber(bModel:GetObtainTime())
                    return aObtainTime > bObtainTime
                else
                    return aBaseID > bBaseID
                end
            else
                return aPower > bPower
            end
        else
            if aRaritySpecial then
                return true;
            else
                return false;
            end
        end
    else
        return aRarity > bRarity
    end
end

local function QualityCompWithFall(aModel, bModel)
    local aRarity = aModel:GetCardFixQualityNum()
    local bRarity = bModel:GetCardFixQualityNum()
  
    if aRarity == bRarity then
        local aPower = PlayerSortTempModel:GetPower(aModel)
        local bPower = PlayerSortTempModel:GetPower(bModel)
        if aPower == bPower then
            local aBaseID = aModel:GetBaseID()
            local bBaseID = bModel:GetBaseID()
            if aBaseID == bBaseID then
                local aObtainTime = tonumber(aModel:GetObtainTime())
                local bObtainTime = tonumber(bModel:GetObtainTime())
                return aObtainTime > bObtainTime
            else
                return aBaseID > bBaseID
            end
        else
            return aPower > bPower
        end
    else
        return aRarity > bRarity
    end
end

local function QualityCompWithRise(aModel, bModel)
    local aRarity = aModel:GetCardFixQualityNum()
    local bRarity = bModel:GetCardFixQualityNum()

    if aRarity == bRarity then
        local aPower = PlayerSortTempModel:GetPower(aModel)
        local bPower = PlayerSortTempModel:GetPower(bModel)
        if aPower == bPower then
            local aBaseID = aModel:GetBaseID()
            local bBaseID = bModel:GetBaseID()
            if aBaseID == bBaseID then
                local aObtainTime = tonumber(aModel:GetObtainTime())
                local bObtainTime = tonumber(bModel:GetObtainTime())
                return aObtainTime > bObtainTime
            else
                return aBaseID > bBaseID
            end
        else
            return aPower > bPower
        end
    else
        return aRarity < bRarity
    end
end

local function LevelCompWithFall(aModel, bModel)
    local aLevel = tonumber(aModel:GetLevel())
    local bLevel = tonumber(bModel:GetLevel())

    local aBaseID = aModel:GetBaseID()
    local bBaseID = bModel:GetBaseID()

    if aLevel == bLevel then
        local aPower = PlayerSortTempModel:GetPower(aModel)
        local bPower = PlayerSortTempModel:GetPower(bModel)
        if aPower == bPower then
            if aBaseID == bBaseID then 
                return aModel:GetCardQuality() > bModel:GetCardQuality()
            else
                return aBaseID > bBaseID
            end
        else
            return aPower > bPower
        end
    else
        return aLevel > bLevel
    end
end

local function LevelCompWithRise(aModel, bModel)
    local aLevel = tonumber(aModel:GetLevel())
    local bLevel = tonumber(bModel:GetLevel())

    local aBaseID = aModel:GetBaseID()
    local bBaseID = bModel:GetBaseID()

    if aLevel == bLevel then
        local aPower = PlayerSortTempModel:GetPower(aModel)
        local bPower = PlayerSortTempModel:GetPower(bModel)
        if aPower == bPower then
            if aBaseID == bBaseID then 
                return aModel:GetCardQuality() > bModel:GetCardQuality()
            else
                return aBaseID > bBaseID
            end
        else
            return aPower > bPower
        end
    else
        return aLevel < bLevel
    end
end

local function PowerCompWithFall(aModel, bModel)
    local aPower = PlayerSortTempModel:GetPower(aModel)
    local bPower = PlayerSortTempModel:GetPower(bModel)

    local aBaseID = aModel:GetBaseID()
    local bBaseID = bModel:GetBaseID()

    if aPower == bPower then
        local aRarity = PlayerSortTempModel:GetRarity(aModel)
        local bRarity = PlayerSortTempModel:GetRarity(bModel) 
        if aRarity == bRarity then
            if aBaseID == bBaseID then 
                local aObtainTime = tonumber(aModel:GetObtainTime())
                local bObtainTime = tonumber(bModel:GetObtainTime())
                return aObtainTime > bObtainTime
            else
                return aBaseID > bBaseID
            end
        else
            return aRarity > bRarity
        end
    else
        return aPower > bPower
    end
end

local function PowerCompWithRise(aModel, bModel)
    local aPower = PlayerSortTempModel:GetPower(aModel)
    local bPower = PlayerSortTempModel:GetPower(bModel)

    local aBaseID = aModel:GetBaseID()
    local bBaseID = bModel:GetBaseID()
    
    if aPower == bPower then
        local aRarity = PlayerSortTempModel:GetRarity(aModel)
        local bRarity = PlayerSortTempModel:GetRarity(bModel) 
        if aRarity == bRarity then
            if aBaseID == bBaseID then 
                local aObtainTime = tonumber(aModel:GetObtainTime())
                local bObtainTime = tonumber(bModel:GetObtainTime())
                return aObtainTime > bObtainTime
            else
                return aBaseID > bBaseID
            end
        else
            return aRarity < bRarity
        end
    else
        return aPower < bPower
    end
end

local function ObtainOrderCompWithFall(aModel, bModel)
    local aObtainTime = tonumber(aModel:GetObtainTime())
    local bObtainTime = tonumber(bModel:GetObtainTime())

    return aObtainTime > bObtainTime
end

local function ObtainOrderCompWithRise(aModel, bModel)
    local aObtainTime = tonumber(aModel:GetObtainTime())
    local bObtainTime = tonumber(bModel:GetObtainTime())

    return aObtainTime < bObtainTime
end

local function BaseIDCompWithFall(aModel, bModel)
    local aBaseID = aModel:GetBaseID()
    local bBaseID = bModel:GetBaseID()
    if aBaseID == bBaseID then
        local aRarity = PlayerSortTempModel:GetRarity(aModel)
        local bRarity = PlayerSortTempModel:GetRarity(bModel)
        if aRarity == bRarity then
            local aPower = PlayerSortTempModel:GetPower(aModel)
            local bPower = PlayerSortTempModel:GetPower(bModel)
            if aPower == bPower then
                local aObtainTime = tonumber(aModel:GetObtainTime())
                local bObtainTime = tonumber(bModel:GetObtainTime())
                return aObtainTime > bObtainTime
            else
                return aPower > bPower
            end
        else
            return aRarity > bRarity
        end
    else
        return aBaseID > bBaseID
    end
end

local function BaseIDCompWithRise(aModel, bModel)
    local aBaseID = aModel:GetBaseID()
    local bBaseID = bModel:GetBaseID()
    if aBaseID == bBaseID then
        local aRarity = PlayerSortTempModel:GetRarity(aModel)
        local bRarity = PlayerSortTempModel:GetRarity(bModel)
        if aRarity == bRarity then
            local aPower = PlayerSortTempModel:GetPower(aModel)
            local bPower = PlayerSortTempModel:GetPower(bModel)
            if aPower == bPower then
                local aObtainTime = tonumber(aModel:GetObtainTime())
                local bObtainTime = tonumber(bModel:GetObtainTime())
                return aObtainTime > bObtainTime
            else
                return aPower > bPower
            end
        else
            return aRarity > bRarity
        end
    else
        return aBaseID < bBaseID
    end
end

function CoachPlayerListMainModel:ctor(slotData)
    self.slotData = slotData
    CoachPlayerListMainModel.super.ctor(self)
end

function CoachPlayerListMainModel:Init()
    self.playerCardsMapModel = PlayerCardsMapModel.new()
    self.playerPiecesMapModel = PlayerPiecesMapModel.new()
    self.pasterPiecesMapModel = PasterPiecesMapModel.new()
    self.playerInfoModel = PlayerInfoModel.new()
    self.playerGenericModel = PlayerGenericModel.new()
    self.playerTeamsModel = PlayerTeamsModel.new()
    self.selectdCardList = {}
    self.cardModelMap = {}
    self.qualityCidList = {}
    self.nationalityCidList = {}
    self.sortCardList = self:GetCardList()
    self:InitCardModelMap()
    self:SetDefaultSelectIndex()
    self.sortFuncMap = {
        [SortType.DEFAULT] = StartOrderComp,
        [SortType.POWER_FALL] = PowerCompWithFall,
        [SortType.POWER_RISE] = PowerCompWithRise,
        [SortType.QUALITY_FALL] = QualityCompWithFall,
        [SortType.QUALITY_RISE] = QualityCompWithRise,
        [SortType.NAME_FALL] = BaseIDCompWithFall,
        [SortType.NAME_RISE] = BaseIDCompWithRise,
        [SortType.OBTAIN_ORDER_FALL] = ObtainOrderCompWithFall,
        [SortType.OBTAIN_ORDER_RISE] = ObtainOrderCompWithRise
    }
    PlayerTeamsTempModel = self.playerTeamsModel
end

function CoachPlayerListMainModel:SetDefaultSelectIndex(selectTypeIndex, selectPos, selectQuality, selectNationality, selectName, selectSkill)
    self.selectTypeIndex = selectTypeIndex
    self.selectPos = selectPos
    self.selectQuality = selectQuality
    self.selectNationality = selectNationality
    self.selectName = selectName
    self.selectSkill = selectSkill
end

function CoachPlayerListMainModel:GetSelectTypeIndex()
    return self.selectTypeIndex or 1 -- 默认选第一个出场顺序
end

function CoachPlayerListMainModel:GetSelectPos()
    return self.selectPos or {} -- 默认不选位置(可多选)
end
--- 质量筛选条件
function CoachPlayerListMainModel:GetSelectQuality()
    return self.selectQuality or {}
end
--- 名字筛选条件
function CoachPlayerListMainModel:GetSeletName()
    return self.selectName or ""
end
--- 国籍筛选条件
function CoachPlayerListMainModel:GetSeletNationality()
    return self.selectNationality or ""
end
--- 技能筛选条件
function CoachPlayerListMainModel:GetSeletSkill()
    return self.selectSkill or {}
end

function CoachPlayerListMainModel:GetCardNumberLimit()
    return self.playerGenericModel:GetPlayerCapacity() + self.playerInfoModel:GetCardNumberLimit()
end

function CoachPlayerListMainModel:AddMoney(money)
    self.playerInfoModel:AddMoney(money)
end

function CoachPlayerListMainModel:GetCardModel(pcid)
    return self.cardModelMap[tostring(pcid)]
end

function CoachPlayerListMainModel:GetPieceModel(cid)
    local cardPieceModel = CardPieceModel.new()
    local pieceData = self.playerPiecesMapModel:GetPieceData(cid)
    cardPieceModel:InitWithCache(pieceData)
    return cardPieceModel
end

function CoachPlayerListMainModel:GetPasterPieceModel(type)
    local cardPasterPieceModel = CardPasterPieceModel.new()
    local pieceData = self.pasterPiecesMapModel:GetPieceData(type)
    cardPasterPieceModel:InitWithCache(pieceData)
    return cardPasterPieceModel
end

function CoachPlayerListMainModel:InitCardModelMap()
    local cardList = self:GetCardList()
    local equipPieceMapModel = EquipPieceMapModel.new()
    local equipsMapModel = EquipsMapModel.new()
    local qualityIndex = nil
    for i, pcid in ipairs(cardList) do
        local cardModel = CardBuilder.GetOwnCardModel(pcid, self.playerTeamsModel, self.playerCardsMapModel, equipPieceMapModel, equipsMapModel)
        self.cardModelMap[tostring(pcid)] = cardModel
        -- 国籍
        if self.nationalityCidList[tostring(cardModel:GetNation())] == nil then
            self.nationalityCidList[tostring(cardModel:GetNation())] = {}
        end
        table.insert(self.nationalityCidList[tostring(cardModel:GetNation())], pcid)
        -- 质量
        qualityIndex = cardModel:GetCardFixQuality()
        if self.qualityCidList[qualityIndex] == nil then
            self.qualityCidList[qualityIndex] = {}
        end
        table.insert(self.qualityCidList[qualityIndex], pcid)
    end
end

function CoachPlayerListMainModel:ResetCardModel(pcid, cardModel)
    self.cardModelMap[tostring(pcid)] = cardModel
end

function CoachPlayerListMainModel:RemoveCardModel(removePcid)
    -- 筛选列表处理
    local cardModel = self.cardModelMap[tostring(removePcid)]
    for i = #self.nationalityCidList[tostring(cardModel:GetNation())], 1, -1 do
        local pcid = self.nationalityCidList[tostring(cardModel:GetNation())][i]
        if tonumber(removePcid) == tonumber(pcid) then
            table.remove(self.nationalityCidList[tostring(cardModel:GetNation())], i)
            break
        end
    end
    for i = #self.qualityCidList[tostring(cardModel:GetCardFixQuality())], 1, -1 do
        local pcid = self.qualityCidList[tostring(cardModel:GetCardFixQuality())][i]
        if tonumber(removePcid) == tonumber(pcid) then
            table.remove(self.qualityCidList[tostring(cardModel:GetCardFixQuality())], i)
            break
        end
    end

    self.cardModelMap[tostring(removePcid)] = nil
    for i = #self.sortCardList, 1, -1 do
        local pcid = self.sortCardList[i]
        if tonumber(removePcid) == tonumber(pcid) then
            table.remove(self.sortCardList, i)
            break
        end
    end
end

function CoachPlayerListMainModel:RemoveCards(pcids)
    assert(pcids)
    self.playerCardsMapModel:RemoveCardData(pcids)
    
    for i, pcid in ipairs(pcids) do
        self:RemoveCardModel(pcid)
    end

    EventSystem.SendEvent("CoachPlayerListMainView_RemoveCards", pcids)
end

function CoachPlayerListMainModel:ModifyFormation(pcids)
    local nowTeamID = self.playerTeamsModel:GetNowTeamId()
    local replacePlayerData = self.playerTeamsModel:GetReplacePlayersData(nowTeamID)
    for i, pcid in ipairs(pcids) do
        for pos, posPcid in pairs(replacePlayerData) do
            if tostring(pcid) == tostring(posPcid) then
                replacePlayerData[pos] = nil
                break
            end
        end
    end
    self.playerTeamsModel:SetReplacePlayersData(nowTeamID, replacePlayerData)
end

function CoachPlayerListMainModel:ResetCardData(pcid, data)
    self.playerCardsMapModel:ResetCardData(pcid, data)
    
    local cardModel = CardBuilder.GetOwnCardModel(pcid)
    self:ResetCardModel(pcid, cardModel)

    EventSystem.SendEvent("CoachPlayerListMainView_ResetCardData", pcid)
end

function CoachPlayerListMainModel:GetCardList()
    local cardList = self.playerCardsMapModel:GetCardList()
    local slotPcids = self.slotData.pcids or {}
    local fixedCardList = {}
    for i,v in ipairs(cardList) do
        if not slotPcids[tostring(v)] then
            table.insert(fixedCardList, v)
        end
    end
    return fixedCardList
end

function CoachPlayerListMainModel:GetPlayerPieceMap()
    return self.playerPiecesMapModel:GetPieceMap()
end

function CoachPlayerListMainModel:GetPlayerPasterPieceMap()
    return self.pasterPiecesMapModel:GetPieceMap()
end

function CoachPlayerListMainModel:GetSortCardList()
    return self.sortCardList
end

function CoachPlayerListMainModel:ResetPieceData(cid, data)
    self.playerPiecesMapModel:ResetPieceData(cid, data)
end

function CoachPlayerListMainModel:RemovePieceData(cid)
    self.playerPiecesMapModel:RemovePieceData(cid)
end

function CoachPlayerListMainModel:GetUniversalPieceNum()
    return self.playerPiecesMapModel:GetUniversalPieceNum()
end

function CoachPlayerListMainModel:ResetPasterPieceData(type, data)
    self.pasterPiecesMapModel:ResetPieceData(type, data)
end

function CoachPlayerListMainModel:RemovePasterPieceData(type)
    self.pasterPiecesMapModel:RemovePieceData(type)
end

--1. 默认排序：
--主排序：首发-替补-其他
--辅助排序：先筛选出所有不重复的ID，品质由高到低、战力由高到低（同ID取品质、战力最高）、球员名由高到低排序。将这些ID排序。相同ID球员放在一起。其内部排序，按照战力由高到低、球员名由高到低、入手顺序由高到低。

--2. 战力排序：
--主排序：战力由高到低
--辅助排序：品质由高到低、球员名由高到低、入手顺序由高到低
-- 双向排序：仅对战力、品质双向

--3. 品质排序：
--主排序：品质由高到低
--辅助排序：先筛选出所有不重复的ID，战力由高到低（同ID取战力最高）、球员名由高到低排序。将这些ID排序。相同ID球员放在一起。其内部排序，按照战力由高到低、球员名由高到低、入手顺序由高到低。
-- 双向排序：仅对品质双向

--4. 球员名排序：
--主排序：球员名由高到低
--辅助排序：先筛选出所有不重复的ID，品质由高到低、战力由高到低（同ID取战力最高）、入手顺序由高到低排序。将这些ID排序。相同ID球员放在一起。其内部排序，战力-入手顺序。
-- 双向排序：仅对球员名双向

--5. 入手顺序
--完全按照入手顺序。
-- 双向排序反序即可

local Mt = { }
Mt.__add = function(t1, t2)
    for i, model in ipairs(t2) do
        table.insert(t1, model)
    end
    return t1
end

-- 根据球员名插入球员
local function SortInsert(l, t)
    local set = { }
    setmetatable(set, Mt)
    for _, model in ipairs(l) do
        local cid = model:GetCid()
        local aRarity = PlayerSortTempModel:GetRarity(model)
        if t[aRarity] and t[aRarity][cid] then
            table.insert(set, model)
            setmetatable(t[aRarity][cid], Mt)
            set = set + t[aRarity][cid]
            t[aRarity][cid] = nil
        else
            table.insert(set, model)
        end
    end
    return set
end

function CoachPlayerListMainModel:SortDefaultAsc(typeIndex, cardModelArray)
    local sortCardModelArray = {}
    local startersMap = { }
    local repsMap = { }
    local notSameMap = { }
    local sameMap = { }

    if not PlayerTeamsTempModel then
        PlayerTeamsTempModel = PlayerTeamsModel.new()
    end

    local eliminateMap = { }
    for i, model in ipairs(cardModelArray) do
        local priority = PlayerSortTempModel:GetPlayerPriority(model, PlayerTeamsTempModel)
        if priority == 2 then
            table.insert(startersMap, model)
        elseif priority == 1 then
            table.insert(repsMap, model)
        else
            local cid = model:GetCid()
            local aRarity = PlayerSortTempModel:GetRarity(model)
            if not eliminateMap[aRarity] then 
                eliminateMap[aRarity] = { }
            end
            if not eliminateMap[aRarity][cid] then 
                eliminateMap[aRarity][cid] = { }
            end
            table.insert(eliminateMap[aRarity][cid], model)
        end
    end

    for aRarity, v in pairs(eliminateMap) do
        for cid, models in pairs(v) do
            if table.nums(models) > 1 then
                table.sort(models, self.sortFuncMap[typeIndex])
                local maxModel = table.remove(models, 1)
                table.insert(notSameMap, maxModel)
                if not sameMap[aRarity] then
                    sameMap[aRarity] = { }
                end
                sameMap[aRarity][cid] = models
            else
                table.insert(notSameMap, models[1])
            end
        end
    end

    setmetatable(startersMap, Mt)
    setmetatable(repsMap, Mt)
    setmetatable(notSameMap, Mt)

    table.sort(startersMap, self.sortFuncMap[typeIndex])
    table.sort(repsMap, self.sortFuncMap[typeIndex])
    table.sort(notSameMap, self.sortFuncMap[typeIndex])

    local combinationMap = SortInsert(notSameMap, sameMap)
    sortCardModelArray = startersMap + repsMap + combinationMap

    return sortCardModelArray
end

function CoachPlayerListMainModel:SortQualityAsc(typeIndex, cardModelArray)
    local sortCardModelArray = {}
    local notSameMap = { }
    local sameMap = { }

    local eliminateMap = { }
    for i, model in ipairs(cardModelArray) do
        local cid = model:GetCid()
        local aRarity = PlayerSortTempModel:GetRarity(model)
        if not eliminateMap[aRarity] then
            eliminateMap[aRarity] = { }
        end
        if not eliminateMap[aRarity][cid] then
            eliminateMap[aRarity][cid] = { }
        end
        table.insert(eliminateMap[aRarity][cid], model)
    end

    for aRarity, v in pairs(eliminateMap) do
        for cid, models in pairs(v) do
            if table.nums(models) > 1 then
                table.sort(models, self.sortFuncMap[typeIndex])
                local maxModel = table.remove(models, 1)
                table.insert(notSameMap, maxModel)
                if not sameMap[aRarity] then
                    sameMap[aRarity] = { }
                end
                sameMap[aRarity][cid] = models
            else
                table.insert(notSameMap, models[1])
            end
        end
    end

    setmetatable(notSameMap, Mt)
    table.sort(notSameMap, self.sortFuncMap[typeIndex])
    local combinationMap = SortInsert(notSameMap, sameMap)
    sortCardModelArray = combinationMap
    return sortCardModelArray
end

function CoachPlayerListMainModel:SortNameAsc(typeIndex, cardModelArray)
    return self:SortQualityAsc(typeIndex, cardModelArray)
end

function CoachPlayerListMainModel:GetSortAsc(typeIndex, cardModelArray)
    local sortCardModelArray = {}
    if typeIndex == SortType.DEFAULT then 
        sortCardModelArray = self:SortDefaultAsc(typeIndex, cardModelArray)
    elseif typeIndex == SortType.POWER_FALL or typeIndex == SortType.POWER_RISE then
        table.sort(cardModelArray, self.sortFuncMap[typeIndex])
        sortCardModelArray = cardModelArray
    elseif typeIndex == SortType.QUALITY_FALL or typeIndex == SortType.QUALITY_RISE then
        sortCardModelArray = self:SortQualityAsc(typeIndex, cardModelArray)
    elseif typeIndex == SortType.NAME_FALL or typeIndex == SortType.NAME_RISE then
        sortCardModelArray = self:SortNameAsc(typeIndex, cardModelArray)
    elseif typeIndex == SortType.OBTAIN_ORDER_FALL or typeIndex == SortType.OBTAIN_ORDER_RISE then
        table.sort(cardModelArray, self.sortFuncMap[typeIndex])
        sortCardModelArray = cardModelArray
    end
    return sortCardModelArray
end

-- 按照排序类型排序
function CoachPlayerListMainModel:SortCardList(typeIndex, pos, quality, nationality, name, skill)
    -- typeIndex = typeIndex or 1
    -- pos = pos or {}
    -- self.selectTypeIndex = typeIndex
    -- self.selectPos = pos
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
            if self.qualityCidList[tostring(v)] then
                table.imerge(quaCidList, self.qualityCidList[tostring(v)])
            end
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

    local cardModelArray = {}
    -- for pcid, cardModel in pairs(self.cardModelMap) do
    --     local isSelect = GetSelectPosOrder(cardModel, pos)
    --     if isSelect then 
    --         table.insert(cardModelArray, cardModel)
    --     end
    -- end
    for index, pcid in ipairs(rootCidList) do
        local isSelect = GetSelectPosOrder(self.cardModelMap[pcid], pos)
        if isSelect then 
            table.insert(cardModelArray, self.cardModelMap[pcid])
        end      
    end

    PlayerSortTempModel = PlayerSortModel.new()
    cardModelArray = self:GetSortAsc(typeIndex, cardModelArray)
    PlayerSortTempModel = nil

    self.sortCardList = {}
    for i, cardModel in ipairs(cardModelArray) do
        table.insert(self.sortCardList, cardModel:GetPcid())
    end

    EventSystem.SendEvent("CoachPlayerListMainView_SortCardList")
end
--- 筛选结果为空 
function CoachPlayerListMainModel:FinishSelectWithNoCard()
    self.sortCardList = {}
    EventSystem.SendEvent("CoachPlayerListMainView_SortCardList")
end

function CoachPlayerListMainModel:ClearSelectedCardList()
    self.selectdCardList = {}

    EventSystem.SendEvent("CoachPlayerListMainView_ClearSelectedCardList")
end

function CoachPlayerListMainModel:GetSelectedCardValue()
    local value = 0
    local selectedList = self:GetSelectedCardList()
    for i, pcid in ipairs(selectedList) do
        value = value + self:GetCardModel(pcid):GetValue()
    end
    return value
end

-- 返回pcid的卡牌是否被选中
function CoachPlayerListMainModel:IsCardSelected(pcid)
    for k, v in pairs(self.selectdCardList) do
        if tostring(pcid) == tostring(k) and v == true then
            return true
        end
    end
end

function CoachPlayerListMainModel:GetSelectedCardList()
    local list = {}
    for pcid, v in pairs(self.selectdCardList) do
        if v == true then
            table.insert(list, pcid)
        end
    end
    return list
end

function CoachPlayerListMainModel:ToggleSelectCard(pcid)
    self.selectdCardList[tostring(pcid)] = not tobool(self.selectdCardList[tostring(pcid)])

    EventSystem.SendEvent("CoachPlayerListMainView_ToggleSelectCard", pcid, self.selectdCardList[tostring(pcid)])
end

-- 添加一个球员
function CoachPlayerListMainModel:AddCard(pcid)
    local cardModel = CardBuilder.GetOwnCardModel(pcid)
    self.cardModelMap[tostring(pcid)] = cardModel
    table.insert(self.sortCardList, pcid)
    -- 国籍
    if self.nationalityCidList[tostring(cardModel:GetNation())] == nil then
        self.nationalityCidList[tostring(cardModel:GetNation())] = {}
    end
    table.insert(self.nationalityCidList[tostring(cardModel:GetNation())], pcid)
    -- 质量
    local qualityIndex = cardModel:GetCardFixQuality()
    if self.qualityCidList[qualityIndex] == nil then
        self.qualityCidList[qualityIndex] = {}
    end
    table.insert(self.qualityCidList[qualityIndex], pcid)
end

return CoachPlayerListMainModel

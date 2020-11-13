local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")
local CardMemoryImproveModel = require("ui.models.cardDetail.memory.CardMemoryImproveModel")
local Model = require("ui.models.Model")

local CardMemorySelectModel = class(Model, "CardMemorySelectModel")

CardMemorySelectModel.SortType = {
    AttrAdd = "AttrAdd", -- 传奇记忆属性加成
    Power = "Power", -- 战力
    Level = "Level", -- 等级
    Obtain = "Obtain" -- 入手顺序
}

function CardMemorySelectModel:ctor(cid, filledPcid)
    self.cid = cid
    self.filledPcid = filledPcid -- 上层传下来的已经添加的卡牌pcid
    self.cardModels = nil
    self.idxMap = nil

    self.cardsMapModel = PlayerCardsMapModel.new()
    self.improveModel = CardMemoryImproveModel.new()

    self.selectedCard = nil

    self.currSortType = self.SortType.AttrAdd
    self.sortOrder = false -- false降序，true升序
    self.cardPowerCache = {} -- 缓存卡牌的战力，用于排序
    self.cardMemoryCache = {} -- 缓存卡牌传奇记忆属性加成，用于排序
    CardMemorySelectModel.super.ctor(self, cid)
end

function CardMemorySelectModel:Init(cid)
    self.cardModels = {}
    if self.cid == nil then return end

    local cidsMap = self.cardsMapModel:GetCardCidMaps()
    local pcids = cidsMap[self.cid] or {}
    for pcid, flag in pairs(pcids) do
        if flag then
            local cardModel = PlayerCardModel.new(pcid)
            local attrAdd = self.improveModel:GetAttrImprove(cardModel)
            if attrAdd > 0 then
                self.cardMemoryCache[tostring(pcid)] = attrAdd
                table.insert(self.cardModels, cardModel)
                if self.filledPcid and pcid == self.filledPcid then
                    self.selectedCard = cardModel -- 设置选中的卡牌为已添加的卡牌
                end
            end
        end
    end
    self:SortCardModels()
end

function CardMemorySelectModel:SetMemoryItemModel(model)
    self.memoryItemModel = model
end

function CardMemorySelectModel:GetCardModels()
    return self.cardModels or {}
end

-- 按照当前规则进行排序
function CardMemorySelectModel:SortCardModels()
    local sortFunc = self["SortBy" .. self.currSortType]
    if sortFunc and type(sortFunc) == "function" then
        sortFunc(self, self.cardModels, self.sortOrder, self.improveModel, self.cardPowerCache, self.cardMemoryCache)
    end
    self.idxMap = {}
    for k, cardModel in ipairs(self.cardModels) do
        local pcid = cardModel:GetPcid()
        self.idxMap[pcid] = tonumber(k)
    end
end

-- 比较函数
local function compare_core(sortOrder, a_val, b_val, a_pcid, b_pcid)
    a_val = tonumber(a_val)
    b_val = tonumber(b_val)
    a_pcid = tonumber(a_pcid)
    b_pcid = tonumber(b_pcid)

    if a_val < b_val then
        return sortOrder
    elseif a_val > b_val then
        return not sortOrder
    else -- 入手顺序老的在前
        return a_pcid < b_pcid
    end
end

-- 传奇记忆属性加成排序
function CardMemorySelectModel:SortByAttrAdd(cardModels, sortOrder, improveModel, powerCache, memoryCache)
    if table.isEmpty(cardModels) then return end

    table.sort(cardModels, function(a, b)
        local a_pcid = a:GetPcid()
        local b_pcid = b:GetPcid()
        local a_attr = memoryCache[tostring(a_pcid)] or 0
        local b_attr = memoryCache[tostring(b_pcid)] or 0
        return compare_core(sortOrder, a_attr, b_attr, a_pcid, b_pcid)
    end)
end

-- 战力排序
function CardMemorySelectModel:SortByPower(cardModels, sortOrder, improveModel, powerCache, memoryCache)
    if table.isEmpty(cardModels) then return end

    table.sort(cardModels, function(a, b)
        local a_pcid = a:GetPcid()
        local b_pcid = b:GetPcid()
        local a_power = 0
        local b_power = 0
        if powerCache[tostring(a_pcid)] then
            a_power = powerCache[tostring(a_pcid)]
        else
            a_power = tonumber(a:GetPower())
            powerCache[tostring(a_pcid)] = a_power
        end
        if powerCache[tostring(b_pcid)] then
            b_power = powerCache[tostring(b_pcid)]
        else
            b_power = tonumber(b:GetPower())
            powerCache[tostring(b_pcid)] = b_power
        end
        return compare_core(sortOrder, a_power, b_power, a_pcid, b_pcid)
    end)
end

-- 等级排序
function CardMemorySelectModel:SortByLevel(cardModels, sortOrder)
    if table.isEmpty(cardModels) then return end

    table.sort(cardModels, function(a, b)
        local a_level = a:GetLevel()
        local b_level = b:GetLevel()
        return compare_core(sortOrder, a_level, b_level, a:GetPcid(), b:GetPcid())
    end)
end

-- 入手顺序排序
function CardMemorySelectModel:SortByObtain(cardModels, sortOrder)
    if table.isEmpty(cardModels) then return end

    table.sort(cardModels, function(a, b)
        local a_pcid = a:GetPcid()
        local b_pcid = b:GetPcid()
        return compare_core(sortOrder, a_pcid, b_pcid, a_pcid, b_pcid)
    end)
end

-- 通过pcid获得某cardModel在当前列表中的index
function CardMemorySelectModel:GetIdxByPcid(pcid)
    return self.idxMap[pcid]
end

-- 获得选中的cardModel
function CardMemorySelectModel:GetSelectedCard()
    return self.selectedCard
end

-- 设置选中的cardModel
function CardMemorySelectModel:SetSelectedCard(cardModel)
    self.selectedCard = cardModel
end

-- 获得选中的cardModel的pcid
function CardMemorySelectModel:GetSelectedPcid()
    return self.selectedCard and self.selectedCard:GetPcid() or nil
end

-- 获得当前排序类型
function CardMemorySelectModel:GetCurrSortType()
    return self.currSortType
end

-- 设置当前排序类型
function CardMemorySelectModel:SetCurrSortType(sortType)
    if self.currSortType == sortType then
        self.sortOrder = not self.sortOrder
    else
        self.sortOrder = (sortType == self.SortType.Obtain) -- 入手顺序希望老的卡牌在前面，老的卡牌加成较大
    end
    self.currSortType = sortType
end

-- 获得当前排序方式，升序true降序false
function CardMemorySelectModel:GetCurrSortOrder()
    return self.sortOrder
end

-- 获得卡牌属性加成
function CardMemorySelectModel:GetAttrImprove(cardModel)
    return self.improveModel:GetAttrImprove(cardModel)
end

-- 确认选择后更新
function CardMemorySelectModel:UpdateAfterConfirm(data)
    local targetCard = data.card or {}
    local memoryCard = data.memoryCard or {}
    local oldCard = data.oldMemoryCard or {}
    if targetCard.pcid then
        self.cardsMapModel:ResetCardData(targetCard.pcid, targetCard)
    end
    if memoryCard.pcid then
        self.cardsMapModel:ResetCardData(memoryCard.pcid, memoryCard)
    end
    if oldCard.pcid then
        self.cardsMapModel:ResetCardData(oldCard.pcid, oldCard)
    end
end

function CardMemorySelectModel:GetQualityStr()
    return self.memoryItemModel:GetQualityStr()
end

-- 获得已被记忆的球员的pcid
function CardMemorySelectModel:GetFilledPcid()
    return self.filledPcid
end

return CardMemorySelectModel

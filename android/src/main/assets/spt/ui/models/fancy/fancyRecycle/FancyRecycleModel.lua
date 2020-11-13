local Model = require("ui.models.Model")
local FancyCard = require("data.FancyCard")
local FancyGroup = require("data.FancyGroup")
local FancyCardsMapModel = require("ui.models.fancy.FancyCardsMapModel")
local FancyRecycleModel = class(Model, "FancyRecycleModel")

function FancyRecycleModel:ctor()
    FancyRecycleModel.super.ctor(self)
    self:FilterCardList()
end

function FancyRecycleModel:FilterCardList()
    self.fancyCardsMapModel = FancyCardsMapModel.new()
    local cardList = self.fancyCardsMapModel:GetAllFancyCard()
    local filterCardList = {}
    local count = 1
    local ids
    local groupIDs = self:GetSelectGroupIDs()
    if groupIDs and next(groupIDs) then
        ids = groupIDs
    else
        ids = {}
        for i, v in pairs(FancyGroup) do
            table.insert(ids, i)
        end
    end

    local fCards = {}
    for i, v in pairs(ids) do
        local fancyCard = FancyGroup[tostring(v)].fancyCard
        for index, fid in ipairs(fancyCard) do
            local cardCacheData = cardList[fid]
            if cardCacheData then
                table.insert(fCards, {fid = fid, num = cardCacheData.num, quality = FancyCard[fid].quality, groupID = FancyCard[fid].groupID})
            end
        end
    end

    table.sort(fCards, function(a, b)
        local qualityA = a.quality
        local qualityB = b.quality
        if qualityA == qualityB then
            local groupA = a.groupID
            local groupB = b.groupID
            return groupA < groupB
        else
            return qualityA < qualityB
        end
    end)

    for i, v in ipairs(fCards) do
        for s = 1, v.num do
            local t = {}
            t.fid = v.fid
            t.index = count
            t.selected = false
            t.quality = v.quality
            count = count + 1
            table.insert(filterCardList, t)
        end
    end

    self.filterCardList = filterCardList
end

function FancyRecycleModel:GetFilterCardList()
    return self.filterCardList
end

function FancyRecycleModel:SetSelectGroupIDs(groupIDs)
    self.groupIDs = groupIDs
    self:FilterCardList()
end

function FancyRecycleModel:ResetSelectCards()
    for i, v in ipairs(self.filterCardList) do
        v.selected = false
    end
end

function FancyRecycleModel:GetSelectGroupIDs()
    return self.groupIDs
end

function FancyRecycleModel:GetSelectCards()
    local filterCardList = self:GetFilterCardList()
    local selectList = {}
    for i, v in ipairs(filterCardList) do
        if v.selected then
            if not selectList[v.fid] then
                selectList[v.fid] = 0
            end
            selectList[v.fid] = selectList[v.fid] + 1
        end
    end
    return selectList
end

function FancyRecycleModel:GetSelectFSCount()
    local pieceCount = 0
    local filterCardList = self:GetFilterCardList()
    for i, v in ipairs(filterCardList) do
        if v.selected then
            pieceCount = pieceCount + FancyCard[v.fid].fs
        end
    end
    return pieceCount
end

return FancyRecycleModel

local Model = require("ui.models.Model")
local FancyGroup = require("data.FancyGroup")
local FancyCard = require("data.FancyCard")
local FancyCardsMapModel = require("ui.models.fancy.FancyCardsMapModel")
local FancyBagModel = class(Model, "FancyBagModel")

function FancyBagModel:ctor()
    FancyBagModel.super.ctor(self)
    self:FilterCardList()
end

function FancyBagModel:FilterCardList()
    self.fancyCardsMapModel = FancyCardsMapModel.new()
    self:InitCount()
    local cardList = self.fancyCardsMapModel:GetAllFancyCard()
    local filterCardList = {}
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
    local selectQuality = self:GetSelectQuality()
    if not next(selectQuality) then
        selectQuality = nil
    end
    local fCards = {}
    for i, v in pairs(ids) do
        local fancyCard = FancyGroup[tostring(v)].fancyCard
        for index, fid in ipairs(fancyCard) do
            local cardCacheData = cardList[fid]
            if cardCacheData then
                local quality = FancyCard[fid].quality
                if (not selectQuality) or selectQuality[quality] then
                    table.insert(fCards, {fid = fid, num = cardCacheData.num, quality = FancyCard[fid].quality, groupID = FancyCard[fid].groupID})
                end
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
            return qualityA > qualityB
        end
    end)

    for i, v in ipairs(fCards) do
        for s = 1, v.num do
            local t = {}
            t.fid = v.fid
            table.insert(filterCardList, t)
        end
    end

    self.filterCardList = filterCardList
end

function FancyBagModel:GetFilterCardList()
    self:FilterCardList()
    return self.filterCardList
end

function FancyBagModel:InitCount()
    local cardList = self.fancyCardsMapModel:GetAllFancyCard()
    local count = 0
    for i, v in pairs(cardList) do
        count = count + v.num
    end
    self.count = count
end

function FancyBagModel:GetCount()
    return self.count
end

function FancyBagModel:SetSelectGroupIDs(groupIDs)
    self.groupIDs = groupIDs
    self:FilterCardList()
end

function FancyBagModel:GetSelectGroupIDs()
    return self.groupIDs
end

function FancyBagModel:SetSelectQuality(quality)
    self.quality = {}
    if quality then
        self.quality[tonumber(quality)] = true
    end
    self:FilterCardList()
end

function FancyBagModel:GetSelectQuality()
    return self.quality or {}
end

function FancyBagModel:IsFilterEmpty()
    local selectQuality = self:GetSelectQuality()
    local selectGroup = self:GetSelectGroupIDs()
    if selectQuality and next(selectQuality) then
        return false
    end
    if selectGroup and next(selectGroup) then
        return false
    end
    return true
end


return FancyBagModel

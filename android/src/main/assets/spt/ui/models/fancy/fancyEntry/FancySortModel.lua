local FancySort = require("data.FancySort")
local FancyGroup = require("data.FancyGroup")
local FancyCardsMapModel = require("ui.models.fancy.FancyCardsMapModel")
local Model = require("ui.models.Model")
local FancySortModel = class(Model, "FancySortModel")

function FancySortModel:ctor()
    FancySortModel.super.ctor(self)
end

function FancySortModel:Init(data)
    self.data = data
    self.fancyCardsMapModel = FancyCardsMapModel.new()
end

function FancySortModel:InitWithProtocol(data)
    assert(type(data) == "table")
    self:Init(data)
end

function FancySortModel:GetSortList()
    local sortList = {}
    for i, v in pairs(FancySort) do
        v.lightCount = 0
        v.haveNewCard = false
        for index, value in ipairs(v.groupID) do
            if not v.haveNewCard and self:IsHaveNewCard(value) then
                v.haveNewCard = true
            end
            v.sortId = tonumber(i)
        end
        table.insert(sortList, v)
    end
    table.sort(sortList, function(a, b)
        return a.order < b.order
    end)
    for i, v in ipairs(sortList) do
        v.sortIndex = i
    end
    return sortList
end

function FancySortModel:IsHaveNewCard(groupID)
    for k, v in pairs(FancyGroup[groupID].fancyCard) do
        if self.fancyCardsMapModel:IsNewTip(v) then
            return true
        end
    end
    return false
end

return FancySortModel

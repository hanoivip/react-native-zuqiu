local Card = require("data.DreamLeagueCard")
local DreamLeagueCardBaseModel = require("ui.models.dreamLeague.DreamLeagueCardBaseModel")

local Model = require("ui.models.Model")
local DreamStoreModel = class(Model, "DreamStoreModel")

function DreamStoreModel:ctor(data)
    self.data = data
    self.goodsList = data.goodsList
    self.itemList = {}
    self.cardList = {}

    self:InitCardList()
    self:InitItemList()
end

function DreamStoreModel:InitCardList()
    for k,v in pairs(self.goodsList) do
        if v.shopType == 1 then
            table.insert(self.cardList, v)
        end
    end
end

function DreamStoreModel:InitItemList()
    for k,v in pairs(self.goodsList) do
        if v.shopType == 2 then
            table.insert(self.itemList, v)
        end
    end
end

function DreamStoreModel:GetItemList()
    return self.itemList
end

function DreamStoreModel:GetCardList()

    return self.cardList
end

return DreamStoreModel

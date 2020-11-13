local Model = require("ui.models.Model")
local ItemsMapModel = require("ui.models.ItemsMapModel")
local ItemModel = require("ui.models.ItemModel")
local RedPacketMapModel = require("ui.models.RedPacketMapModel")
local ItemListConstants = require("ui.models.itemList.ItemListConstants")
local RedPacketModel = require("ui.models.RedPacketModel")
local ItemPlaceType = require("ui.scene.itemList.ItemPlaceType")

local ItemListModel = class(Model)

function ItemListModel:ctor()
    ItemListModel.super.ctor(self)
    self:Init()
end

function ItemListModel:Init()
    self.itemsMapModel = ItemsMapModel.new()
    self.redPacketMapModel = RedPacketMapModel.new()
    self.itemListData = { }
    self.itemModelMap = { }
end

function ItemListModel:InitData(order)
    self.itemListData = { }
    self.itemModelMap = { }
    local items = self.itemsMapModel:GetItems()
    for k, v in pairs(items) do
        if v.num ~= 0 then
            local itemModel = ItemModel.new(k)
            local isValid = itemModel:HasValid()
            local itemPlaceType = itemModel:GetItemType()
            if isValid and itemPlaceType == ItemPlaceType.Normal then
                table.insert(self.itemListData, k)
                self.itemModelMap[k] = itemModel
            end
        end
    end
    local redPacketAll = self.redPacketMapModel:GetRedPacketAll()
    
    for k, v in pairs(redPacketAll) do
        local redPacketModel = RedPacketModel.new(k)
        table.insert(self.itemListData, k)
        self.itemModelMap[k] = redPacketModel
    end
    self:SortItemList(order)
end

function ItemListModel:SortItemList(order)
    if order == ItemListConstants.SortType.QUALITY_ASCEND then
        table.sort(self.itemListData, function(a, b) 
                if self.itemModelMap[a]:GetQuality() == self.itemModelMap[b]:GetQuality() then
                    return self.itemModelMap[a]:GetBaseId() < self.itemModelMap[b]:GetBaseId()
                else
                    return self.itemModelMap[a]:GetQuality() < self.itemModelMap[b]:GetQuality()
                end
            end)
    elseif order == ItemListConstants.SortType.QUALITY_DSCEND then
        table.sort(self.itemListData, function(a, b)
                if self.itemModelMap[a]:GetQuality() == self.itemModelMap[b]:GetQuality() then
                    return self.itemModelMap[a]:GetBaseId() < self.itemModelMap[b]:GetBaseId()
                else
                    return self.itemModelMap[a]:GetQuality() > self.itemModelMap[b]:GetQuality()
                end
            end)
    elseif order == ItemListConstants.SortType.KIND_ASCEND then
        table.sort(self.itemListData, function(a, b)
                if self.itemModelMap[a]:GetBaseId() == self.itemModelMap[b]:GetBaseId() then
                    return self.itemModelMap[a]:GetQuality() > self.itemModelMap[b]:GetQuality()
                else
                    return self.itemModelMap[a]:GetBaseId() < self.itemModelMap[b]:GetBaseId()
                end
            end)
    elseif order == ItemListConstants.SortType.KIND_DSCEND then
        table.sort(self.itemListData, function(a, b)
                if self.itemModelMap[a]:GetBaseId() == self.itemModelMap[b]:GetBaseId() then
                    return self.itemModelMap[a]:GetQuality() > self.itemModelMap[b]:GetQuality()
                else
                    return self.itemModelMap[a]:GetBaseId() > self.itemModelMap[b]:GetBaseId()
                end
            end)
    end
end

function ItemListModel:GetListData()
    return self.itemListData
end

function ItemListModel:GetModel(id)
    return self.itemModelMap[tostring(id)]
end

return ItemListModel
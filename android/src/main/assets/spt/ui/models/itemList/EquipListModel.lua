local Model = require("ui.models.Model")
local EquipsMapModel = require("ui.models.EquipsMapModel")
local EquipModel = require("ui.models.EquipModel")
local ItemListConstants = require("ui.models.itemList.ItemListConstants")

local EquipListModel = class(Model)

function EquipListModel:ctor()
    EquipListModel.super.ctor(self)
    self:Init()
end

function EquipListModel:Init()
    self.equipsMapModel = EquipsMapModel.new()
    self.equipListData = { }
    self.equipModelMap = { }
end

function EquipListModel:InitData(order, isShowAllKinds, kinds)
    self.equipListData = { }
    self.equipModelMap = { }
    local equips = self.equipsMapModel:GetEquips()
    for k, v in pairs(equips) do
        if v.num ~= 0 then
            local equipModel = EquipModel.new(k)
            if isShowAllKinds or self:CheckKind(kinds, equipModel:GetType()) then
                table.insert(self.equipListData, k)
                self.equipModelMap[k] = equipModel
            end
        end
    end
    self:SortEquipList(order)
end

function EquipListModel:SortEquipList(order)
    if order == ItemListConstants.SortType.QUALITY_ASCEND then
        table.sort(self.equipListData, function(a, b) 
                if self.equipModelMap[a]:GetQuality() == self.equipModelMap[b]:GetQuality() then
                    return self.equipModelMap[a]:GetType() < self.equipModelMap[b]:GetType()
                else
                    return self.equipModelMap[a]:GetQuality() < self.equipModelMap[b]:GetQuality()
                end
            end)
    elseif order == ItemListConstants.SortType.QUALITY_DSCEND then
        table.sort(self.equipListData, function(a, b)
                if self.equipModelMap[a]:GetQuality() == self.equipModelMap[b]:GetQuality() then
                    return self.equipModelMap[a]:GetType() < self.equipModelMap[b]:GetType()
                else
                    return self.equipModelMap[a]:GetQuality() > self.equipModelMap[b]:GetQuality()
                end
            end)
    elseif order == ItemListConstants.SortType.KIND_ASCEND then
        table.sort(self.equipListData, function(a, b)
                if self.equipModelMap[a]:GetType() == self.equipModelMap[b]:GetType() then
                    return self.equipModelMap[a]:GetQuality() > self.equipModelMap[b]:GetQuality()
                else
                    return self.equipModelMap[a]:GetType() < self.equipModelMap[b]:GetType()
                end
            end)
    elseif order == ItemListConstants.SortType.KIND_DSCEND then
        table.sort(self.equipListData, function(a, b)
                if self.equipModelMap[a]:GetType() == self.equipModelMap[b]:GetType() then
                    return self.equipModelMap[a]:GetQuality() > self.equipModelMap[b]:GetQuality()
                else
                    return self.equipModelMap[a]:GetType() > self.equipModelMap[b]:GetType()
                end
            end)
    end
end

function EquipListModel:CheckKind(kinds, equipType)
    for i, v in ipairs(kinds) do
        if v == tonumber(equipType) then
            return true
        end
    end
    return false
end

function EquipListModel:GetListData()
    return self.equipListData
end

function EquipListModel:GetModel(eid)
    return self.equipModelMap[tostring(eid)]
end

return EquipListModel
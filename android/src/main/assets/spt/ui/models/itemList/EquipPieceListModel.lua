local Model = require("ui.models.Model")
local EquipPieceMapModel = require("ui.models.EquipPieceMapModel")
local EquipPieceModel = require("ui.models.EquipPieceModel")
local ItemListConstants = require("ui.models.itemList.ItemListConstants")

local EquipPieceListModel = class(Model)

function EquipPieceListModel:ctor()
    EquipPieceListModel.super.ctor(self)
    self:Init()
end

function EquipPieceListModel:Init()
    self.equipPieceMapModel = EquipPieceMapModel.new()
    self.equipPieceListData = { }
    self.equipPieceModelMap = { }
end

function EquipPieceListModel:InitData(order, isShowAllKinds, kinds)
    self.equipPieceListData = { }
    self.equipPieceModelMap = { }
    local equipPieces = self.equipPieceMapModel:GetEquipPieces()
    for k, v in pairs(equipPieces) do
        if v.num ~= 0 then
            local equipPieceModel = EquipPieceModel.new(k)
            if isShowAllKinds or self:CheckKind(kinds, equipPieceModel:GetType()) then
                table.insert(self.equipPieceListData, k)
                self.equipPieceModelMap[k] = equipPieceModel
            end
        end
    end
    self:SortEquipPieceList(order)
end

function EquipPieceListModel:SortEquipPieceList(order)
    if order == ItemListConstants.SortType.QUALITY_ASCEND then
        table.sort(self.equipPieceListData, function(a, b) 
                if self.equipPieceModelMap[a]:GetQuality() == self.equipPieceModelMap[b]:GetQuality() then
                    return self.equipPieceModelMap[a]:GetType() < self.equipPieceModelMap[b]:GetType()
                else
                    return self.equipPieceModelMap[a]:GetQuality() < self.equipPieceModelMap[b]:GetQuality()
                end
            end)
    elseif order == ItemListConstants.SortType.QUALITY_DSCEND then
        table.sort(self.equipPieceListData, function(a, b)
                if self.equipPieceModelMap[a]:GetQuality() == self.equipPieceModelMap[b]:GetQuality() then
                    return self.equipPieceModelMap[a]:GetType() < self.equipPieceModelMap[b]:GetType()
                else
                    return self.equipPieceModelMap[a]:GetQuality() > self.equipPieceModelMap[b]:GetQuality()
                end
            end)
    elseif order == ItemListConstants.SortType.KIND_ASCEND then
        table.sort(self.equipPieceListData, function(a, b)
                if self.equipPieceModelMap[a]:GetType() == self.equipPieceModelMap[b]:GetType() then
                    return self.equipPieceModelMap[a]:GetQuality() > self.equipPieceModelMap[b]:GetQuality()
                else
                    return self.equipPieceModelMap[a]:GetType() < self.equipPieceModelMap[b]:GetType()
                end
            end)
    elseif order == ItemListConstants.SortType.KIND_DSCEND then
        table.sort(self.equipPieceListData, function(a, b)
                if self.equipPieceModelMap[a]:GetType() == self.equipPieceModelMap[b]:GetType() then
                    return self.equipPieceModelMap[a]:GetQuality() > self.equipPieceModelMap[b]:GetQuality()
                else
                    return self.equipPieceModelMap[a]:GetType() > self.equipPieceModelMap[b]:GetType()
                end
            end)
    end
end

function EquipPieceListModel:CheckKind(kinds, equipPieceType)
    for i, v in ipairs(kinds) do
        if v == tonumber(equipPieceType) then
            return true
        end
    end
    return false
end

function EquipPieceListModel:GetListData()
    return self.equipPieceListData
end

function EquipPieceListModel:GetModel(pid)
    return self.equipPieceModelMap[tostring(pid)]
end

return EquipPieceListModel
local EventSystem = require ("EventSystem")
local Model = require("ui.models.Model")
local EquipsMapModel = require("ui.models.EquipsMapModel")
local EquipPieceMapModel = require("ui.models.EquipPieceMapModel")
local EquipItemModel = require("ui.models.cardDetail.EquipItemModel")
local Equipment = require("data.Equipment")
local EquipFromQuest = require("data.EquipFromQuest")

local ItemDetailModel = class(Model, "ItemDetailModel")

function ItemDetailModel:ctor(eid)
    ItemDetailModel.super.ctor(self)
    self.eid = eid
    self.equipsMapModel = EquipsMapModel.new()
    self.equipPieceMapModel = EquipPieceMapModel.new()
    self.equipItemModel = EquipItemModel.new()
    self.equipItemModel:InitWithStaticId(self.eid)
    self.staticData = Equipment[tostring(self.eid)]
end

function ItemDetailModel:GetEquipID()
    return self.eid
end

function ItemDetailModel:GetEquipNum()
    return self.equipsMapModel:GetEquipNum(self.eid)
end

function ItemDetailModel:GetEquipModel()
    return self.equipItemModel
end

function ItemDetailModel:GetEquipPieceNum()
    return self.equipPieceMapModel:GetEquipPieceNum(self.eid)
end

function ItemDetailModel:GetPieceName()
    return self.staticData.name
end

function ItemDetailModel:GetName()
    return self.staticData.name
end

function ItemDetailModel:GetNote()
    return self.staticData.note
end

function ItemDetailModel:GetQuality()
    return self.staticData.quality
end

function ItemDetailModel:GetUpgrade()
    return self.staticData.upgrade
end

function ItemDetailModel:GetBaseID()
    return self.staticData.baseID
end

-- 装备图片索引
function ItemDetailModel:GetIconIndex()
    return self.staticData.baseID
end

-- 等级限定
function ItemDetailModel:GetNeedCardLevel()
    return self.staticData.cardLvl
end

-- 合成装备需要的碎片数量
function ItemDetailModel:GetCompositePieceNum()
    return self.staticData.pieceNum
end

function ItemDetailModel:ResetEquipNum(eid, num)
    self.equipsMapModel:ResetEquipNum(eid, num)

    EventSystem.SendEvent("ItemDetailModel_ResetEquipNum")
end

function ItemDetailModel:ResetEquipPieceNum(data)
    self.equipPieceMapModel:ResetEquipPieceNum(data.del_piece.pid, data.del_piece.num)
end

-- 处理equip/incorporate(装备合成接口)的返回结果
function ItemDetailModel:ResetEquipAndPiece(data)
    self.equipsMapModel:ResetEquipNum(data.add_equip.eid, data.add_equip.num)
    self.equipPieceMapModel:ResetEquipPieceNum(data.del_piece.pid, data.del_piece.num)

    EventSystem.SendEvent("ItemDetailModel_ResetEquipAndPiece")
end

function ItemDetailModel:GetEquipSource()
    local stageIdTab = {}

    if type(EquipFromQuest[self.eid]) == "table" then
        for i, v in ipairs(EquipFromQuest[self.eid]) do
            if v.questID then
                table.insert(stageIdTab, v.questID)
            end
        end
    end

    return stageIdTab
end

return ItemDetailModel

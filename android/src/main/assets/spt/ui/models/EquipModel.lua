local Model = require("ui.models.Model")
local EquipsMapModel = require("ui.models.EquipsMapModel")
local EquipPieceMapModel = require("ui.models.EquipPieceMapModel")
local Equipment = require("data.Equipment")
local EquipFromQuest = require("data.EquipFromQuest")

local EquipModel = class(Model)

function EquipModel:ctor(eid)
    EquipModel.super.ctor(self)
    self.equipsMapModel = EquipsMapModel.new()
    self.equipPieceMapModel = EquipPieceMapModel.new()
    self.eid = eid
    self.staticData = Equipment[tostring(self.eid)]
end

function EquipModel:GetEid()
    return self.eid
end

function EquipModel:HasValid()
    return self.staticData and next(self.staticData)
end

function EquipModel:GetEquipNum()
    return self.equipsMapModel:GetEquipNum(self.eid)
end

function EquipModel:GetEquipPieceNum()
    return self.equipPieceMapModel:GetEquipPieceNum(self.eid)
end

function EquipModel:GetQuality()
    return self.staticData.quality
end

function EquipModel:GetName()
    return self.staticData.name
end

function EquipModel:GetIconIndex()
    return self.eid
end

function EquipModel:GetAddNum()
    return self:GetEquipNum()
end

function EquipModel:GetDesc()
    return self.staticData.note
end

function EquipModel:GetPieceNum()
    return self.staticData.pieceNum
end

function EquipModel:GetBaseId()
    return self.staticData.baseID
end

function EquipModel:GetFromQuest()
    return EquipFromQuest[tostring(self.eid)]
end

function EquipModel:GetLetterId()
    return self.staticData.letterturnID
end

function EquipModel:GetType()
    return self.staticData.type
end

return EquipModel

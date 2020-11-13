local Model = require("ui.models.Model")
local EquipPieceMapModel = require("ui.models.EquipPieceMapModel")
local Equipment = require("data.Equipment")
local EquipFromQuest = require("data.EquipFromQuest")

local EquipPieceModel = class(Model)

function EquipPieceModel:ctor(pid)
    EquipPieceModel.super.ctor(self)
    self.equipPieceMapModel = EquipPieceMapModel.new()
    self.pid = pid
    self.staticData = Equipment[tostring(self.pid)]
end

function EquipPieceModel:GetPid()
    return self.pid
end

function EquipPieceModel:GetEquipPieceNum()
    return self.equipPieceMapModel:GetEquipPieceNum(self.pid)
end

function EquipPieceModel:GetQuality()
    return self.staticData.quality
end

function EquipPieceModel:GetName()
    return self.staticData.name
end

function EquipPieceModel:GetIconIndex()
    return self.pid
end

function EquipPieceModel:GetAddNum()
    return self:GetEquipPieceNum()
end

function EquipPieceModel:GetPieceNum()
    return self.staticData.pieceNum
end

function EquipPieceModel:GetBaseId()
    return self.staticData.baseID
end

function EquipPieceModel:GetFromQuest()
    return EquipFromQuest[tostring(self.pid)]
end

function EquipPieceModel:GetLetterId()
    return self.staticData.letterturnID
end

function EquipPieceModel:GetType()
    return self.staticData.type
end

function EquipPieceModel:GetDesc()
    return self.staticData.note
end

return EquipPieceModel
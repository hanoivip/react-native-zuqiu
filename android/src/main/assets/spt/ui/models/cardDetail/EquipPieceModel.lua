local EventSystem = require ("EventSystem")
local Model = require("ui.models.Model")

local Equipment = require("data.Equipment")
local EquipItemModel = require("ui.models.cardDetail.EquipItemModel")

local EquipPieceModel = class(EquipItemModel, "EquipPieceModel")

function EquipPieceModel:ctor()
    EquipPieceModel.super.ctor(self)
end

function EquipPieceModel:InitWithCache(cache)
    self.cacheData = cache
    self.equipID = self.cacheData.pid
    self.staticData = Equipment[tostring(self.equipID)]
end

return EquipPieceModel
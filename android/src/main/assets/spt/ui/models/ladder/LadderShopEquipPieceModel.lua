local EquipPieceModel = require("ui.models.EquipPieceModel")

local LadderShopEquipPieceModel = class(EquipPieceModel, "LadderShopEquipPieceModel")

function LadderShopEquipPieceModel:ctor(id, num)
    LadderShopEquipPieceModel.super.ctor(self, id)
    self.equipPieceNum = num
end

function LadderShopEquipPieceModel:GetAddNum()
    return self.equipPieceNum
end

return LadderShopEquipPieceModel
local EquipModel = require("ui.models.EquipModel")

local LadderShopEquipModel = class(EquipModel, "LadderShopEquipModel")

function LadderShopEquipModel:ctor(id, num)
    LadderShopEquipModel.super.ctor(self, id)
    self.equipNum = num
end

function LadderShopEquipModel:GetAddNum()
    return self.equipNum
end

return LadderShopEquipModel
local BaseEquipModel = require("ui.models.base.BaseEquipModel")
local Equipment = require("data.Equipment")
local PlayerBindingEquipModel = class(BaseEquipModel, "PlayerBindingEquipModel")

function PlayerBindingEquipModel:ctor(equipID)
    PlayerBindingEquipModel.super.ctor(self, equipID)
    self:InitWithStaticId(equipID)
end

function PlayerBindingEquipModel:InitWithCache(cache)
    self.cacheData = cache
end

function PlayerBindingEquipModel:InitWithStaticId(equipID)
    self.staticData = Equipment[tostring(equipID)]
end

function PlayerBindingEquipModel:GetEquipID()
    return self.cacheData.eid
end

function PlayerBindingEquipModel:GetSlot()
    return self.cacheData.slot
end

function PlayerBindingEquipModel:GetQuality()
    return self.staticData.quality
end

function PlayerBindingEquipModel:IsEquip()
    return self.cacheData.isEquip
end

return PlayerBindingEquipModel

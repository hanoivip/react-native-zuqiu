local EventSystem = require ("EventSystem")
local Model = require("ui.models.Model")

local Equipment = require("data.Equipment")

local EquipItemModel = class(Model, "EquipItemModel")

function EquipItemModel:ctor()
    EquipItemModel.super.ctor(self)
    self.equipID = nil
    self.cacheData = {}
    self.staticData = {}
end

function EquipItemModel:InitWithCache(cache)
    self.cacheData = cache
    self.equipID = self.cacheData.eid
    self.staticData = Equipment[tostring(self.equipID)]
end

function EquipItemModel:InitWithStaticId(staticId)
    self.equipID = staticId
    self.staticData = Equipment[tostring(self.equipID)]
end

function EquipItemModel:GetEquipID()
    return self.equipID
end

function EquipItemModel:GetSlot()
    return self.cacheData.slot
end

function EquipItemModel:IsEquip()
    return self.cacheData.isEquip
end

function EquipItemModel:GetSum()
    return self.cacheData.num
end

function EquipItemModel:GetAddNum()
    return self.cacheData.add
end

function EquipItemModel:GetName()
    return self.staticData.name
end

function EquipItemModel:GetQuality()
    return self.staticData.quality
end

function EquipItemModel:GetUpgrade()
    return self.staticData.upgrade
end

function EquipItemModel:GetBaseID()
    return self.staticData.baseID
end

function EquipItemModel:GetNeedCardLevel()
    return self.staticData.cardLvl
end

function EquipItemModel:GetPieceNum()
    return self.staticData.pieceNum
end

-- 装备图片索引
function EquipItemModel:GetIconIndex()
    return self.equipID
end

return EquipItemModel

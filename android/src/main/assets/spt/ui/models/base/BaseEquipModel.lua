local Model = require("ui.models.Model")
local BaseEquipModel = class(Model, "BaseEquipModel")

local Equipment = require("data.Equipment")

-- param id 装备的静态ID
function BaseEquipModel:ctor(equipID)
    self.equipID = equipID
    self.staticData = Equipment[tostring(equipID)]
end

function BaseEquipModel:GetEquipID()
    return self.equipID
end

function BaseEquipModel:GetNote()
    return self.staticData.note
end

-- 对球员身价的提升值
function BaseEquipModel:GetPriceUp()
    return self.staticData.priceUp
end

function BaseEquipModel:GetName()
    return self.staticData.name
end

function BaseEquipModel:GetQuality()
    return self.staticData.quality
end

function BaseEquipModel:GetUpgrade()
    return self.staticData.upgrade
end

function BaseEquipModel:GetBaseID()
    return self.staticData.baseID
end

function BaseEquipModel:GetNeedCardLevel()
    return self.staticData.cardLvl
end

function BaseEquipModel:GetPieceNum()
    return self.staticData.pieceNum
end

-- 装备图片索引
function BaseEquipModel:GetIconIndex()
    return self.equipID
end


return BaseEquipModel

local BaseModel = require("ui.models.greensward.item.itemAction.GreenswardItemActionBaseModel")

local ItemActionTreasureOpenModel = class(BaseModel, "ItemActionTreasureOpenModel")

-- 绿茵征途使用道具，探宝行为model
function ItemActionTreasureOpenModel:Init(id, greenswardItemModel, greenswardBuildModel, eventModel)
    ItemActionTreasureOpenModel.super.Init(self, id, greenswardItemModel, greenswardBuildModel)
    self.eventModel = eventModel
end

-- 获得与此行为相关的eventModel
function ItemActionTreasureOpenModel:GetEventModel()
    return self.eventModel
end

function ItemActionTreasureOpenModel:GetRow()
    return self.eventModel:GetRow()
end

function ItemActionTreasureOpenModel:GetCol()
    return self.eventModel:GetCol()
end

function ItemActionTreasureOpenModel:GetCostType()
    return "item"
end

return ItemActionTreasureOpenModel

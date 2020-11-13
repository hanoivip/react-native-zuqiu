local BaseModel = require("ui.models.greensward.item.itemAction.GreenswardItemActionBaseModel")

local ItemActionAdvTriggerModel = class(BaseModel, "ItemActionAdvTriggerModel")

-- 绿茵征途使用道具，修改地图事件行为model
function ItemActionAdvTriggerModel:Init(id, greenswardItemModel, greenswardBuildModel, eventModel)
    ItemActionAdvTriggerModel.super.Init(self, id, greenswardItemModel, greenswardBuildModel)
    self.eventModel = eventModel
end

-- 获得与此行为相关的eventModel
function ItemActionAdvTriggerModel:GetEventModel()
    return self.eventModel
end

function ItemActionAdvTriggerModel:GetRow()
    return self.eventModel:GetRow()
end

function ItemActionAdvTriggerModel:GetCol()
    return self.eventModel:GetCol()
end

function ItemActionAdvTriggerModel:GetCostType()
    return "item"
end

return ItemActionAdvTriggerModel

local BaseModel = require("ui.models.greensward.item.itemAction.GreenswardItemActionBaseModel")

local ItemActionTreasureMapModel = class(BaseModel, "ItemActionTreasureMapModel")

-- 绿茵征途使用道具，查看藏宝图行为model
function ItemActionTreasureMapModel:Init(id, greenswardItemModel, greenswardBuildModel)
    ItemActionTreasureMapModel.super.Init(self, id, greenswardItemModel, greenswardBuildModel)
end

return ItemActionTreasureMapModel

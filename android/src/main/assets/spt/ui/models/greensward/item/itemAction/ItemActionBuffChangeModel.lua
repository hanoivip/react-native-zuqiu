local BaseModel = require("ui.models.greensward.item.itemAction.GreenswardItemActionBaseModel")

local ItemActionBuffChangeModel = class(BaseModel, "ItemActionBuffChangeModel")

-- 绿茵征途使用道具，修改自身buff行为model
function ItemActionBuffChangeModel:Init(id, greenswardItemModel, greenswardBuildModel)
    ItemActionBuffChangeModel.super.Init(self, id, greenswardItemModel, greenswardBuildModel)
end

return ItemActionBuffChangeModel

local BaseModel = require("ui.models.greensward.item.itemAction.GreenswardItemActionBaseModel")

local ItemActionMysticHintModel = class(BaseModel, "ItemActionMysticHintModel")

-- 绿茵征途使用道具，查看神秘指令行为model
function ItemActionMysticHintModel:Init(id, greenswardItemModel, greenswardBuildModel)
    ItemActionMysticHintModel.super.Init(self, id, greenswardItemModel, greenswardBuildModel)
end

return ItemActionMysticHintModel

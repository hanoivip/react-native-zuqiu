local BaseModel = require("ui.models.greensward.item.itemAction.GreenswardItemActionBaseModel")

local ItemActionWeakenOpponentModel = class(BaseModel, "ItemActionWeakenOpponentModel")

-- 绿茵征途使用道具，使用豪门小道报行为model
function ItemActionWeakenOpponentModel:Init(id, greenswardItemModel, greenswardBuildModel, eventModel)
    ItemActionWeakenOpponentModel.super.Init(self, id, greenswardItemModel, greenswardBuildModel)
    self.eventModel = eventModel
end

function ItemActionWeakenOpponentModel:GetEventModel()
    return self.eventModel
end

return ItemActionWeakenOpponentModel

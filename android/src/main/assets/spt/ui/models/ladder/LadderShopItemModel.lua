local ItemModel = require("ui.models.ItemModel")

local LadderShopItemModel = class(ItemModel, "LadderShopItemModel")

function LadderShopItemModel:ctor(id, num)
    LadderShopItemModel.super.ctor(self, id)
    self.itemNum = num
end

function LadderShopItemModel:GetAddNum()
    return self.itemNum
end

return LadderShopItemModel
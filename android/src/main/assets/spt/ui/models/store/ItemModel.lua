local Model = require("ui.models.Model")
local StoreModel = require("ui.models.store.StoreModel")

local ItemModel = class(Model)

ItemModel.FlagColors = {
    [1] = StoreModel.HotColor.RED,
    [2] = StoreModel.HotColor.GOLD,
}

function ItemModel:ctor(data)
    self:Init(data)
end

-- 待实现
function ItemModel:Init(data)
    dump("not implemented")
end

function ItemModel:IsHighlight()
    return tobool(self.data.highlight)
end

function ItemModel:IsHot()
    return type(self.data.hot) == "table"
end

function ItemModel:GetHotText()
    if self:IsHot() then
        return self.data.hot.text
    end
end

function ItemModel:GetHotColor()
    if self:IsHot() then
        return self.data.hot.color
    end
end

function ItemModel:GetItemPrice()
    return self.data.price
end

function ItemModel:SetItemPrice(price)
    if price then
        self.data.price = price
    end
end


return ItemModel

local EventSystem = require("EventSystem")
local Model = require("ui.models.Model")

local ExchangeItem = require("data.ExchangeItem")

local ExchangeItemModel = class(Model, "ExchangeItemModel")

function ExchangeItemModel:ctor()
    ExchangeItemModel.super.ctor(self)
end

function ExchangeItemModel:InitWithCache(cache)
    self.cacheData = cache
    self.staticData = ExchangeItem[tostring(self.cacheData.id)] or {}
end

function ExchangeItemModel:InitWithStaticId(staticId)
    self.staticData = ExchangeItem[tostring(staticId)] or {}
end

function ExchangeItemModel:GetID()
    return self.cacheData.id
end

function ExchangeItemModel:GetSum()
    return self.cacheData.num
end

function ExchangeItemModel:GetAddNum()
    return self.cacheData.add
end

function ExchangeItemModel:GetName()
    return self.staticData.name
end

function ExchangeItemModel:GetQuality()
    return self.staticData.quality or 0
end

function ExchangeItemModel:GetIconIndex()
    return self.staticData.picIndex
end

function ExchangeItemModel:GetDesc()
    return self.staticData.desc
end

function ExchangeItemModel:GetAccess()
    return self.staticData.access
end

function ExchangeItemModel:CanBeUsed()
    if self.staticData.usage == 0 then
        return false
    else
        return true
    end
end

function ExchangeItemModel:CanBeSaled()
    if self.staticData.sale == 0 then
        return false
    else
        return true
    end
end

function ExchangeItemModel:GetPrice()
    return self.staticData.price
end

return ExchangeItemModel

local Model = require("ui.models.Model")
local MarblesExchangeItem = require("data.MarblesExchangeItem")

local MarblesItemModel = class(Model, "MarblesItemModel")

function MarblesItemModel:ctor()
    MarblesItemModel.super.ctor(self)
end

function MarblesItemModel:InitWithCache(cache)
    self.cacheData = cache
    self.staticData = MarblesExchangeItem[tostring(self.cacheData.id)] or {}
end

function MarblesItemModel:InitWithStaticId(staticId)
    self.staticData = MarblesExchangeItem[tostring(staticId)] or {}
end

function MarblesItemModel:GetID()
    return self.cacheData.id
end

function MarblesItemModel:GetSum()
    return self.cacheData.num
end

function MarblesItemModel:GetAddNum()
    return self.cacheData.add
end

function MarblesItemModel:GetName()
    return self.staticData.name
end

function MarblesItemModel:GetQuality()
    return self.staticData.quality or 0
end

function MarblesItemModel:GetIconIndex()
    return self.staticData.picIndex
end

function MarblesItemModel:GetDesc()
    return self.staticData.desc
end

function MarblesItemModel:GetAccess()
    return self.staticData.access
end

function MarblesItemModel:CanBeUsed()
    if self.staticData.usage == 0 then
        return false
    else
        return true
    end
end

function MarblesItemModel:CanBeSaled()
    if self.staticData.sale == 0 then
        return false
    else
        return true
    end
end

function MarblesItemModel:GetPrice()
    return self.staticData.price
end

return MarblesItemModel

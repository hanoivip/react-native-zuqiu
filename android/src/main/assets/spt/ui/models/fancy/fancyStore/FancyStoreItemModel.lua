local Model = require("ui.models.Model")
local FancyStoreItemModel = class(Model, "FancyStoreItemModel")

function FancyStoreItemModel:ctor()
    FancyStoreItemModel.super.ctor(self)
end

function FancyStoreItemModel:Init(data)
    self.data = data
end

-- 获取一次购买的数量
function FancyStoreItemModel:GetCount()
    return self.data.count
end

-- 获取限购类型
function FancyStoreItemModel:GetLimitType()
    return self.data.limitType
end

-- 获取弹板类型
function FancyStoreItemModel:GetPlate()
    return self.data.plate
end

-- 获取价格
function FancyStoreItemModel:GetPrice()
    return self.data.price
end

-- 获取货币类型
function FancyStoreItemModel:GetCurrencyType()
    return self.data.currencyType
end

-- 获取内部ID
function FancyStoreItemModel:GetSubID()
    return self.data.subID
end

-- 获取商品ID
function FancyStoreItemModel:GetGoodsID()
    return self.data.goodsID
end

-- 获取限购数量
function FancyStoreItemModel:GetLimitAmount()
    return self.data.limitAmount
end

-- 获取商品类型
function FancyStoreItemModel:GetGoodsType()
    return self.data.goodsType
end

-- 获取当期已购数量
function FancyStoreItemModel:GetCnt()
    return self.data.cnt
end

-- 获取期数
function FancyStoreItemModel:GetID()
    return self.data.ID
end

return FancyStoreItemModel
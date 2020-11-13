local FancyStoreItemModel = require("ui.models.fancy.fancyStore.FancyStoreItemModel")
local Model = require("ui.models.Model")
local FancyStoreModel = class(Model, "FancyStoreModel")

function FancyStoreModel:ctor()
    FancyStoreModel.super.ctor(self)
end

function FancyStoreModel:Init(data)
    self.data = data
end

function FancyStoreModel:InitWithProtocol(data)
    assert(type(data) == "table")
    self:Init(data)
end

-- 获取结束时间（下次更新时间）
function FancyStoreModel:GetEndTime()
    local refreshTime = ""
    if self.data.endTime then
        refreshTime = string.convertSecondToMonth(self.data.endTime)
    end
    return refreshTime
end

-- 获取商城列表
function FancyStoreModel:GetGoodsList()
    local goodsList = {}
    if self.data.list then
        for i, v in pairs(self.data.list) do
            local fancyStoreItemModel = FancyStoreItemModel.new()
            fancyStoreItemModel:Init(v)
            table.insert(goodsList, fancyStoreItemModel)
        end
        table.sort(goodsList, function (a, b)
            return a:GetSubID() < b:GetSubID()
        end)
    end
    return goodsList
end

return FancyStoreModel
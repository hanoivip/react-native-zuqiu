local EventSystem = require ("EventSystem")
local Model = require("ui.models.Model")

local ItemsMapModel = class(Model, "ItemsMapModel")

function ItemsMapModel:ctor()
    ItemsMapModel.super.ctor(self)
end

function ItemsMapModel:Init(data)
    if not data then
        data = cache.getItemsMap()
    end
    self.data = data
end

function ItemsMapModel:InitWithProtocol(data)
    assert(type(data) == "table")
    local itemsMap = {}
    for i, v in ipairs(data) do
        itemsMap[tostring(v.id)] = v
    end
    cache.setItemsMap(itemsMap)
    self:Init(itemsMap)
end

function ItemsMapModel:GetItems()
    return self.data
end

function ItemsMapModel:GetItemData(id)
    return self.data[tostring(id)]
end

function ItemsMapModel:GetItemNum(id)
    return self.data[tostring(id)] and self.data[tostring(id)].num or 0
end

function ItemsMapModel:ResetItemNum(id, num)
    assert(id and num and type(num) == "number")
    local idStr = tostring(id)
    if not self.data[idStr] then
        self.data[idStr] = {}
        self.data[idStr].id = id
    end
    self.data[idStr].num = num

    EventSystem.SendEvent("ItemsMapModel_ResetItemNum", id, num)
end

function ItemsMapModel:UpdateFromReward(rewardTable)
    assert(rewardTable and type(rewardTable) == "table")
    if not rewardTable.item then return end

    for i, v in ipairs(rewardTable.item) do
        self:ResetItemNum(v.id, v.num)
    end

    EventSystem.SendEvent("ItemsMapModel_UpdateFromReward")
end

return ItemsMapModel

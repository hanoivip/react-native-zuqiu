local Model = require("ui.models.Model")
local EventSystem = require("EventSystem")
local GreenswardItemType = require("ui.models.greensward.item.configType.GreenswardItemType")
local GreenswardItemUseAfterType = require("ui.models.greensward.item.configType.GreenswardItemUseAfterType")
local GreenswardItemClass = require("ui.models.greensward.item.configType.GreenswardItemClass")
local GreenswardItemModel = require("ui.models.greensward.item.GreenswardItemModel")
local AdventureItem = require("data.AdventureItem")

local GreenswardItemMapModel = class(Model, "GreenswardItemMapModel")

-- 所有绿茵征途道具
function GreenswardItemMapModel:ctor(greenswardItem)
    self.items = {} -- 所有道具, { id = num, id = num, ... }
    GreenswardItemMapModel.super.ctor(self)

    if greenswardItem then
        self:InitWithProtocol(greenswardItem)
    end
end

function GreenswardItemMapModel:Init(greenswardItem)
    if table.isEmpty(greenswardItem) then
        self.items = cache.getGreenswardItem()
    else
        self:UpdateCache(greenswardItem)
    end
end

function GreenswardItemMapModel:InitWithProtocol(greenswardItem)
    self:Init(greenswardItem)
end

-- 更新缓存
function GreenswardItemMapModel:UpdateCache(greenswardItem)
    if greenswardItem then
        self.items = greenswardItem
    end
    cache.setGreenswardItem(self.items)
end

-- 获得所有物品数据
function GreenswardItemMapModel:GetItemsData()
    return self.items
end

-- 获得道具的model
function GreenswardItemMapModel:GetItemModelById(id)
    id = tostring(id)
    local itemModel = nil
    if AdventureItem[id] then
        itemModel = GreenswardItemModel.new(id)
        itemModel:SetOwnNum(self:GetItemNum(id))
    end
    return itemModel
end

-- 获得所有道具的model
function GreenswardItemMapModel:GetItemModels()
    local result = {}
    for id, num in pairs(self.items) do
        if num > 0 then
            table.insert(result, self:GetItemModelById(id))
        end
    end
    return result
end

-- 设置物品数量
function GreenswardItemMapModel:SetItemNum(id, num, needUpdateCache)
    num = math.clamp(num, 0, num)
    self.items[tostring(id)] = num
    EventSystem.SendEvent("Greensward_Item_Change", id, num)
    if needUpdateCache then
        self:UpdateCache()
    end
end

-- 获得物品数量
function GreenswardItemMapModel:GetItemNum(id)
    return tonumber(self.items[tostring(id)])
end

-- 传入的道具列表，玩家是否满足数量条件
-- 有一个配置的满足即可
-- @param itemList: 
-- itemList = {
--     {
--         id = 1001,
--         num = 1
--     },
--     {
--         id = 1002,
--         num = 2
--     }
-- }
function GreenswardItemMapModel:HasItemFill(itemList)
    local isFill = false
    for k, v in ipairs(itemList or {}) do
        local num = self:GetItemNum(tostring(v.id))
        if num >= tonumber(v.num) then
            isFill = true
            break
        end
    end
    return isFill
end

-- 传入的道具列表，玩家是否满足数量条件
-- 所有配置的道具都满足
-- @param itemList: 同HasItemFill
function GreenswardItemMapModel:HasItemAllFill(itemList)
    if table.isEmpty(itemList) then
        return false
    end
    local isFill = true
    for k, v in ipairs(itemList) do
        local num = self:GetItemNum(tostring(v.id))
        isFill = isFill and num >= tonumber(v.num)
        if not isFill then
            break
        end
    end
    return isFill
end

-- 从奖励中更新物品，格式固定
-- @param rewards [table]: contents或者gifts
-- num表示当前数目
-- add/reduce表示增/减
function GreenswardItemMapModel:UpdateItemsFromRewards(rewards)
    for k, reward in ipairs(rewards.advItem or {}) do
        local id = tostring(reward.id)
        local num = tonumber(reward.num)
        self:SetItemNum(id, num, false)
    end
    self:UpdateCache()
    EventSystem.SendEvent("Greensward_Item_Reward")
end

-- 从消耗中更新物品，格式固定
-- @param cost [table]: cost
-- cost = {
--     advItem = {
--         {
--             id = 18,
--             num = 8,
--             reduce = 1,
--         },
--     },
-- },
function GreenswardItemMapModel:UpdateItemsFromCost(cost)
    for k, v in ipairs(cost.advItem or {}) do
        local id = tostring(v.id)
        local num = tonumber(v.num or v.curr_num)
        self:SetItemNum(id, num, false)
    end
    self:UpdateCache()
end

function GreenswardItemMapModel:GetItemBoxPrefabPathByType(advItemType)
    if advItemType == GreenswardItemType.Comsumables then -- 消耗道具
        return "Assets/CapstonesRes/Game/UI/Common/Part/AdventureItemBox.prefab"
    elseif advItemType == GreenswardItemType.Preserve then -- 特殊道具
        return "Assets/CapstonesRes/Game/UI/Common/Part/AdventureItemBox.prefab"
    elseif advItemType == GreenswardItemType.Logo then -- 徽章
        return "Assets/CapstonesRes/Game/UI/Common/Part/AdventureItemBox.prefab"
    elseif advItemType == GreenswardItemType.Frame then -- 边框
        return "Assets/CapstonesRes/Game/UI/Common/Part/AdventureItemBox.prefab"
    else
        return ""
    end
    -- 先这样做，目前边框和徽章需求不明确
end

-- 使用后不删除的道具是否失去使用功能
function GreenswardItemMapModel:IsItemUsed(itemModel, buildModel)
    if itemModel:GetAfterUseType() == GreenswardItemUseAfterType.Viewonly then
        if itemModel:GetItemClass() == GreenswardItemClass.TreasureMap then -- 藏宝图
            if buildModel then
                local useCondition = itemModel:GetUseCondition()
                local res = false
                for k, floor in ipairs(useCondition) do
                    res = res or buildModel:IsTreasureFound(floor)
                end
                return res
            end
        end
    end
    return false
end

return GreenswardItemMapModel

local GreenswardItemMapModel = require("ui.models.greensward.item.GreenswardItemMapModel")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local ItemType = require("ui.scene.itemList.ItemType")
local LimitType = require("ui.scene.itemList.LimitType")
local AdventureStore = require("data.AdventureStore")
local Model = require("ui.models.Model")

local GreenswardStoreItemModel = class(Model, "GreenswardStoreItemModel")

-- @param id [string]: 商品的id
-- @param storeType [string]: 商品的所在商店类别，1-6，详见GreenswardStoreType
function GreenswardStoreItemModel:ctor(id, storeType)
    self.itemMapModel = GreenswardItemMapModel.new()
    self.id = nil
    self.storeType = storeType
    self.staticData = {}
    self.cache = {}
    self.itemId = nil
    self.itemType = ItemType.AdvItem

    if id and storeType then
        self:InitWithId(id)
    end

    GreenswardStoreItemModel.super.ctor(self)
end

function GreenswardStoreItemModel:Init(id)
    GreenswardStoreItemModel.super.Init(self)
    self.itemMapModel:Init()

    if id then
        self:InitWithId(id)
    end
end

function GreenswardStoreItemModel:InitWithId(id)
    self:SetId(id)
    if self.id then
        self.staticData = AdventureStore[self.storeType][self.id] or {}
        self.itemId = self.staticData.itemId
        self.itemType = self.staticData.itemType
    end
end

function GreenswardStoreItemModel:InitWithCache(cache)
    if cache then
        self.cacheData = cache
    end
end

-- 获得商品id
function GreenswardStoreItemModel:GetId()
    return self.id
end

function GreenswardStoreItemModel:SetId(id)
    self.id = tostring(id)
end

-- 获得商品名称（目前是道具的名称）
function GreenswardStoreItemModel:GetName()
    if self.corrItemModel then
        if self.corrItemModel.GetName ~= nil and type(self.corrItemModel.GetName) == "function" then
            return self.corrItemModel:GetName()
        else
            return ""
        end
    else
        return ""
    end
end

-- 获得商品id
function GreenswardStoreItemModel:GetItemId()
    return self.itemId
end

-- 获得商品类型
function GreenswardStoreItemModel:GetItemType()
    return self.itemType
end

-- 获得所在商店的类型
function GreenswardStoreItemModel:GetStoreType()
    return self.staticData.storeType
end

-- 获得商品购买所需货币
function GreenswardStoreItemModel:GetCurrencyType()
    return self.staticData.currencyType
end

-- 获得原价
function GreenswardStoreItemModel:GetOrdinalPrice()
    return self.staticData.ordinalPrice
end

-- 获得现价
function GreenswardStoreItemModel:GetPrice()
    return self.staticData.price
end

-- 获得限购类型
function GreenswardStoreItemModel:GetLimitType()
    return self.staticData.limitType
end

-- 获得限购次数
function GreenswardStoreItemModel:GetLimitAmount()
    return self.staticData.limitAmount
end

-- 获得content
function GreenswardStoreItemModel:GetContents()
    return self.staticData.contents
end

-- 购买弹板
function GreenswardStoreItemModel:GetPlate()
    return self.staticData.plate
end

-- 获得已经购买次数
function GreenswardStoreItemModel:GetBought()
    return self.bought or 0
end

function GreenswardStoreItemModel:SetBought(num)
    self.bought = num
end

-- 获得限购描述 TODO
function GreenswardStoreItemModel:GetLimitDesc()
    local desc = ""
    local limitType = self:GetLimitType()
    local limitAmount = self:GetLimitAmount()
    local cnt = self:GetBought()
    if limitType == LimitType.NoLimit then
        desc = lang.trans("time_limit_guild_carnival_guild_limit_1") -- 不限购
    elseif limitType == LimitType.DayLimit then
        desc = lang.trans("time_limit_guild_carnival_guild_limit_2", limitAmount - cnt, limitAmount) -- 每日可够
    elseif limitType == LimitType.ForeverLimit then
        desc = lang.trans("limit_type_one_season", limitAmount - cnt, limitAmount) -- 本赛季期间可购
    elseif limitType == LimitType.TimeLimit then
        desc = lang.trans("limit_type_time_limit", limitAmount - cnt, limitAmount)
    elseif limitType == LimitType.ExistLimit then
        desc = lang.trans("limit_type_exist_limit", limitAmount - cnt, limitAmount)
    elseif limitType == LimitType.PlayerLimit then
        desc = lang.trans("limit_type_player_limit", limitAmount - cnt, limitAmount)
    end
    return desc
end

function GreenswardStoreItemModel:IsPurchaseLimit()
    if limitType ~= LimitType.NoLimit then
        return self:GetBought() >= self:GetLimitAmount()
    else
        return false
    end
end

-- 列表中索引
function GreenswardStoreItemModel:SetIdx(idx)
    self.idx = idx
end

function GreenswardStoreItemModel:GetIdx()
    return self.idx
end

function GreenswardStoreItemModel:SetCorrelationItemModel(corrItemModel)
    self.corrItemModel = corrItemModel
end

-- 列表中是否被选中
function GreenswardStoreItemModel:SetSelected(flag)
    self.selected = flag
end

function GreenswardStoreItemModel:GetSelected()
    return self.selected
end

return GreenswardStoreItemModel

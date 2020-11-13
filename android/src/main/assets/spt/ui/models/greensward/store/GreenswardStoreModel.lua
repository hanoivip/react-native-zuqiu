local GreenswardItemMapModel = require("ui.models.greensward.item.GreenswardItemMapModel")
local GreenswardStoreItemModel = require("ui.models.greensward.store.GreenswardStoreItemModel")
local GreenswardItemType = require("ui.models.greensward.item.configType.GreenswardItemType")
local GreenswardStoreType = require("ui.models.greensward.store.GreenswardStoreType")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local AdventureStore = require("data.AdventureStore")
local Model = require("ui.models.Model")

local GreenswardStoreModel = class(Model, "GreenswardStoreModel")

GreenswardStoreModel.StoreType = {
    ItemStore = tostring(GreenswardStoreType.ItemStore), -- 道具
    Logo = tostring(GreenswardStoreType.Logo), -- 徽章
    Frame = tostring(GreenswardStoreType.Frame), -- 边框
}

GreenswardStoreModel.StoreOpen = {
    ItemStore = true, -- 道具
    Logo = true, -- 徽章
    Frame = true, -- 边框
}

function GreenswardStoreModel:ctor()
    self.itemMapModel = GreenswardItemMapModel.new()
    self.itemModels = {} -- 所有商品的model
    self.currItemModels = {} -- 当前页面下的商品的Model

    self.tab = self.StoreType.ItemStore -- 默认tab为徽章商店

    self.selectedIdx = {}

    GreenswardStoreModel.super.ctor(self)
end

function GreenswardStoreModel:Init()
    GreenswardStoreModel.super.Init(self)

    self.itemModels = self:ParseConfig()
end

function GreenswardStoreModel:InitWithProtocol(data)
    self.cacheData = data
    -- 解析道具商城的已购情况
    for storeType, models in pairs(self.itemModels) do
        for k, itemModel in ipairs(models or {}) do
            local boughtRecord = data[tostring(itemModel:GetId())]
            if boughtRecord then
                itemModel:SetBought(boughtRecord.buy or 0)
            end
        end
    end
end

-- 将AdventureStore中的配置转换成model
function GreenswardStoreModel:ParseConfig()
    local items = {}
    for k, storeType in pairs(self.StoreType) do
        if self.StoreOpen[k] then
            items[storeType] = {}
            local configs = AdventureStore[storeType]
            if not table.isEmpty(configs) then
                for id, config in pairs(configs) do
                    local itemModel = GreenswardStoreItemModel.new(id, tostring(storeType))
                    table.insert(items[storeType], itemModel)
                end
            end
        end
    end

    return items
end

function GreenswardStoreModel:SetGreenswardBuildModel(greenswardBuildModel)
    self.buildModel = greenswardBuildModel
end

function GreenswardStoreModel:GetGreenswardBuildModel()
    return self.buildModel
end

-- 获得玩家当前装配的徽章和边框
function GreenswardStoreModel:GetCurrBadgeId()
    return self.buildModel:GetCurrBadgeId()
end

function GreenswardStoreModel:GetCurrFrameId()
    return self.buildModel:GetCurrFrameId()
end

function GreenswardStoreModel:GetCurrAvatarPicIndex()
    return self.buildModel:GetCurrAvatarPicIndex()
end

-- 获得当前页签下所需所有商品model
function GreenswardStoreModel:GetCurrItemModels()
    self.currItemModels = self.itemModels[self.tab] or {}

    table.sort(self.currItemModels, function(a, b)
        return tonumber(a:GetId()) < tonumber(b:GetId())
    end)

    for idx, itemModel in ipairs(self.currItemModels) do
        itemModel:SetIdx(tonumber(idx))
    end

    if table.nums(self.currItemModels) > 0 then
        local currIdx = self:GetSelectedIdx()
        if currIdx ~= nil then
            self:SetSelectedIdx(currIdx) -- 之前选中的
        else
            self:SetSelectedIdx(1) -- 默认选中第一个
        end
    else
        self:SetSelectedIdx(nil) -- 列表为空选中为空
    end

    return self.currItemModels
end

-- 获得当前选中的道具的索引
function GreenswardStoreModel:GetSelectedIdx()
    return self.selectedIdx[self.tab]
end

function GreenswardStoreModel:SetSelectedIdx(idx)
    local oldIdx = self:GetSelectedIdx()
    local itemNum = #self.currItemModels
    if oldIdx and oldIdx <= itemNum then
        self.currItemModels[oldIdx]:SetSelected(false)
    end
    self.selectedIdx[self.tab] = idx
    local currIdx = self:GetSelectedIdx()
    if currIdx and currIdx <= itemNum then
        self.currItemModels[currIdx]:SetSelected(true)
    end
end

-- 获得当前选中的商品的model
-- @return [GreenswardStoreItemModel]
function GreenswardStoreModel:GetSelectedItemModel()
    local itemModel = nil
    local currIdx = self:GetSelectedIdx()
    if currIdx ~= nil then
        itemModel = self.currItemModels[currIdx]
    end
    return itemModel
end

-- 获得当前选中的页签
function GreenswardStoreModel:GetCurrTab()
    return self.tab
end

-- 设置选中页签
function GreenswardStoreModel:SetCurrTab(tab)
    self.tab = tostring(tab)
end

-- 判断所使用的货币是否充足
function GreenswardStoreModel:IsCostEnough(cType, cost)
    if not self.playerInfoModel then
        self.playerInfoModel = PlayerInfoModel.new()
    end
    return self.playerInfoModel:IsCostEnough(cType, cost)
end

-- 购买后更新
function GreenswardStoreModel:UpdateAfterPurchased(data, storeItemModel, isItem)
    local cost = data.cost
    local buyRecord = data.buyRecord or {}
    local contents = data.contents or {}
    self.buildModel:CostDetail(cost)
    if isItem then
        self.itemMapModel:Init()
    else
        self.itemMapModel:UpdateItemsFromRewards(contents)
    end
    local commodityId = tostring(storeItemModel:GetId())
    for id, buyData in pairs(buyRecord) do
        if commodityId == tostring(id) then
            storeItemModel:SetBought(buyData.buy or 0)
            break
        end
    end
end

return GreenswardStoreModel

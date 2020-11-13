local GreenswardItemMapModel = require("ui.models.greensward.item.GreenswardItemMapModel")
local GreenswardStoreItemModel = require("ui.models.greensward.store.GreenswardStoreItemModel")
local GreenswardStoreType = require("ui.models.greensward.store.GreenswardStoreType")
local GreenswardItemType = require("ui.models.greensward.item.configType.GreenswardItemType")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local AdventureItem = require("data.AdventureItem")
local Model = require("ui.models.Model")

local GreenswardAvatarSelectModel = class(Model, "GreenswardAvatarSelectModel")

GreenswardAvatarSelectModel.AvatarType = {
    Logo = tostring(GreenswardItemType.Logo), -- 徽章
    Frame = tostring(GreenswardItemType.Frame), -- 边框
}

function GreenswardAvatarSelectModel:ctor(greenswardItemMapModel)
    self.itemMapModel = greenswardItemMapModel or GreenswardItemMapModel.new()
    self.itemModels = {} -- 所有边框和徽章的model
    self.currItemModels = {} -- 当前页面下的道具的Model

    self.tab = self.AvatarType.Logo -- 默认tab为徽章

    self.selectedIdx = {}

    GreenswardAvatarSelectModel.super.ctor(self)
end

function GreenswardAvatarSelectModel:Init()
    GreenswardAvatarSelectModel.super.Init(self)

    self.itemModels = self:ParseConfig()
end

-- 将AdventureItem中的配置转换成model
function GreenswardAvatarSelectModel:ParseConfig()
    local items = {}
    for key, avatarType in pairs(self.AvatarType) do
        items[avatarType] = {}
    end
    for configId, config in pairs(AdventureItem) do
        local avatarType = tostring(config.itemType)
        if items[avatarType] ~= nil then
            table.insert(items[avatarType], self.itemMapModel:GetItemModelById(configId))
        end
    end
    return items
end

function GreenswardAvatarSelectModel:SetGreenswardBuildModel(greenswardBuildModel)
    self.buildModel = greenswardBuildModel
end

function GreenswardAvatarSelectModel:GetGreenswardBuildModel()
    return self.buildModel
end

function GreenswardAvatarSelectModel:GetItemMapModel()
    return self.itemMapModel
end

-- 获得玩家当前装配的徽章和边框
function GreenswardAvatarSelectModel:GetCurrBadgeId()
    return self.buildModel:GetCurrBadgeId()
end

function GreenswardAvatarSelectModel:GetCurrFrameId()
    return self.buildModel:GetCurrFrameId()
end

function GreenswardAvatarSelectModel:GetCurrAvatarPicIndex()
    return self.buildModel:GetCurrAvatarPicIndex()
end

-- 获得当前页签下所需所有物品model
function GreenswardAvatarSelectModel:GetCurrItemModels()
    self.currItemModels = self.itemModels[self.tab] or {}

    -- 已拥有 > 未拥有，内部id排序
    table.sort(self.currItemModels, function(a, b)
        local a_num = a:GetOwnNum()
        local b_num = b:GetOwnNum()
        if a_num < b_num then
            return false
        elseif a_num > b_num then
            return true
        else
            return tonumber(a:GetId()) < tonumber(b:GetId())
        end
    end)

    local currUsedId = nil
    if self.tab == self.AvatarType.Logo then
        currUsedId = self:GetCurrBadgeId()
    elseif self.tab == self.AvatarType.Frame then
        currUsedId = self:GetCurrFrameId()
    end

    local boughtIdx = 1
    local currUsedIdx = 1
    for idx, itemModel in ipairs(self.currItemModels) do
        itemModel:SetIdx(tonumber(idx))
        if self.boughtItemId == itemModel:GetId() then
            boughtIdx = tonumber(idx)
        end
        if tostring(currUsedId) == tostring(itemModel:GetId()) then
            currUsedIdx = tonumber(idx)
        end
    end

    -- 设置选中
    if table.nums(self.currItemModels) > 0 then
        local currIdx = self:GetSelectedIdx()
        if currIdx ~= nil then
            self:SetSelectedIdx(currIdx) -- 之前选中的
        else
            self:SetSelectedIdx(currUsedIdx) -- 默认选中装配的
        end
    else
        self:SetSelectedIdx(nil) -- 列表为空选中为空
    end

    if self.boughtItemId ~= nil then -- 购买后刷新列表，idx变化，通过设置id控制选中
        self:SetSelectedIdx(boughtIdx)
        self:SetBoughtId(nil)
    end

    return self.currItemModels
end

-- 获得当前选中的道具的索引
function GreenswardAvatarSelectModel:GetSelectedIdx()
    return self.selectedIdx[self.tab]
end

function GreenswardAvatarSelectModel:SetSelectedIdx(idx)
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

function GreenswardAvatarSelectModel:SetBoughtId(itemId)
    self.boughtItemId = itemId
end

-- 获得当前选中的物品的model
-- @return [GreenswardItemModel]
function GreenswardAvatarSelectModel:GetSelectedItemModel()
    local itemModel = nil
    local currIdx = self:GetSelectedIdx()
    if currIdx ~= nil then
        itemModel = self.currItemModels[currIdx]
    end
    return itemModel
end

-- 获得当前选中的页签
function GreenswardAvatarSelectModel:GetCurrTab()
    return self.tab
end

-- 设置选中页签
function GreenswardAvatarSelectModel:SetCurrTab(tab)
    self.tab = tostring(tab)
end

-- 判断所使用的货币是否充足
function GreenswardAvatarSelectModel:IsCostEnough(cType, cost)
    if not self.playerInfoModel then
        self.playerInfoModel = PlayerInfoModel.new()
    end
    return self.playerInfoModel:IsCostEnough(cType, cost)
end

-- 获得该商品再AdventureStore中配置的商品的model
function GreenswardAvatarSelectModel:GetAccessStoreItemModel(itemModel)
    local storeItemModel = nil
    local storeItemId = itemModel:GetAccessId()
    local itemType = itemModel:GetItemType()
    if storeItemId ~= nil and itemType ~= nil and storeItemId > 0 then
        local storeType = nil
        if itemType == GreenswardItemType.Logo then
            storeType = GreenswardStoreType.Logo
        elseif itemType == GreenswardItemType.Frame then
            storeType = GreenswardStoreType.Frame
        else
            return storeItemModel
        end
        storeItemModel = GreenswardStoreItemModel.new(tostring(storeItemId), tostring(storeType))
    end
    return storeItemModel
end

-- 购买后更新
function GreenswardAvatarSelectModel:UpdateAfterPurchased(data, storeItemModel, itemModel)
    local cost = data.cost
    local buyRecord = data.buyRecord or {}
    local contents = data.contents or {}
    if not self.playerInfoModel then
        self.playerInfoModel = PlayerInfoModel.new()
    end
    self.playerInfoModel:CostDetail(cost)
    self.itemMapModel:UpdateItemsFromRewards(contents)

    local itemId = itemModel:GetId()
    itemModel:SetOwnNum(self.itemMapModel:GetItemNum(itemId))
    self:SetBoughtId(tostring(itemId))
end

-- 更换形象
function GreenswardAvatarSelectModel:UpdateAfterSwitch(data)
    local ret = data.ret or {}
    local base = data.base or {}
    self.buildModel:SetCurrBadgeId(ret.badge)
    self.buildModel:SetCurrFrameId(ret.frame)
    if not table.isEmpty(base) then
        self.buildModel:RefreshBaseInfo(base)
    end
end

return GreenswardAvatarSelectModel

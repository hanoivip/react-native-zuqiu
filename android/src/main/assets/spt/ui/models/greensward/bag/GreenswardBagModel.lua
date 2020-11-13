local GreenswardItemMapModel = require("ui.models.greensward.item.GreenswardItemMapModel")
local GreenswardItemType = require("ui.models.greensward.item.configType.GreenswardItemType")
local Model = require("ui.models.Model")

local GreenswardBagModel = class(Model, "GreenswardBagModel")

function GreenswardBagModel:ctor()
    self.itemMapModel = GreenswardItemMapModel.new()
    self.itemModels = {} -- 所有物品的model
    self.currItemModels = {} -- 当前页面下的物品的model

    self.tab = tostring(GreenswardItemType.Comsumables) -- 默认tab为消耗道具

    self.selectedIdx = {}

    GreenswardBagModel.super.ctor(self)
end

function GreenswardBagModel:Init()
    GreenswardBagModel.super.Init(self)
    self.itemModels = self.itemMapModel:GetItemModels()
end

function GreenswardBagModel:SetGreenswardBuildModel(greenswardBuildModel)
    self.buildModel = greenswardBuildModel
end

function GreenswardBagModel:GetGreenswardBuildModel()
    return self.buildModel
end

-- 获得当前页签下所需所有道具的model
function GreenswardBagModel:GetCurrItemModels()
    self.currItemModels = {}
    local itemType = tonumber(self.tab)
    for k, itemModel in ipairs(self.itemModels) do
        if itemModel:GetItemType() == itemType then
            table.insert(self.currItemModels, itemModel)
        end
    end

    table.sort(self.currItemModels, function(a, b)
        local a_use = tonumber(a:GetUseType())
        local b_use = tonumber(b:GetUseType())
        if a_use < b_use then
            return true
        elseif a_use > b_use then
            return false
        else
            local a_id = a:GetId()
            local b_id = b:GetId()
            return tonumber(a:GetId()) < tonumber(b:GetId())
        end
    end)

    for k, itemModel in ipairs(self.currItemModels) do
        itemModel:SetSelected(false)
        itemModel:SetIdx(tonumber(k))
    end

    if #self.currItemModels > 0 then
        self:SetSelectedIdx(self:GetSelectedIdx() or 1)
    else
        self:SetSelectedIdx(nil)
    end

    return self.currItemModels
end

-- 获得当前选中的道具的索引
function GreenswardBagModel:GetSelectedIdx()
    return self.selectedIdx[self.tab]
end

function GreenswardBagModel:SetSelectedIdx(idx)
    local oldIdx = self:GetSelectedIdx()
    local itemNum = #self.currItemModels
    if itemNum <= 0 then idx = nil end
    if oldIdx and oldIdx <= itemNum then
        self.currItemModels[oldIdx]:SetSelected(false)
    end
    self.selectedIdx[self.tab] = idx
    local newSelectedIdx = self:GetSelectedIdx()
    if newSelectedIdx and newSelectedIdx <= itemNum then
        self.currItemModels[newSelectedIdx]:SetSelected(true)
    end
end

-- 获得当前选中的道具的model
function GreenswardBagModel:GetSelectedItemModel()
    local itemModel = nil
    local selectedIdx = self:GetSelectedIdx()
    if selectedIdx then
        itemModel = self.currItemModels[selectedIdx]
    end
    return itemModel
end

-- 获得当前选中的页签
function GreenswardBagModel:GetCurrTab()
    return self.tab
end

-- 设置选中页签
function GreenswardBagModel:SetCurrTab(tab)
    self.tab = tostring(tab)
end

-- 获得当前层数
function GreenswardBagModel:GetCurrFloor()
    return self.buildModel:GetCurrentFloor()
end

-- 使用道具后更新
function GreenswardBagModel:UpdateAfterItemUsed()
    self.itemMapModel:Init()
    self.itemModels = self.itemMapModel:GetItemModels()
end

-- 获得道具后更新
function GreenswardBagModel:UpdateAfterItemReward()
    self.itemMapModel:Init()
    self.itemModels = self.itemMapModel:GetItemModels()
end

-- 使用后不删除的道具是否失去使用功能
function GreenswardBagModel:IsItemUsed(itemModel)
    return self.itemMapModel:IsItemUsed(itemModel, self.buildModel)
end

return GreenswardBagModel

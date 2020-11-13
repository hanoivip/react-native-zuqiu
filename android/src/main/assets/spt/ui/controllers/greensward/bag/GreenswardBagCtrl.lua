local BaseCtrl = require("ui.controllers.BaseCtrl")
local MenuType = require("ui.controllers.itemList.MenuType")
local GreenswardItemActionMainCtrl = require("ui.controllers.greensward.item.itemAction.GreenswardItemActionMainCtrl")
local GreenswardBagModel = require("ui.models.greensward.bag.GreenswardBagModel")

local GreenswardBagCtrl = class(BaseCtrl, "GreenswardBagCtrl")

GreenswardBagCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/Bag/GreenswardBag.prefab"

GreenswardBagCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function GreenswardBagCtrl:ctor()
    GreenswardBagCtrl.super.ctor(self)
end

function GreenswardBagCtrl:Init(greenswardBuildModel)
    GreenswardBagCtrl.super.Init(self)

    self.model = GreenswardBagModel.new()
    self.model:SetGreenswardBuildModel(greenswardBuildModel)

    self.view.onTabClick = function(itemType) self:OnTabClick(itemType) end
    self.view.onItemClick = function(itemModel) self:OnItemClick(itemModel) end
    self.view.onUseItemClick = function(itemModel) self:OnUseItemClick(itemModel) end
    self.view.onItemUsed = function() self:OnItemUsed() end
    self.view.onItemReward = function() self:OnItemReward() end
    self.view:InitView(self.model)
end

function GreenswardBagCtrl:Refresh(greenswardBuildModel)
    GreenswardBagCtrl.super.Refresh(self)

    self.view:RefreshView()
end

function GreenswardBagCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function GreenswardBagCtrl:OnExitScene()
    self.view:OnExitScene()
end

-- 页签点击事件
function GreenswardBagCtrl:OnTabClick(itemType)
    self.model:SetCurrTab(itemType)
    self.view:RefreshScrollView()
    self.view:RefreshDetailView()
end

-- 道具点击事件
function GreenswardBagCtrl:OnItemClick(itemModel)
    local oldItemModel = self.model:GetSelectedItemModel()
    local oldIdx = oldItemModel:GetIdx()
    local newIdx = itemModel:GetIdx()
    if oldIdx == newIdx then return end

    self.model:SetSelectedIdx(newIdx)
    if oldItemModel then
        oldItemModel:SetSelected(false)
        self.view:UpdateItemView(oldIdx, oldItemModel)
    end
    if itemModel then
        itemModel:SetSelected(true)
        self.view:UpdateItemView(newIdx, itemModel)
    end
    self.view:RefreshDetailView()
end

-- 使用道具
function GreenswardBagCtrl:OnUseItemClick(itemModel)
    local usage = itemModel:GetUsage()
    if tonumber(usage) == 1 then
        res.PushDialog("ui.controllers.itemList.GiftBoxDetailCtrl", itemModel, false, false)
    else
        local actionMainCtrl = GreenswardItemActionMainCtrl.new(itemModel, self.model:GetGreenswardBuildModel())
        actionMainCtrl:DoAction()
    end
end

-- 使用道具后
function GreenswardBagCtrl:OnItemUsed()
    self.model:UpdateAfterItemUsed()
end

--获得道具后
function GreenswardBagCtrl:OnItemReward()
    self.model:UpdateAfterItemReward()
end

return GreenswardBagCtrl

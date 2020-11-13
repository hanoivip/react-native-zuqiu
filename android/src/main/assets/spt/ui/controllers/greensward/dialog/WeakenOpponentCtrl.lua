local BaseCtrl = require("ui.controllers.BaseCtrl")
local WeakenOpponentModel = require("ui.models.greensward.event.WeakenOpponentModel")
local GreenswardItemActionMainCtrl = require("ui.controllers.greensward.item.itemAction.GreenswardItemActionMainCtrl")

local WeakenOpponentCtrl = class(BaseCtrl, "WeakenOpponentCtrl")

WeakenOpponentCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/WeakenOpponent.prefab"

WeakenOpponentCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function WeakenOpponentCtrl:ctor(eventModel)
    WeakenOpponentCtrl.super.ctor(self)
end

function WeakenOpponentCtrl:Init(eventModel)
    if not self.model then
        self.model = WeakenOpponentModel.new()
    end
    self.model:InitWithParent(eventModel)

    self.view.onBtnUse = function() self:OnBtnUse() end
    self.view.onItemClick = function(itemModel) self:OnItemClick(itemModel) end
    self.view:InitView(self.model)
end

function WeakenOpponentCtrl:Refresh(eventModel)
    WeakenOpponentCtrl.super.Refresh(self)
    self.view:RefreshView()
end

-- 点击确定
function WeakenOpponentCtrl:OnBtnUse()
    local eventModel = self.model:GetEventModel()
    local itemModel = self.model:GetSelectedItemModel()
    if itemModel ~= nil then
        local actionMainCtrl = GreenswardItemActionMainCtrl.new(itemModel, eventModel:GetBuildModel(), eventModel)
        actionMainCtrl:DoAction()
    end
end

-- 点击物品
function WeakenOpponentCtrl:OnItemClick(itemModel)
    local oldItemModel = self.model:GetSelectedItemModel()
    local oldIdx = nil
    if oldItemModel then
        oldIdx = oldItemModel:GetIdx()
    end
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
    self.view:RefreshButtonState()
end

return WeakenOpponentCtrl

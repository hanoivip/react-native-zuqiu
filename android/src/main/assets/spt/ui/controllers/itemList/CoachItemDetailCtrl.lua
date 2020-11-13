local BaseCtrl = require("ui.controllers.BaseCtrl")
local EquipsMapModel = require("ui.models.EquipsMapModel")
local EquipPieceMapModel = require("ui.models.EquipPieceMapModel")
local MenuType = require("ui.controllers.itemList.MenuType")
local UISoundManager = require("ui.control.manager.UISoundManager")

local CoachItemDetailCtrl = class(BaseCtrl)
CoachItemDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/ItemList/Coach/CoachItemDetail.prefab"
CoachItemDetailCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function CoachItemDetailCtrl:Init(model)
    self.model = model
end

function CoachItemDetailCtrl:Refresh()
    CoachItemDetailCtrl.super.Refresh(self)
    self:InitView()
end

function CoachItemDetailCtrl:GetStatusData()
    return self.model
end

function CoachItemDetailCtrl:OnEnterScene()
    self.view:EnterScene()
end

function CoachItemDetailCtrl:OnExitScene()
    self.view:ExitScene()
end

function CoachItemDetailCtrl:InitView()
    self.view:InitView(self.model)
end

return CoachItemDetailCtrl

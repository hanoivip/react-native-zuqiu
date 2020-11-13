 local BaseCtrl = require("ui.controllers.BaseCtrl")
local PlayerPieceDetailCtrl = class(BaseCtrl)
PlayerPieceDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/PlayerPiece/PlayerPieceDetail.prefab"
PlayerPieceDetailCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function PlayerPieceDetailCtrl:Init(model)
    self.model = model
end

function PlayerPieceDetailCtrl:Refresh()
    PlayerPieceDetailCtrl.super.Refresh(self)
    self.view:InitView(self.model)
end

function PlayerPieceDetailCtrl:GetStatusData()
    return self.model
end

function PlayerPieceDetailCtrl:OnEnterScene()
    self.view:EnterScene()
end

function PlayerPieceDetailCtrl:OnExitScene()
    self.view:ExitScene()
end

return PlayerPieceDetailCtrl


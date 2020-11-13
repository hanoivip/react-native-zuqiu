local BaseCtrl = require("ui.controllers.BaseCtrl")
local FancyPieceDetailCtrl = class(BaseCtrl)
FancyPieceDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Fancy/FancyStore/FancyPieceDetail.prefab"

function FancyPieceDetailCtrl:Init(model)
    self.model = model
end

function FancyPieceDetailCtrl:Refresh()
    FancyPieceDetailCtrl.super.Refresh(self)
    self.view:InitView(self.model)
end

function FancyPieceDetailCtrl:GetStatusData()
    return self.model
end

function FancyPieceDetailCtrl:OnEnterScene()
    self.view:EnterScene()
end

function FancyPieceDetailCtrl:OnExitScene()
    self.view:ExitScene()
end

return FancyPieceDetailCtrl


local BaseCtrl = require("ui.controllers.BaseCtrl")
local MarblesItemDetailCtrl = class(BaseCtrl)

MarblesItemDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Marbles/MarblesItemDetail.prefab"

MarblesItemDetailCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function MarblesItemDetailCtrl:Init(model)
    self.model = model
end

function MarblesItemDetailCtrl:Refresh()
    MarblesItemDetailCtrl.super.Refresh(self)
    self.view:InitView(self.model)
end

function MarblesItemDetailCtrl:GetStatusData()
    return self.model
end

function MarblesItemDetailCtrl:OnEnterScene()
    self.view:EnterScene()
end

function MarblesItemDetailCtrl:OnExitScene()
    self.view:ExitScene()
end

return MarblesItemDetailCtrl


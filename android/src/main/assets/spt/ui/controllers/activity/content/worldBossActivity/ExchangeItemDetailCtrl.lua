local BaseCtrl = require("ui.controllers.BaseCtrl")
local ExchangeItemDetailCtrl = class(BaseCtrl)

ExchangeItemDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/WorldBossActivity/ExchangeItemDetail.prefab"

ExchangeItemDetailCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function ExchangeItemDetailCtrl:Init(model)
    self.model = model
end

function ExchangeItemDetailCtrl:Refresh()
    ExchangeItemDetailCtrl.super.Refresh(self)
    self.view:InitView(self.model)
end

function ExchangeItemDetailCtrl:GetStatusData()
    return self.model
end

function ExchangeItemDetailCtrl:OnEnterScene()
    self.view:EnterScene()
end

function ExchangeItemDetailCtrl:OnExitScene()
    self.view:ExitScene()
end

return ExchangeItemDetailCtrl


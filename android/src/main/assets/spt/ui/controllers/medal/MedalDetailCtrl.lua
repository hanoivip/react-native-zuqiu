local BaseCtrl = require("ui.controllers.BaseCtrl")
local MedalDetailCtrl = class(BaseCtrl)
MedalDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Medal/Prefab/MedalDetail.prefab"
MedalDetailCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function MedalDetailCtrl:Init(medalModel)
end

function MedalDetailCtrl:Refresh(medalModel)
    MedalDetailCtrl.super.Refresh(self)
    self.view:InitView(medalModel)
end

return MedalDetailCtrl


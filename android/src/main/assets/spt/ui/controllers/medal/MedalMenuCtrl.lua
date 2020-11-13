local BaseCtrl = require("ui.controllers.BaseCtrl")
local MedalMenuCtrl = class(BaseCtrl)
MedalMenuCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Medal/Prefab/BenedictionMenu.prefab"
MedalMenuCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function MedalMenuCtrl:Init()
end

function MedalMenuCtrl:Refresh()
    MedalMenuCtrl.super.Refresh(self)
    self.view:InitView()
end

return MedalMenuCtrl


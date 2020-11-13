local BaseCtrl = require("ui.controllers.BaseCtrl")

local VIPTipCtrl = class(BaseCtrl, "VIPTipCtrl")

VIPTipCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Charge/VIPTip.prefab"

VIPTipCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function VIPTipCtrl:Init(vipLevel, chargeView)
    self.view:InitView(vipLevel, chargeView)
    luaevt.trig("SDK_Report", "vip_levelup", vipLevel)
end

return VIPTipCtrl
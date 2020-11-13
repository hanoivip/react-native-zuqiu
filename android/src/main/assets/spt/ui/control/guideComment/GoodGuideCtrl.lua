local BaseCtrl = require("ui.controllers.BaseCtrl")
local GoodGuideCtrl = class(BaseCtrl, "GoodGuideCtrl")

GoodGuideCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Common/GuideComment/GuideComment.prefab"

GoodGuideCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function GoodGuideCtrl:Refresh(isStore)
    GoodGuideCtrl.super.Refresh(self)
    self.view:InitView(isStore)
end

return GoodGuideCtrl
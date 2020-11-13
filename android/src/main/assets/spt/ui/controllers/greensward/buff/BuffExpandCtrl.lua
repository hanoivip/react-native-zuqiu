local BaseCtrl = require("ui.controllers.BaseCtrl")
local BuffExpandCtrl = class(BaseCtrl, "BuffExpandCtrl")

BuffExpandCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Buff/BuffExpand.prefab"

BuffExpandCtrl.dialogStatus = {
    touchClose = true,
    withShadow = false,
    unblockRaycast = false,
}

function BuffExpandCtrl:Init(greenswardBuildModel, greenswardResourceCache)
    self.view:InitView(greenswardBuildModel, greenswardResourceCache)
end

return BuffExpandCtrl

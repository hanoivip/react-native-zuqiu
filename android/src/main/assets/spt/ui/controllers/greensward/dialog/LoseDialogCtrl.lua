local BaseCtrl = require("ui.controllers.BaseCtrl")
local LoseDialogCtrl = class(BaseCtrl, "LoseDialogCtrl")

LoseDialogCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/LoseGuide.prefab"

LoseDialogCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

return LoseDialogCtrl
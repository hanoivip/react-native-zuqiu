local BaseCtrl = require("ui.controllers.BaseCtrl")
local LevelUpNoticeCtrl = class(BaseCtrl)

LevelUpNoticeCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}
LevelUpNoticeCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Court/Prefab/LevelNotice.prefab"
function LevelUpNoticeCtrl:Init()
end

function LevelUpNoticeCtrl:Refresh(courtBuildModel, courtBuildType, lvl)
    self.view:InitView(courtBuildModel, courtBuildType, lvl)
end

return LevelUpNoticeCtrl

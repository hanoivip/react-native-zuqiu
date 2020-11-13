local BaseCtrl = require("ui.controllers.BaseCtrl")
local MedalBreakThroughBoardCtrl = class(BaseCtrl)
MedalBreakThroughBoardCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Medal/Prefab/MedalBreakThroughBoard.prefab"
MedalBreakThroughBoardCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function MedalBreakThroughBoardCtrl:Init()

end

function MedalBreakThroughBoardCtrl:Refresh(currMedalSingleModel, oldMedalSingleModel)
    MedalBreakThroughBoardCtrl.super.Refresh(self)
    self.view:InitView(currMedalSingleModel, oldMedalSingleModel)
end

return MedalBreakThroughBoardCtrl

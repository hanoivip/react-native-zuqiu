local BaseCtrl = require("ui.controllers.BaseCtrl")

local CoachBaseInfoSuccessCtrl = class(BaseCtrl, "CoachBaseInfoSuccessCtrl")

CoachBaseInfoSuccessCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/BaseInfo/CoachBaseInfoSuccessBoard.prefab"

CoachBaseInfoSuccessCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function CoachBaseInfoSuccessCtrl:ctor()
    CoachBaseInfoSuccessCtrl.super.ctor(self)
end

function CoachBaseInfoSuccessCtrl:Init(coachBaseInfoModel)
end

function CoachBaseInfoSuccessCtrl:Refresh(coachBaseInfoModel)
    CoachBaseInfoSuccessCtrl.super.Refresh(self)
    self.model = coachBaseInfoModel
    self.view:InitView(self.model)
end

return CoachBaseInfoSuccessCtrl
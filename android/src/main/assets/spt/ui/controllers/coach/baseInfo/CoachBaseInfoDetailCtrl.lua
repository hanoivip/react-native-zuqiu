local BaseCtrl = require("ui.controllers.BaseCtrl")

local CoachBaseInfoDetailCtrl = class(BaseCtrl, "CoachBaseInfoDetailCtrl")

CoachBaseInfoDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/BaseInfo/CoachBaseInfoDetail.prefab"

CoachBaseInfoDetailCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function CoachBaseInfoDetailCtrl:ctor()
    CoachBaseInfoDetailCtrl.super.ctor(self)
end

function CoachBaseInfoDetailCtrl:Init(coachBaseInfoModel)
end

function CoachBaseInfoDetailCtrl:Refresh(coachBaseInfoModel)
    CoachBaseInfoDetailCtrl.super.Refresh(self)
    self.model = coachBaseInfoModel
    self.view:InitView(self.model)
end

return CoachBaseInfoDetailCtrl
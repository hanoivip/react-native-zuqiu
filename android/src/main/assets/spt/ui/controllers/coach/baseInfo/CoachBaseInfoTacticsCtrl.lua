local BaseCtrl = require("ui.controllers.BaseCtrl")

local CoachBaseInfoTacticsCtrl = class(BaseCtrl, "CoachBaseInfoTacticsCtrl")

CoachBaseInfoTacticsCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/BaseInfo/CoachBaseInfoTactics.prefab"

CoachBaseInfoTacticsCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function CoachBaseInfoTacticsCtrl:ctor()
    CoachBaseInfoTacticsCtrl.super.ctor(self)
end

function CoachBaseInfoTacticsCtrl:Init()
end

function CoachBaseInfoTacticsCtrl:Refresh(coachBaseInfoTacticsModel)
    CoachBaseInfoTacticsCtrl.super.Refresh(self)
    if not coachBaseInfoTacticsModel then
        local CoachBaseInfoTacticsModel = require("ui.models.coach.baseInfo.CoachBaseInfoTacticsModel")
        self.model = CoachBaseInfoTacticsModel.new()
    else
        self.model = coachBaseInfoTacticsModel
    end
    self.view:InitView(self.model)
end

return CoachBaseInfoTacticsCtrl
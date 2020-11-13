local BaseCtrl = require("ui.controllers.BaseCtrl")

local AssistCoachInformationItemDetailCtrl = class(BaseCtrl, "AssistCoachInformationItemDetailCtrl")

AssistCoachInformationItemDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/AssistCoachInformation/AssistCoachInformationItemDetail.prefab"

AssistCoachInformationItemDetailCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function AssistCoachInformationItemDetailCtrl:ctor()
    AssistCoachInformationItemDetailCtrl.super.ctor(self)
end

function AssistCoachInformationItemDetailCtrl:Init(aciModel)
    AssistCoachInformationItemDetailCtrl.super.Init(self)
end

function AssistCoachInformationItemDetailCtrl:Refresh(aciModel)
    AssistCoachInformationItemDetailCtrl.super.Refresh(self)
    if aciModel then
        self.aciModel = aciModel
        self.view:InitView(self.aciModel)
    end
end

function AssistCoachInformationItemDetailCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function AssistCoachInformationItemDetailCtrl:OnExitScene()
    self.view:OnExitScene()
end

return AssistCoachInformationItemDetailCtrl

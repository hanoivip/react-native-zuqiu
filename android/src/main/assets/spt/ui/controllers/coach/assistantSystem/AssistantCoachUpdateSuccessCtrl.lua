local BaseCtrl = require("ui.controllers.BaseCtrl")

local AssistantCoachUpdateSuccessCtrl = class(BaseCtrl, "AssistantCoachUpdateSuccessCtrl")

AssistantCoachUpdateSuccessCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/AssistantSystem/Prefabs/AssistantCoachUpdateSuccess.prefab"

AssistantCoachUpdateSuccessCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function AssistantCoachUpdateSuccessCtrl:ctor()
    AssistantCoachUpdateSuccessCtrl.super.ctor(self)
end

function AssistantCoachUpdateSuccessCtrl:Init(assistantCoachModel)
    AssistantCoachUpdateSuccessCtrl.super.Init(self)
    self.view.onBtnConfirmClick = function() self:OnBtnConfirmClick() end
end

function AssistantCoachUpdateSuccessCtrl:Refresh(assistantCoachModel)
    AssistantCoachUpdateSuccessCtrl.super.Refresh(self)
    if assistantCoachModel then
        self.acModel = assistantCoachModel
        self.view:InitView(self.acModel)
    end
end

function AssistantCoachUpdateSuccessCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function AssistantCoachUpdateSuccessCtrl:OnExitScene()
    self.view:OnExitScene()
end

function AssistantCoachUpdateSuccessCtrl:OnBtnConfirmClick()
    self.view:Close()
end

return AssistantCoachUpdateSuccessCtrl

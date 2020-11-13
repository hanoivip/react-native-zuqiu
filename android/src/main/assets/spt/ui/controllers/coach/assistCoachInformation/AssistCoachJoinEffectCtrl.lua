local AssistantCoachModel = require("ui.models.coach.assistantSystem.AssistantCoachModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")

local AssistCoachJoinEffectCtrl = class(BaseCtrl, "AssistCoachJoinEffectCtrl")

AssistCoachJoinEffectCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/AssistCoachInformation/AssistCoachJoinEffect.prefab"

AssistCoachJoinEffectCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function AssistCoachJoinEffectCtrl:ctor()
    AssistCoachJoinEffectCtrl.super.ctor(self)
end

function AssistCoachJoinEffectCtrl:Init(assistCoachJoinEffectModel)
    AssistCoachJoinEffectCtrl.super.Init(self)
    if assistCoachJoinEffectModel then
        self.model = assistCoachJoinEffectModel
        self.view.onCloseDialog = function() self:OnCloseDialog() end
        self.view:InitView(self.model)
    end
end

function AssistCoachJoinEffectCtrl:Refresh(assistCoachJoinEffectModel)
    AssistCoachJoinEffectCtrl.super.Refresh(self)
    if self.model then
        self.view:RefreshView()
    end
end

function AssistCoachJoinEffectCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function AssistCoachJoinEffectCtrl:OnExitScene()
    self.view:OnExitScene()
end

function AssistCoachJoinEffectCtrl:OnCloseDialog()
    local acModel = self.model:GetNewAssistantCoachModel()
    res.PushDialog("ui.controllers.coach.assistCoachInformation.AssistCoachJoinCtrl", acModel)
end

return AssistCoachJoinEffectCtrl

local BaseCtrl = require("ui.controllers.BaseCtrl")

local AssistCoachJoinCtrl = class(BaseCtrl, "AssistCoachJoinCtrl")

AssistCoachJoinCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/AssistCoachInformation/AssistCoachJoin.prefab"

AssistCoachJoinCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function AssistCoachJoinCtrl:ctor()
    AssistCoachJoinCtrl.super.ctor(self)
end

function AssistCoachJoinCtrl:Init(acModel)
    AssistCoachJoinCtrl.super.Init(self)
end

function AssistCoachJoinCtrl:Refresh(acModel)
    AssistCoachJoinCtrl.super.Refresh(self)
    if acModel then
        self.acModel = acModel
        self.view:InitView(self.acModel)
    end
end

function AssistCoachJoinCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function AssistCoachJoinCtrl:OnExitScene()
    self.view:OnExitScene()
end

return AssistCoachJoinCtrl

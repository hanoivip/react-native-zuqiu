local AssistantCoachSystemCtrl = require("ui.controllers.coach.assistantSystem.AssistantCoachSystemCtrl")
local OtherAssistantCoachSystemModel = require("ui.models.coach.otherPlayer.OtherAssistantCoachSystemModel")

local OtherAssistantCoachSystemCtrl = class(AssistantCoachSystemCtrl, "OtherAssistantCoachSystemCtrl")

OtherAssistantCoachSystemCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/OtherPlayer/OtherAssistantCoachSystem.prefab"

function OtherAssistantCoachSystemCtrl:AheadRequest(mainCoachData, currTeamIndex)
end

function OtherAssistantCoachSystemCtrl:ctor()
    OtherAssistantCoachSystemCtrl.super.ctor(self)
end

function OtherAssistantCoachSystemCtrl:Init(assistantCoach)
    self.view.onMenuClick = function(index, data) self:OnMenuClick(index, data) end
    self.view.onBtnBackClick = function() self:OnBtnBackClick() end
end

function OtherAssistantCoachSystemCtrl:Refresh(assistantCoach)
    if not self.model then
        self.model = OtherAssistantCoachSystemModel.new()
    end
    self.model:InitWithProtocol(assistantCoach)
    self.view:InitView(self.model)
    self.view:ShowDisplayArea(true)
    self.view:RefreshView()
end

-- 点击返回按钮
function OtherAssistantCoachSystemCtrl:OnBtnBackClick()
    res.PopScene()
end

return OtherAssistantCoachSystemCtrl

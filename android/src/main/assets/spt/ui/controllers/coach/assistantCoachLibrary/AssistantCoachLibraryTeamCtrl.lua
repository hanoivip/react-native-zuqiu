local BaseCtrl = require("ui.controllers.BaseCtrl")

local AssistantCoachLibraryTeamCtrl = class(BaseCtrl, "AssistantCoachLibraryTeamCtrl")

AssistantCoachLibraryTeamCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/AssistantCoachLibrary/AssistantCoachLibraryTeam.prefab"

AssistantCoachLibraryTeamCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function AssistantCoachLibraryTeamCtrl:ctor()
    AssistantCoachLibraryTeamCtrl.super.ctor(self)
end

function AssistantCoachLibraryTeamCtrl:Init(assistantCoachLibraryModel)
    AssistantCoachLibraryTeamCtrl.super.Init(self)

    self.view.onToggleClick = function(label, isOn) self:OnToggleClick(label, isOn) end
    self.view.onBtnConfirmClick = function() self:OnBtnConfirmClick() end
end

function AssistantCoachLibraryTeamCtrl:Refresh(assistantCoachLibraryModel)
    AssistantCoachLibraryTeamCtrl.super.Refresh(self)
    if assistantCoachLibraryModel then
        self.aclModel = assistantCoachLibraryModel
        self.view:InitView(self.aclModel)
    end
end

function AssistantCoachLibraryTeamCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function AssistantCoachLibraryTeamCtrl:OnExitScene()
    self.view:OnExitScene()
end

function AssistantCoachLibraryTeamCtrl:OnToggleClick(label, isOn)
    if isOn then
        self.choosedTeamIdx = label
    else
        self.choosedTeamIdx = nil
    end
end

function AssistantCoachLibraryTeamCtrl:OnBtnConfirmClick()
    if self.choosedTeamIdx ~= nil then
        self.aclModel:SetChoosedTeamIdx(self.choosedTeamIdx)
        self.view:SendConfirmEvent()
    end
end

return AssistantCoachLibraryTeamCtrl

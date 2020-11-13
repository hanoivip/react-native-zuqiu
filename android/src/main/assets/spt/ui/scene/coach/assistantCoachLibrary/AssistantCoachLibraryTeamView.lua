local UnityEngine = clr.UnityEngine
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local AssistantCoachLibraryTeamView = class(unity.base, "AssistantCoachLibraryTeamView")

local TogglePath = "Assets/CapstonesRes/Game/UI/Scene/Coach/AssistantCoachLibrary/AssistantCoachLibraryTeamToggle.prefab"

function AssistantCoachLibraryTeamView:ctor()
    self.canvasGroup = self.___ex.canvasGroup
    -- 确认按钮
    self.btnConfirm = self.___ex.btnConfirm
    -- 单选组
    self.toggleGroup = self.___ex.toggleGroup
    self.rctToggleGroup = self.___ex.rctToggleGroup
end

function AssistantCoachLibraryTeamView:start()
    self:RegBtnEvent()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function AssistantCoachLibraryTeamView:InitView(assistantCoachLibraryModel)
    self.aclModel = assistantCoachLibraryModel

    res.ClearChildren(self.rctToggleGroup)
    local maxTeams = self.aclModel:GetMaxTeams()
    for i = 1, maxTeams do
        local obj, spt = res.Instantiate(TogglePath)
        if obj ~= nil and spt ~= nil then
            obj.transform:SetParent(self.rctToggleGroup.transform, false)
            spt:InitView(i, self.toggleGroup)
        end
    end
end

function AssistantCoachLibraryTeamView:RegBtnEvent()
    self.btnConfirm:regOnButtonClick(function()
        self:OnBtnConfirmClick()
    end)
end

function AssistantCoachLibraryTeamView:Close()
    local callback = function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

function AssistantCoachLibraryTeamView:OnEnterScene()
    EventSystem.AddEvent("AssistantCoachLibrary_OnClickToggle", self, self.OnToggleClick)
end

function AssistantCoachLibraryTeamView:OnExitScene()
    EventSystem.RemoveEvent("AssistantCoachLibrary_OnClickToggle", self, self.OnToggleClick)
end

function AssistantCoachLibraryTeamView:OnToggleClick(label, isOn)
    if self.onToggleClick and type(self.onToggleClick) == "function" then
        self.onToggleClick(label, isOn)
    end
end

function AssistantCoachLibraryTeamView:OnBtnConfirmClick()
    if self.onBtnConfirmClick and type(self.onBtnConfirmClick) == "function" then
        self.onBtnConfirmClick()
        self:Close()
    end
end

function AssistantCoachLibraryTeamView:SendConfirmEvent()
    EventSystem.SendEvent("AssistantCoachLibraryTeam_OnConfirmTeam")
end

return AssistantCoachLibraryTeamView

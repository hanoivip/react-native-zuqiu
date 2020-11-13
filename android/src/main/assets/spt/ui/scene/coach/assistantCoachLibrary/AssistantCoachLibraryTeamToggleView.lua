local UnityEngine = clr.UnityEngine
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local LuaButton = require("ui.control.button.LuaButton")

local AssistantCoachLibraryTeamToggleView = class(LuaButton, "AssistantCoachLibraryTeamToggleView")

function AssistantCoachLibraryTeamToggleView:ctor()
    AssistantCoachLibraryTeamToggleView.super.ctor(self)
    self.toggle = self.___ex.toggle
    self.txtLabel = self.___ex.txtLabel
end

function AssistantCoachLibraryTeamToggleView:start()
    self:regOnButtonClick(function()
        EventSystem.SendEvent("AssistantCoachLibrary_OnClickToggle", self.label, self.toggle.isOn)
    end)
end

function AssistantCoachLibraryTeamToggleView:InitView(label, toggleGroup)
    self.label = label
    self.txtLabel.text = lang.trans("team_index", self.label)
    if toggleGroup then
        self.toggle.group = toggleGroup
    end
end

return AssistantCoachLibraryTeamToggleView

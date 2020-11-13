local UnityEngine = clr.UnityEngine
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local LuaButton = require("ui.control.button.LuaButton")

local CompeteGuessConfirmToggleView = class(LuaButton, "CompeteGuessConfirmToggleView")

function CompeteGuessConfirmToggleView:ctor()
    CompeteGuessConfirmToggleView.super.ctor(self)
    self.toggle = self.___ex.toggle
    self.label = self.___ex.label
end

function CompeteGuessConfirmToggleView:start()
    self:regOnButtonClick(function()
        EventSystem.SendEvent("CompeteGuess_Confirm", self.label)
    end)
end

return CompeteGuessConfirmToggleView

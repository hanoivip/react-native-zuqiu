local GreenswardEventModel = require("ui.models.greensward.event.GreenswardEventModel")
local DetectingEventModel2 = class(GreenswardEventModel, "DetectingEventModel2")

function DetectingEventModel2:ctor()
    DetectingEventModel2.super.ctor(self)
	self.ctrlPath = "ui.controllers.greensward.dialog.OpponentDialogCtrl"
end

function DetectingEventModel2:TriggerEvent()
	EventSystem.SendEvent("GreenswardOpponentEventTrigger", self)
end

function DetectingEventModel2:HasEvent()
    return true
end

function DetectingEventModel2:IsShowDialog()
    local st = self:GetCurrentState()
    return tobool(tonumber(st) == GreenswardEventModel.EventStatus.TrigEvent) 
end

function DetectingEventModel2:IsOperable()
    return true
end

function DetectingEventModel2:GetEventResName()
    return "OpponentEvent"
end

return DetectingEventModel2
local GreenswardEventModel = require("ui.models.greensward.event.GreenswardEventModel")
local GreenswardItemMapModel = require("ui.models.greensward.item.GreenswardItemMapModel")

local TreasureBossEventModel1 = class(GreenswardEventModel, "TreasureBossEventModel1")

function TreasureBossEventModel1:ctor()
    TreasureBossEventModel1.super.ctor(self)
    self.ctrlPath = "ui.controllers.greensward.dialog.OpponentDialogCtrl"
end

function TreasureBossEventModel1:TriggerEvent()
	EventSystem.SendEvent("GreenswardOpponentEventTrigger", self)
end

function TreasureBossEventModel1:HasEvent()
    return true
end

function TreasureBossEventModel1:GetEventResName()
    return "OpponentEvent"
end

return TreasureBossEventModel1

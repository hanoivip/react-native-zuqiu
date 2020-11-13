local GreenswardEventModel = require("ui.models.greensward.event.GreenswardEventModel")
local GreenswardItemMapModel = require("ui.models.greensward.item.GreenswardItemMapModel")

local TreasureMonsterEventModel = class(GreenswardEventModel, "TreasureMonsterEventModel")

function TreasureMonsterEventModel:ctor()
    TreasureMonsterEventModel.super.ctor(self)
    self.ctrlPath = "ui.controllers.greensward.dialog.OpponentDialogCtrl"
end

function TreasureMonsterEventModel:TriggerEvent()
	EventSystem.SendEvent("GreenswardOpponentEventTrigger", self)
end

function TreasureMonsterEventModel:HasEvent()
    return true
end

function TreasureMonsterEventModel:GetEventResName()
    return "OpponentEvent"
end

return TreasureMonsterEventModel

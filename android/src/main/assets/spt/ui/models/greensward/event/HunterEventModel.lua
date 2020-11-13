local GreenswardEventModel = require("ui.models.greensward.event.GreenswardEventModel")
local GreenswardItemMapModel = require("ui.models.greensward.item.GreenswardItemMapModel")

local HunterEventModel = class(GreenswardEventModel, "HunterEventModel")

function HunterEventModel:ctor()
    HunterEventModel.super.ctor(self)
    self.ctrlPath = "ui.controllers.greensward.dialog.OpponentDialogCtrl"
end

function HunterEventModel:TriggerEvent()
	EventSystem.SendEvent("GreenswardOpponentEventTrigger", self)
end

function HunterEventModel:HasEvent()
    return true
end

function HunterEventModel:GetEventResName()
    return "OpponentEvent"
end

function HunterEventModel:GetSignPrefabName()
    return "RewardSign"
end

function HunterEventModel:GetSignIcon()
    return "Assets/CapstonesRes/Game/UI/Common/Images/ItemIcon/TreasureMap.png"
end

return HunterEventModel

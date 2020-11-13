local GreenswardEventModel = require("ui.models.greensward.event.GreenswardEventModel")
local GreenswardItemMapModel = require("ui.models.greensward.item.GreenswardItemMapModel")

local TreasureBossEventModel2 = class(GreenswardEventModel, "TreasureBossEventModel2")

function TreasureBossEventModel2:ctor()
    TreasureBossEventModel2.super.ctor(self)
    self.ctrlPath = "ui.controllers.greensward.dialog.OpponentDialogCtrl"
end

function TreasureBossEventModel2:TriggerEvent()
	EventSystem.SendEvent("GreenswardOpponentEventTrigger", self)
end

function TreasureBossEventModel2:HasEvent()
    return true
end

function TreasureBossEventModel2:GetEventResName()
    return "OpponentEvent"
end

function TreasureBossEventModel2:HasUnlock()
    return false
end

function TreasureBossEventModel2:HasFog()
	return false
end

function TreasureBossEventModel2:GetEffectText()
	local buildModel = self:GetBuildModel()
	local moraleRound = buildModel:GetMoraleRound()
	local moraleDownCycle, moraleMonsterMoraleDown = self:GetMoraleEffectTriggerData()
	return lang.trans("morale_effect", moraleDownCycle, moraleMonsterMoraleDown, moraleRound)
end

function TreasureBossEventModel2:GetSignPrefabName()
    return "RoundSign"
end

function TreasureBossEventModel2:GetSignIcon()
    return "Assets/CapstonesRes/Game/UI/Scene/Greensward/Common/Greensward_Common_Hourglass.png"
end

return TreasureBossEventModel2

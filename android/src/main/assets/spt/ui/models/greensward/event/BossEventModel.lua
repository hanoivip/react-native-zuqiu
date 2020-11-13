local GreenswardEventModel = require("ui.models.greensward.event.GreenswardEventModel")
local BossEventModel = class(GreenswardEventModel, "BossEventModel")

function BossEventModel:ctor()
	BossEventModel.super.ctor(self)
	self.ctrlPath = "ui.controllers.greensward.dialog.OpponentDialogCtrl"
end

function BossEventModel:TriggerEvent()
	EventSystem.SendEvent("GreenswardOpponentEventTrigger", self)
end

function BossEventModel:HasEvent()
	return true
end

function BossEventModel:GetEventResName()
	return "OpponentEvent"
end

function BossEventModel:HasUnlock()
	return false
end

function BossEventModel:HasFog()
	return false
end

function BossEventModel:GetNameColorParam()
    return 255, 245, 94
end

function BossEventModel:GetNameBorderName()
	return "Name_Border2"
end

function BossEventModel:GetSignPrefabName()
	return "EnemySign1"
end

function BossEventModel:GetPicIndex()
	local currentFloor = self:GetCurrentFloor()
	local totalFloor = self:GetTotalFloor()
	if tonumber(currentFloor) == tonumber(totalFloor) then
		return nil
	end
	return self.staticData.picIndex
end

function BossEventModel:GetChallengeText()
	local currentFloor = self:GetCurrentFloor()
	local totalFloor = self:GetTotalFloor()
	if tonumber(currentFloor) == tonumber(totalFloor) then
		return lang.trans("adventure_challenge_tip3")
	else
		return lang.trans("adventure_challenge_tip2")
	end
end

return BossEventModel
local GreenswardEventModel = require("ui.models.greensward.event.GreenswardEventModel")
local ExitEventModel = class(GreenswardEventModel, "ExitEventModel")

function ExitEventModel:ctor()
    ExitEventModel.super.ctor(self)
	self.isIconKeep = true
	self.ctrlPath = "ui.controllers.greensward.dialog.PlaneDialogCtrl"
end

function ExitEventModel:TriggerEvent()
	EventSystem.SendEvent("GreenswardGeneralEventTrigger", self)
end

function ExitEventModel:IsFlyAction()
	return true
end

function ExitEventModel:IsShowPlane()
	local buildModel = self:GetBuildModel()
	local totalFloor = buildModel:GetTotalFloor()
	local currentFloor = buildModel:GetCurrentFloor()
	if currentFloor >= totalFloor then
		return false
	else
		local greenswardMatchModel = require("ui.models.greensward.build.GreenswardMatchModel").new()
		if greenswardMatchModel:GetPassContents() then -- 飞机在通关奖励点击后再出现
			return false
		end
	end
	return true
end

function ExitEventModel:HasClear()
    return false
end

function ExitEventModel:HasFog()
	return false
end

function ExitEventModel:HasEvent()
    return true
end

function ExitEventModel:GetEventResName()
    return "PlaneEvent"
end

function ExitEventModel:GetFlyAnimationRes()
	return "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Effect/EffectPlane.prefab"
end

function ExitEventModel:IsShowDialog()
	local buildModel = self:GetBuildModel()
	local totalFloor = buildModel:GetTotalFloor()
	local currentFloor = buildModel:GetCurrentFloor()
	local topFloor = buildModel:GetOpenFloor()
	if currentFloor >= totalFloor then
		local DialogManager = require("ui.control.manager.DialogManager")
		DialogManager.ShowToast(lang.trans("adventure_plane_tip"))
		return false
	elseif topFloor > currentFloor then
		local DialogManager = require("ui.control.manager.DialogManager")
		DialogManager.ShowToast(lang.trans("adventure_plane_tip2"))
		return false
	else
		return true
	end
end

function ExitEventModel:GetNextFloor()
	local buildModel = self:GetBuildModel()
	local currentFloor = buildModel:GetCurrentFloor() or 1
	local nextFloor = currentFloor + 1
	return nextFloor
end

function ExitEventModel:GetBottomBoardName()
	return "Plane_Dlog"
end

return ExitEventModel
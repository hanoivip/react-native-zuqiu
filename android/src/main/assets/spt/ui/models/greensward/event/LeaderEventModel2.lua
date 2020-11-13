local GreenswardEventModel = require("ui.models.greensward.event.GreenswardEventModel")
local GreenswardItemMapModel = require("ui.models.greensward.item.GreenswardItemMapModel")

local LeaderEventModel2 = class(GreenswardEventModel, "LeaderEventModel2")

function LeaderEventModel2:ctor()
    LeaderEventModel2.super.ctor(self)
    self.ctrlPath = "ui.controllers.greensward.dialog.OpponentDialogCtrl"
end

function LeaderEventModel2:TriggerEvent()
	EventSystem.SendEvent("GreenswardOpponentEventTrigger", self)
end

function LeaderEventModel2:HasEvent()
    return true
end

function LeaderEventModel2:GetEventResName()
    return "OpponentEvent"
end

function LeaderEventModel2:GetNameColorParam()
    return 255, 255, 255
end

function LeaderEventModel2:GetSignPrefabName()
    return "MarkSign"
end

function LeaderEventModel2:GetNameBorderName()
    return "Name_Border3"
end

function LeaderEventModel2:GetCloudEffectRes()
    local st = self:GetCurrentState()
    if tobool(tonumber(st) == GreenswardEventModel.EventStatus.Lock_Effect) then
        return "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Effect/EffectLight.prefab"
    elseif tobool(tonumber(st) == GreenswardEventModel.EventStatus.LockWithSign) then
        return "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Effect/EffectEddy.prefab"
    end
end

function LeaderEventModel2:GetMarkNum()
    return self.data.order
end

return LeaderEventModel2

local GreenswardEventModel = require("ui.models.greensward.event.GreenswardEventModel")
local EntranceEventModel = class(GreenswardEventModel, "EntranceEventModel")

function EntranceEventModel:ctor()
    EntranceEventModel.super.ctor(self)
	self.isOpen = true
end

function EntranceEventModel:TriggerEvent()

end

function EntranceEventModel:IsFlyAction()
    return false
end

function EntranceEventModel:IsShowPlane()
    return true
end

function EntranceEventModel:IsOriginPoint()
    return true
end

function EntranceEventModel:HasClear()
    return false
end

function EntranceEventModel:HasFog()
	return false
end

function EntranceEventModel:HasEvent()
    return true
end

function EntranceEventModel:GetFlyAnimationRes()
    return "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Effect/EffectPlane.prefab"
end

function EntranceEventModel:GetEventResName()
    return "PlaneEvent"
end

return EntranceEventModel
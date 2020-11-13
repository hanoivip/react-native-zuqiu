local DialogManager = require("ui.control.manager.DialogManager")
local GreenswardEventModel = require("ui.models.greensward.event.GreenswardEventModel")
local MountainEventModel = class(GreenswardEventModel, "MountainEventModel")

function MountainEventModel:ctor()
    MountainEventModel.super.ctor(self)
end

function MountainEventModel:HandleClickEvent()
    local st = self:GetCurrentState()
    if tobool(tonumber(st) == GreenswardEventModel.EventStatus.BeOperable) then 
        DialogManager.ShowToast(lang.trans("mountain_tip"))
    elseif tobool(tonumber(st) == GreenswardEventModel.EventStatus.Lock_Effect) then 
        DialogManager.ShowToast(lang.trans("thunderstorm_tip"))
    end
end

return MountainEventModel
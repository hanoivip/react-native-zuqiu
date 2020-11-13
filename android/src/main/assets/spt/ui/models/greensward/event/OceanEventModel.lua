local DialogManager = require("ui.control.manager.DialogManager")
local GreenswardEventModel = require("ui.models.greensward.event.GreenswardEventModel")
local GreenswardItemMapModel = require("ui.models.greensward.item.GreenswardItemMapModel")
local GreenswardItemActionMainCtrl = require("ui.controllers.greensward.item.itemAction.GreenswardItemActionMainCtrl")

local OceanEventModel = class(GreenswardEventModel, "OceanEventModel")

function OceanEventModel:ctor()
    OceanEventModel.super.ctor(self)
    self.isIconKeep = true
    local uiParam =  {
        icon_pos = {x = 0, y = 5, z = 0},
        icon_scale = {x = 2.1, y = 2.1, z = 1}
    }
    self:SetUIParam(uiParam)
end

function OceanEventModel:GetPicIndex()
    if not self:IsTheEventOver() then
        return self.staticData.picIndex
    else
        return "water_passed"
    end
end

function OceanEventModel:TriggerEvent()
    local effectPos = self:GetEffectPos()
    local effectState = GreenswardEventModel.EventStatus.Unlock
    local itemId = self:GetConsumeItemId()
    local itemModel = GreenswardItemMapModel.new():GetItemModelById(itemId)
    if not itemModel then
        self:HandleClickEvent()
        return
    end

    local actionMainCtrl = GreenswardItemActionMainCtrl.new(itemModel, self:GetBuildModel(), self)
    actionMainCtrl:DoAction()

    EventSystem.SendEvent("GreenswardEventModel_StatusChange", self, effectPos, effectState)
end

function OceanEventModel:HandleClickEvent()
    local st = self:GetCurrentState()
    if tobool(tonumber(st) == GreenswardEventModel.EventStatus.BeOperable) then
        if not self:CanEssentialItemFill() then
            DialogManager.ShowToast(lang.trans("ocean_tip"))
        end
    elseif tobool(tonumber(st) == GreenswardEventModel.EventStatus.Lock_Effect) then
        DialogManager.ShowToast(lang.trans("thunderstorm_tip"))
    end
end

function OceanEventModel:HasEvent()
    return true
end

function OceanEventModel:HasTweenExtension()
    return true
end

function OceanEventModel:GetEventResName()
    return "UseItemEvent"
end

return OceanEventModel

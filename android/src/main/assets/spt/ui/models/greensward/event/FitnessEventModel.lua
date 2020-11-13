local GeneralEventModel = require("ui.models.greensward.event.GeneralEventModel")
local FitnessEventModel = class(GeneralEventModel, "FitnessEventModel")

function FitnessEventModel:ctor()
    FitnessEventModel.super.ctor(self)
    self.eventResName = "BuildEvent"
    self.eventTriggerName = "GreenswardGeneralEventTrigger"
    self.ctrlPath = "ui.controllers.greensward.dialog.GeneralDialogCtrl"
end

function FitnessEventModel:SetTriggerEventName(eventTriggerName)
    self.eventTriggerName = eventTriggerName
end

function FitnessEventModel:TriggerEvent()
    EventSystem.SendEvent(self.eventTriggerName, self)
end

function FitnessEventModel:HasEvent()
    return true
end

function FitnessEventModel:HandleEvent(data)
    local floorData = self:GetAdventureFloorData()
    local gymBuff = tonumber(floorData.gymBuff)

    local symbol = gymBuff >= 0 and "+" or ""
    local colorHex = gymBuff >= 0 and "green" or "red"
    local tips = "<color=" .. colorHex .. ">" .. lang.transstr("allAttribute") .. ": " .. symbol .. gymBuff .. "%</color>"
    self:SetTip(tips)
end

function FitnessEventModel:GetContentText()
    local floorData = self:GetAdventureFloorData()
    local gymBuff = tonumber(floorData.gymBuff)
    return lang.trans("adventure_fitness_tips", gymBuff)
end

function FitnessEventModel:GetMoraleButtonDesc()
    return lang.trans("adventure_fitness_desc")
end

function FitnessEventModel:GetLeaveButtonDesc()
    return lang.trans("leave")
end

function FitnessEventModel:GetEventResName()
    return self.eventResName
end

function FitnessEventModel:GetBottomBoardName()
    return "Fitness_Dlog"
end

return FitnessEventModel
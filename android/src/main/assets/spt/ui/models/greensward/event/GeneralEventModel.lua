local GreenswardEventModel = require("ui.models.greensward.event.GreenswardEventModel")
local GeneralEventModel = class(GreenswardEventModel, "GeneralEventModel")

function GeneralEventModel:ctor()
    GeneralEventModel.super.ctor(self)
    self.eventResName = "TriggerEvent"
    self.eventTriggerName = "GreenswardGeneralEventTrigger"
    self.moralebuttonDesc = ""
    self.powerbuttonDesc = ""
    self.leaveButtonDesc = ""
    self.itembuttonDesc = ""
    self.bottomBoardName = ""
    self.hasTweenExtension = false
end

function GeneralEventModel:SetTriggerEventName(eventTriggerName)
    self.eventTriggerName = eventTriggerName
end

function GeneralEventModel:TriggerEvent()
    EventSystem.SendEvent(self.eventTriggerName, self)
end

function GeneralEventModel:HasEvent()
    return true
end

function GeneralEventModel:SetEventResName(eventResName)
    self.eventResName = eventResName
end

function GeneralEventModel:SetCtrlPath(ctrlPath)
    self.ctrlPath = ctrlPath
end

function GeneralEventModel:GetContentText()
    return self.contentText
end

function GeneralEventModel:GetMoraleButtonDesc()
    return self.moralebuttonDesc
end

function GeneralEventModel:GetPowerButtonDesc()
    return self.powerbuttonDesc
end

function GeneralEventModel:GetItemButtonDesc()
    return self.itembuttonDesc
end

function GeneralEventModel:GetLeaveButtonDesc()
    return self.leaveButtonDesc
end

function GeneralEventModel:SetContentText(contentText)
    self.contentText = contentText
end

function GeneralEventModel:SetMoraleButtonDesc(moralebuttonDesc)
    self.moralebuttonDesc = moralebuttonDesc
end

function GeneralEventModel:SetPowerButtonDesc(powerbuttonDesc)
    self.powerbuttonDesc = powerbuttonDesc
end

function GeneralEventModel:SetItemButtonDesc(itembuttonDesc)
    self.itembuttonDesc = itembuttonDesc
end

function GeneralEventModel:SetLeaveButtonDesc(leaveButtonDesc)
    self.leaveButtonDesc = leaveButtonDesc
end

function GeneralEventModel:GetEventResName()
    return self.eventResName
end

function GeneralEventModel:GetDialogTitleColor()
    return nil
end

function GeneralEventModel:SetTweenExtension(hasTweenExtension)
    self.hasTweenExtension = hasTweenExtension
end

function GeneralEventModel:HasTweenExtension()
    return self.hasTweenExtension
end

return GeneralEventModel
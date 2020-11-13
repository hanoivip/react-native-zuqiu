local DialogManager = require("ui.control.manager.DialogManager")
local GeneralEventModel = require("ui.models.greensward.event.GeneralEventModel")
local SubwayEventModel = class(GeneralEventModel, "SubwayEventModel")

function SubwayEventModel:ctor()
    SubwayEventModel.super.ctor(self)
    self.isIconKeep = true
    self.ctrlPath = "ui.controllers.greensward.dialog.SubwayDialogCtrl"
end

function SubwayEventModel:TriggerEvent()
    EventSystem.SendEvent("GreenswardGeneralEventTrigger", self)
end

function SubwayEventModel:IsOperable()
    local st = self:GetCurrentState()
    return tobool(tonumber(st) == GreenswardEventModel.EventStatus.Unlock)
end

function SubwayEventModel:HasEvent()
    return true
end

function SubwayEventModel:IsPreserveEvent()
    return true
end

function SubwayEventModel:GetContentText()
    return lang.trans("adventure_subway_tips")
end

function SubwayEventModel:GetMoraleButtonDesc()
    return lang.trans("buy_ticket_tip")
end

function SubwayEventModel:GetLeaveButtonDesc()
    return lang.trans("leave")
end

function SubwayEventModel:GetEventResName()
    return "BuildEvent"
end

function SubwayEventModel:HandleEvent(data)
    local base = data.base or { }
    local footPrint = base.footPrint or { }
    local map = data.ret and data.ret.map or { }
    EventSystem.SendEvent("GreenswardSubwayJump", footPrint[1], footPrint[2], map)
end

function SubwayEventModel:GetBottomBoardName()
    return "Subway_Dlog"
end

function SubwayEventModel:HandleEventExtension()
    DialogManager.ShowToast(lang.trans("subway_pass_tip"))
end

return SubwayEventModel
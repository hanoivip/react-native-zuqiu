local GeneralEventModel = require("ui.models.greensward.event.GeneralEventModel")
local GreenswardItemMapModel = require("ui.models.greensward.item.GreenswardItemMapModel")

local ChargeStationEventModel = class(GeneralEventModel, "ChargeStationEventModel")

function ChargeStationEventModel:ctor()
    ChargeStationEventModel.super.ctor(self)
    self.eventTriggerName = "GreenswardGeneralEventTrigger"
    self.ctrlPath = "ui.controllers.greensward.dialog.GeneralDialogCtrl"
end

function ChargeStationEventModel:InitData(key, data, buildModel)
    ChargeStationEventModel.super.InitData(self, key, data, buildModel)
    self.itemModel = GreenswardItemMapModel.new():GetItemModelById(self:GetConsumeItemId())
end

function ChargeStationEventModel:RefreshData(data)
    ChargeStationEventModel.super.RefreshData(self, data)
    self.itemModel = GreenswardItemMapModel.new():GetItemModelById(self:GetConsumeItemId())
end

function ChargeStationEventModel:HasEvent()
    return true
end

function ChargeStationEventModel:GetContentText()
    return lang.trans("adventure_station_tips")
end

function ChargeStationEventModel:GetMoraleButtonDesc()
    return lang.trans("adventure_station_desc")
end

function ChargeStationEventModel:GetPowerButtonDesc()
    return lang.trans("adventure_station_desc")
end

function ChargeStationEventModel:GetItemButtonDesc()
    return lang.trans("adventure_use_pass_card", self:GetConsumeItemName())
end

function ChargeStationEventModel:GetUseItemTip()
    return lang.trans("adventure_use_item_tip2", self:GetConsumeItemName())
end

function ChargeStationEventModel:GetEventResName()
    return "CombineEvent"
end

function ChargeStationEventModel:GetLeaveButtonDesc()
    return lang.trans("leave")
end

function ChargeStationEventModel:ConsumeByItem()
    return ChargeStationEventModel.super.ConsumeByItem(self)
end

function ChargeStationEventModel:GetConsumeItemModel()
    return self.itemModel
end

function ChargeStationEventModel:GetConsumeItemName()
    local name = ""
    if self.itemModel then
        name = self.itemModel:GetName()
    end
    return name
end

function ChargeStationEventModel:GetBottomBoardName()
    return "ChargeStation_Dlog"
end

function ChargeStationEventModel:GetPassTip()
    return "station_pass_tip"
end

return ChargeStationEventModel

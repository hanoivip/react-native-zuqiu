local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local GeneralEventModel = require("ui.models.greensward.event.GeneralEventModel")
local GreenswardItemMapModel = require("ui.models.greensward.item.GreenswardItemMapModel")

local StoneEventModel = class(GeneralEventModel, "StoneEventModel")

function StoneEventModel:ctor()
    StoneEventModel.super.ctor(self)
    self.eventTriggerName = "GreenswardGeneralEventTrigger"
    self.ctrlPath = "ui.controllers.greensward.dialog.GeneralDialogCtrl"
end

function StoneEventModel:InitData(key, data, buildModel)
    StoneEventModel.super.InitData(self, key, data, buildModel)
    self.itemModel = GreenswardItemMapModel.new():GetItemModelById(self:GetConsumeItemId())
end

function StoneEventModel:RefreshData(data)
    StoneEventModel.super.RefreshData(self, data)
    self.itemModel = GreenswardItemMapModel.new():GetItemModelById(self:GetConsumeItemId())
end

function StoneEventModel:HasEvent()
    return true
end

function StoneEventModel:GetLeaveButtonDesc()
    return lang.trans("leave")
end

function StoneEventModel:GetContentText()
    return lang.trans("adventure_stone_tips")
end

function StoneEventModel:GetMoraleButtonDesc()
    return lang.trans("adventure_stone_desc")
end

function StoneEventModel:GetPowerButtonDesc()
    return lang.trans("adventure_stone_desc")
end

function StoneEventModel:GetItemButtonDesc()
    return lang.trans("adventure_use_pass_card", self:GetConsumeItemName())
end

function StoneEventModel:GetUseItemTip()
    return lang.trans("adventure_use_item_tip2", self:GetConsumeItemName())
end

function StoneEventModel:GetEventResName()
    return "CombineEvent"
end

function StoneEventModel:ConsumeByItem()
    return StoneEventModel.super.ConsumeByItem(self)
end

function StoneEventModel:GetConsumeItemModel()
    return self.itemModel
end

function StoneEventModel:GetConsumeItemName()
    local name = ""
    if self.itemModel then
        name = self.itemModel:GetName()
    end
    return name
end

function StoneEventModel:GetBottomBoardName()
    return "Stone_Dlog"
end

function StoneEventModel:GetDialogTitleColor()
    local color = {
        { percent = 0, color = Color(0, 0, 0, 1) } ,
        { percent = 1, color = Color(0, 0, 0, 1) }
    }
    return color
end

function StoneEventModel:GetPassTip()
    return "stone_pass_tip"
end

return StoneEventModel

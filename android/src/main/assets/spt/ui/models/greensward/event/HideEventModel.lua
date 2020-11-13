local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local GreenswardEventModel = require("ui.models.greensward.event.GreenswardEventModel")
local GreenswardItemMapModel = require("ui.models.greensward.item.GreenswardItemMapModel")
local GreenswardItemUseConType = require("ui.models.greensward.item.configType.GreenswardItemUseConType")

local HideEventModel = class(GreenswardEventModel, "HideEventModel")

function HideEventModel:ctor()
    HideEventModel.super.ctor(self)
    self.ctrlPath = "ui.controllers.greensward.dialog.HideDialogCtrl"
end

function HideEventModel:InitData(key, data, buildModel)
    HideEventModel.super.InitData(self, key, data, buildModel)
    self.itemModel = GreenswardItemMapModel.new():GetItemModelById(self:GetConsumeItemId())
end

function HideEventModel:RefreshData(data)
    HideEventModel.super.RefreshData(self, data)
    self.itemModel = GreenswardItemMapModel.new():GetItemModelById(self:GetConsumeItemId())
end

function HideEventModel:ActivationEvent()
    if not self:IsTreausreFound() then -- 若本层宝藏已经挖到，则不触发点开放大镜事件
        EventSystem.SendEvent("GreenswardTreasureActivationEventTrigger", self)
    end
end

function HideEventModel:TriggerEvent()
    EventSystem.SendEvent("GreenswardGeneralEventTrigger", self)
end

function HideEventModel:HasEvent()
    return true
end

function HideEventModel:GetEventName()
    return lang.trans("adventure_treasure_search")
end

function HideEventModel:GetContentText()
    return lang.trans("adventure_treasure_desc")
end

function HideEventModel:GetMoraleButtonDesc()
    return lang.trans("adventure_treasure_morale_desc")
end

function HideEventModel:GetItemButtonDesc()
    return lang.trans("adventure_use_pass_search", self:GetConsumeItemName())
end

function HideEventModel:GetPowerButtonDesc()
    return lang.trans("adventure_treasure_morale_desc")
end

function HideEventModel:GetLeaveButtonDesc()
    return lang.trans("adventure_treasure_leave_desc")
end

-- 隐藏藏宝格事件，80才可弹出对话框
function HideEventModel:IsShowDialog()
    local st = self:GetCurrentState()
    return tobool(tonumber(st) == self.EventStatus.Observation)
end

function HideEventModel:GetEventResName()
    return "HiddenEvent"
end

function HideEventModel:ConsumeByItem()
    return HideEventModel.super.ConsumeByItem(self) and self:CanConsumeItemFill()
end

function HideEventModel:GetConsumeItemModel()
    return self.itemModel
end

function HideEventModel:GetConsumeItemName()
    local name = ""
    if self.itemModel then
        name = self.itemModel:GetName()
    end
    return name
end

function HideEventModel:GetBottomBoardName()
    return "Treasure_Dlog"
end

function HideEventModel:GetDialogTitleColor()
    local color = {
        { percent = 0, color = Color(0, 0, 0, 1) } ,
        { percent = 1, color = Color(0, 0, 0, 1) }
    }
    return color
end

-- 藏宝图道具有层数条件
function HideEventModel:CanEssentialItemFill()
    local needItem = self:GetEssentialItem()
    local hasItem = false
    if type(needItem) == "table" then
        local itemMapModel = GreenswardItemMapModel.new()
        local currFloor = tonumber(self:GetBuildModel():GetCurrentFloor())
        for k, v in ipairs(needItem) do
            local treasureMap = itemMapModel:GetItemModelById(v.id)
            if treasureMap:GetOwnNum() >= tonumber(v.num)
                and treasureMap:GetUseConditionType() == GreenswardItemUseConType.Floor
                and treasureMap:CanUseCondifionFill(currFloor) then
                hasItem = true
                break
            end
        end
    end
    return table.isEmpty(needItem) or hasItem
end

function HideEventModel:HasTweenExtension()
    return true
end

function HideEventModel:GetTip()
    return "treasure_open_tip"
end

-- 本层藏宝图是否找到
function HideEventModel:IsTreausreFound()
    return self.buildModel:IsCurrFloorTreasureFound()
end

return HideEventModel

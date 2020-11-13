local BaseCtrl = require("ui.controllers.BaseCtrl")
local DreamHallHistoryModel = require("ui.models.dreamLeague.dreamHall.DreamHallHistoryModel")

local DreamHallHistoryCtrl = class(BaseCtrl, "DreamHallHistoryCtrl")

DreamHallHistoryCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

DreamHallHistoryCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamHall/DreamHallHistory/DreamHallHistory.prefab"

function DreamHallHistoryCtrl:Init(dreamHallHistoryModel)
    self.dreamHallHistoryModel = dreamHallHistoryModel
end

function DreamHallHistoryCtrl:Refresh(dreamHallHistoryModel)
    DreamHallHistoryCtrl.super.Refresh(self)
    self.view:InitView(dreamHallHistoryModel)
end

function DreamHallHistoryCtrl:GetStatusData()
    return self.dreamHallHistoryModel
end
return DreamHallHistoryCtrl
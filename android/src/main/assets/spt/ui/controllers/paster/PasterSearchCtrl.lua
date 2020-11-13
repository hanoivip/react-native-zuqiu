local CardPastersMapModel = require("ui.models.CardPastersMapModel")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local SkillShowType = require("ui.scene.skill.SkillShowType")
local DialogManager = require("ui.control.manager.DialogManager")
local BaseCtrl = require("ui.controllers.BaseCtrl")

local PasterSearchCtrl = class(BaseCtrl, "PasterSearchCtrl")

PasterSearchCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Paster/PasterSearchBoard.prefab"

PasterSearchCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function PasterSearchCtrl:Init(pasterQueueModel)
    self.pasterQueueModel = pasterQueueModel
end

function PasterSearchCtrl:Refresh()
    PasterSearchCtrl.super.Refresh(self)
    self.view:InitView(self.pasterQueueModel)
end

function PasterSearchCtrl:GetStatusData()
    return self.pasterQueueModel
end

return PasterSearchCtrl

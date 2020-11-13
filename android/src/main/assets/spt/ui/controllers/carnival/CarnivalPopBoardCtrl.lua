local BaseCtrl = require("ui.controllers.BaseCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local CarnivalPopBoardCtrl = class(BaseCtrl, "CarnivalPopBoardCtrl")

CarnivalPopBoardCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}
CarnivalPopBoardCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Carnival/Prefabs/CarnivalRewardPopBoard.prefab"

function CarnivalPopBoardCtrl:Init(rewardModel)
    self.rewardModel = rewardModel
    self.view:InitView(rewardModel)
end

function CarnivalPopBoardCtrl:GetStatusData()
    return self.rewardModel
end

return CarnivalPopBoardCtrl
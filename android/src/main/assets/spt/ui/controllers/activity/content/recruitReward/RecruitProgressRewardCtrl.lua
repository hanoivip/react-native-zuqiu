local BaseCtrl = require("ui.controllers.BaseCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local RecruitProgressRewardCtrl = class(BaseCtrl, "RecruitProgressRewardCtrl")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")

RecruitProgressRewardCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

RecruitProgressRewardCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/RecruitReward/RecruitProgressReward.prefab"

function RecruitProgressRewardCtrl:ctor()
end

function RecruitProgressRewardCtrl:Init(progressDataList, recruitRewardModel)
    self.recruitRewardModel = recruitRewardModel or {}
    self.progressDataList = progressDataList
    self.view:InitView(progressDataList, recruitRewardModel)
end

return RecruitProgressRewardCtrl
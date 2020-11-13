local BaseCtrl = require("ui.controllers.BaseCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local TimeLimitExplorePointRewardCtrl = class(BaseCtrl, "TimeLimitExplorePointRewardCtrl")

TimeLimitExplorePointRewardCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}
TimeLimitExplorePointRewardCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Explore/TimeLimitPointRewardBoard.prefab"

function TimeLimitExplorePointRewardCtrl:Init(rewardModel, func)
    self.rewardModel = rewardModel
    self.view:InitView(rewardModel, func)
end

function TimeLimitExplorePointRewardCtrl:GetStatusData()
    return self.rewardModel
end

return TimeLimitExplorePointRewardCtrl
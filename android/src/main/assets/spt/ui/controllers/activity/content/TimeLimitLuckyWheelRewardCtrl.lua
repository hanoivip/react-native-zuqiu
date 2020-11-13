local BaseCtrl = require("ui.controllers.BaseCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local TimeLimitLuckyWheelRewardCtrl = class(BaseCtrl, "TimeLimitLuckyWheelRewardCtrl")

TimeLimitLuckyWheelRewardCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}
TimeLimitLuckyWheelRewardCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/LuckyWheelEx/TimeLimitLuckyWheelRewardBoard.prefab"

function TimeLimitLuckyWheelRewardCtrl:Init(rewardModel, func)
    self.rewardModel = rewardModel
    self.view:InitView(rewardModel, func)
end

function TimeLimitLuckyWheelRewardCtrl:GetStatusData()
    return self.rewardModel
end

return TimeLimitLuckyWheelRewardCtrl
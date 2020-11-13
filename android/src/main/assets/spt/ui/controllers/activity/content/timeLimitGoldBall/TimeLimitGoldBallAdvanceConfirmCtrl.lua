local BaseCtrl = require("ui.controllers.BaseCtrl")

local TimeLimitGoldBallAdvanceConfirmCtrl = class(BaseCtrl, "TimeLimitGoldBallAdvanceConfirmCtrl")

TimeLimitGoldBallAdvanceConfirmCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/TimeLimitGoldBall/TimeLimitGoldBallAdvanceConfirm.prefab"

TimeLimitGoldBallAdvanceConfirmCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function TimeLimitGoldBallAdvanceConfirmCtrl:ctor()
    TimeLimitGoldBallAdvanceConfirmCtrl.super.ctor(self)
end

function TimeLimitGoldBallAdvanceConfirmCtrl:Init(timeLimitGoldBallModel)
    TimeLimitGoldBallAdvanceConfirmCtrl.super.Init(self)
    self.view:InitView(timeLimitGoldBallModel)
end

function TimeLimitGoldBallAdvanceConfirmCtrl:Refresh(timeLimitGoldBallModel)
    TimeLimitGoldBallAdvanceConfirmCtrl.super.Refresh(self)
    self.view:RefreshView()
end

return TimeLimitGoldBallAdvanceConfirmCtrl

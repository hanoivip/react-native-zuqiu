local BaseCtrl = require("ui.controllers.BaseCtrl")
local CompeteGuessReverseRewardModel = require("ui.models.compete.guess.CompeteGuessReverseRewardModel")

local CompeteGuessReverseRewardCtrl = class(BaseCtrl, "CompeteGuessReverseRewardCtrl")

CompeteGuessReverseRewardCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Compete/Guess/CompeteGuessReverseReward.prefab"

CompeteGuessReverseRewardCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function CompeteGuessReverseRewardCtrl:ctor()
    CompeteGuessReverseRewardCtrl.super.ctor(self)
end

function CompeteGuessReverseRewardCtrl:Init(reverseReweard, minStage, maxStage)
end

function CompeteGuessReverseRewardCtrl:Refresh(reverseReweard, minStage, maxStage)
    CompeteGuessReverseRewardCtrl.super.Refresh(self)
    self.model = CompeteGuessReverseRewardModel.new()
    self.model:InitReverseReward(reverseReweard, minStage, maxStage)
    self.view:InitView(self.model)
end

return CompeteGuessReverseRewardCtrl

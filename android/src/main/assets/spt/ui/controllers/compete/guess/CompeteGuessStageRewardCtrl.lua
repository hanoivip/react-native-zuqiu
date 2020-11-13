local BaseCtrl = require("ui.controllers.BaseCtrl")
local CompeteGuessStageRewardModel = require("ui.models.compete.guess.CompeteGuessStageRewardModel")

local CompeteGuessStageRewardCtrl = class(BaseCtrl, "CompeteGuessStageRewardCtrl")

CompeteGuessStageRewardCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Compete/Guess/CompeteGuessStageReward.prefab"

CompeteGuessStageRewardCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function CompeteGuessStageRewardCtrl:ctor()
    CompeteGuessStageRewardCtrl.super.ctor(self)
end

function CompeteGuessStageRewardCtrl:Init(stageReward, canSupport)
end

function CompeteGuessStageRewardCtrl:Refresh(stageReward, canSupport)
    CompeteGuessStageRewardCtrl.super.Refresh(self)
    self.model = CompeteGuessStageRewardModel.new()
    self.model:InitStageReward(stageReward, canSupport)
    self.view:InitView(self.model)
end

function CompeteGuessStageRewardCtrl:GetStatusData()
    return self.model:GetStatusData()
end

return CompeteGuessStageRewardCtrl

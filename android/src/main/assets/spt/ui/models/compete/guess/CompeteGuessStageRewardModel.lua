local Model = require("ui.models.Model")

local CompeteGuessStageRewardModel = class(Model, "CompeteGuessStageRewardModel")

function CompeteGuessStageRewardModel:ctor()
    -- 竞猜奖励奖励
    self.stageReward = nil
end

function CompeteGuessStageRewardModel:InitStageReward(stageReward, canSupport)
    self.stageReward = stageReward
    self.canSupport = canSupport
end

-- 获得竞猜奖励数据
function CompeteGuessStageRewardModel:GetStageReward()
    return self.stageReward
end

-- 是否显示竞猜按钮
function CompeteGuessStageRewardModel:CanSupport()
    return self.canSupport
end

function CompeteGuessStageRewardModel:GetStatusData()
    return self.stageReward, self.canSupport
end

return CompeteGuessStageRewardModel

local Model = require("ui.models.Model")

local CompeteGuessReverseRewardModel = class(Model, "CompeteGuessReverseRewardModel")

function CompeteGuessReverseRewardModel:ctor()
    -- 翻盘奖励
    self.reverseReward = nil
end

function CompeteGuessReverseRewardModel:InitReverseReward(reverseReweard, minStage, maxStage)
    self.reverseData = reverseReweard
    self.minStage = minStage
    self.maxStage = maxStage
    self.reverseReward = {}
    for k, v in pairs(reverseReweard) do
        table.insert(self.reverseReward, v)
    end
    table.sort(self.reverseReward, function(a, b) return a.idx < b.idx end)
    for k, v in ipairs(self.reverseReward) do
        v.nextComebackTimes = self.reverseReward[k + 1] and self.reverseReward[k + 1].comebackTimes or 0
    end
end

-- 获取翻盘奖励数据
function CompeteGuessReverseRewardModel:GetReverseReward()
    return self.reverseReward
end

-- 获得翻盘奖励判断
function CompeteGuessReverseRewardModel:GetJudgeStage()
    return self.minStage, self.maxStage
end

return CompeteGuessReverseRewardModel

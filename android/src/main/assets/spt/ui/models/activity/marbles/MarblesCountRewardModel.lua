local Model = require("ui.models.Model")
local MarblesCountRewardModel = class(Model)
MarblesCountRewardModel.RewardState = {}
MarblesCountRewardModel.RewardState.Disable = 1
MarblesCountRewardModel.RewardState.Enable = 2
MarblesCountRewardModel.RewardState.Received = 3
local RewardState = MarblesCountRewardModel.RewardState

function MarblesCountRewardModel:ctor(marblesModel)
    self.marblesModel = marblesModel
end

function MarblesCountRewardModel:InitWithProtocol(rewardData)
    self.rewardData = rewardData
    self:InitRewardList()
end

function MarblesCountRewardModel:InitRewardList()
    self.rewardList = {}
    local curCount = self:GetCurShootCount()
    for k, v in pairs(self.rewardData.countList) do
        v.rewardState = RewardState.Enable
        if v.receive == 0 and v.count > curCount then
            v.rewardState = RewardState.Disable
        elseif v.receive == 1 then
            v.rewardState = RewardState.Received
        end
        table.insert(self.rewardList, v)
    end
    table.sort(self.rewardList, function(a, b) return a.count < b.count end)
end

function MarblesCountRewardModel:GetCountRewardList()
    return self.rewardList or {}
end

function MarblesCountRewardModel:ChangeRewardState(rewardId)
    rewardId = tostring(rewardId)
    self.rewardData.countList[rewardId].receive = 1
    self:InitRewardList()
end

function MarblesCountRewardModel:GetCurShootCount()
    return self.rewardData.shootCnt or 0
end

function MarblesCountRewardModel:GetPeriodId()
    local periodId = self.marblesModel:GetPeriodId()
    return periodId
end

function MarblesCountRewardModel:RefreshData(data)
end

return MarblesCountRewardModel

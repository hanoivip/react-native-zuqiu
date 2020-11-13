local RewardStatus = require("ui.models.friends.RewardStatus")
local Model = require("ui.models.Model")

local RewardItemViewModel = class(Model, "RewardItemViewModel")

function RewardItemViewModel:ctor(data)
    RewardItemViewModel.super.ctor(self)

    self.singleData = data
end

--可领取未领取
function RewardItemViewModel:IsRewardCollectable()
    return self.singleData.status == RewardStatus.COLLECTABLE
end

--已领取
function RewardItemViewModel:IsRewardAlreadyCollected()
    return self.singleData.status == RewardStatus.COLLECTED
end

--未达成条件
function RewardItemViewModel:IsRewardUnqualified()
    return self.singleData.status == RewardStatus.INCOMPLETE
end
function RewardItemViewModel:IsRewardInComplete()
    return self.singleData.status == RewardStatus.INCOMPLETE
end

function RewardItemViewModel:GetContents()
    return self.singleData.contents
end

function RewardItemViewModel:SetStatus(value)
    self.singleData.status = value
end

--是否显示左右的箭头，当奖励物品的数目大于count时显示
function RewardItemViewModel:IsArrowsShow(count)
    return self.singleData.contentsCount > count
end

function RewardItemViewModel:GetSingleData()
    return self.singleData
end

return RewardItemViewModel
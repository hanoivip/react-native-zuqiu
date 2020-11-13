local ActivityModel = require("ui.models.activity.ActivityModel")
local GrowthPlanModel = class(ActivityModel)

function GrowthPlanModel:InitWithProtocol()
end

function GrowthPlanModel:GetRewardData()
    return self:GetActivitySingleData().list
end

function GrowthPlanModel:GetConditionDescByIndex(index)
    return self:GetActivitySingleData().list[index].conditionDesc
end

function GrowthPlanModel:GetRewardProgressByIndex(index)
    return self:GetActivitySingleData().list[index].value
end

function GrowthPlanModel:GetRemainTime()
    local isBuy = self:IsBought()
    if not isBuy then
        return self:GetActivitySingleData().remainTime
    else
        return self:GetActivitySingleData().showRemainTime
    end
end

function GrowthPlanModel:GetActivityDesc()
    return self:GetActivitySingleData().desc
end

function GrowthPlanModel:GetRewardStatusByIndex(index)
    return self:GetActivitySingleData().list[index].status
end

function GrowthPlanModel:SetRewardStatusByIndex(index, value)
    self:GetActivitySingleData().list[index].status = value
end

function GrowthPlanModel:GetRewardSubIdByIndex(index)
    return self:GetActivitySingleData().list[index].subID
end

function GrowthPlanModel:GetDiamondToBuy()
    return self:GetActivitySingleData().list[1].diamond
end

-- 是否已经购买过成长计划
function GrowthPlanModel:IsBought()
    return tobool(self:GetActivitySingleData().isBuy)
end

-- 支付类型（豪门币欧元钻石）
function GrowthPlanModel:GetPayType()
    return self:GetActivitySingleData().list[1].currencyType
end

function GrowthPlanModel:GetTitle()
    return self:GetActivitySingleData().title
end

return GrowthPlanModel
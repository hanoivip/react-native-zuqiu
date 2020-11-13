local ActivityModel = require("ui.models.activity.ActivityModel")
local BelatedGiftModel = class(ActivityModel)

function BelatedGiftModel:InitWithProtocol()
end

function BelatedGiftModel:GetRewardSubIdByIndex(index)
    return self:GetActivitySingleData().list[index].subID
end

function BelatedGiftModel:GetRewardStatusByIndex(index)
    return self:GetActivitySingleData().list[index].status
end

function BelatedGiftModel:SetRewardStatusByIndex(index, value)
    self:GetActivitySingleData().list[index].status = value
end

function BelatedGiftModel:GetActivityDesc()
    return self:GetActivitySingleData().desc
end

function BelatedGiftModel:GetCurrentConsumeList()
    return self:GetActivitySingleData().list
end

function BelatedGiftModel:GetCurrServerTime()
    return self:GetActivitySingleData().serverTime
end

function BelatedGiftModel:GetDescTip()
    return self:GetActivitySingleData().descTip
end

function BelatedGiftModel:GetName()
    return self:GetActivitySingleData().name or lang.trans("belatedGift_title")
end

function BelatedGiftModel:GetTime()
    if self:GetActivitySingleData().serverTime - self:GetActivitySingleData().activityEndTime < 0 then
        return  lang.trans("cumulative_pay_time", string.convertSecondToMonth(self:GetActivitySingleData().beginTime), 
                                    string.convertSecondToMonth(self:GetActivitySingleData().activityEndTime))
    else
        return  lang.trans("belatedGift_recv_time", string.convertSecondToMonth(self:GetActivitySingleData().endTime))
    end
end
return BelatedGiftModel
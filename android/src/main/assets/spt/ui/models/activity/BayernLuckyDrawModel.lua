local ActivityModel = require("ui.models.activity.ActivityModel")
local BayernLuckyDrawModel = class(ActivityModel)

function BayernLuckyDrawModel:InitWithProtocol()
end

function BayernLuckyDrawModel:GetRewardData()
    return self:GetActivitySingleData().list
end

function BayernLuckyDrawModel:GetActivityDesc()
    return self:GetActivitySingleData().desc
end

-- 是否参与抽奖
function BayernLuckyDrawModel:IsClickedFreeDraw()
    local flag = false
    local list = self:GetActivitySingleData().list
    if(list ~= nil) then
        for i, v in pairs(list) do
            if list[i].c_t ~= nil then
                flag = true
            end
        end
    end
    return flag
end

-- 是否领取奖励
function BayernLuckyDrawModel:IsGetReward()
    return tobool(self:GetActivitySingleData().isGetReward)
end

-- 活动显示时间
function BayernLuckyDrawModel:GetRemainTime()
    return tonumber(self:GetActivitySingleData().remainTime)
end

-- 开奖剩余时间
function BayernLuckyDrawModel:GetShowRemainTime()
    return tonumber(self:GetActivitySingleData().list[1].showRemainTime)
end

function BayernLuckyDrawModel:SetRewardStatusByIndex(index,value)
    self:GetActivitySingleData().list[index].status = value
end

function BayernLuckyDrawModel:GetRewardStatusByIndex(index)
    return self:GetActivitySingleData().list[index].status
end

function BayernLuckyDrawModel:GetRwardItemSubIDByIndex(index)
    return self:GetActivitySingleData().list[index].subID
end

function BayernLuckyDrawModel:GetActivityNeedLevel(index)
    return self:GetActivitySingleData().list[index].lvLimit
end

return BayernLuckyDrawModel
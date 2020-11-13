local ActivityModel = require("ui.models.activity.ActivityModel")
local NationalWelfareRewardType = require("ui.models.activity.NationalWelfareRewardType")
local Timer = require('ui.common.Timer')

local NationalWelfareModel = class(ActivityModel)

function NationalWelfareModel:InitWithProtocol()
    self.remainTimer = nil
    self.hasTimer = true
end

-- 奖励的SubId
function NationalWelfareModel:GetRewardSubIdByIndex(index)
    return self.rewardDataList[index].subID
end

-- 奖励领取状态
function NationalWelfareModel:GetRewardStatusByIndex(index)
    return self.rewardDataList[index].status
end

-- 设置奖励领取状态
function NationalWelfareModel:SetRewardStatusByIndex(index, value)
    self.rewardDataList[index].status = value
end

-- 活动描述
function NationalWelfareModel:GetActivityDesc()
    return self:GetActivitySingleData().desc
end

-- 完成充值人数
function NationalWelfareModel:GetPayNumber()
    return self:GetActivitySingleData().value
end

-- 剩余时间
function NationalWelfareModel:GetRemainTime()
    return self:GetActivitySingleData().remainTime
end

-- 设置剩余时间
function NationalWelfareModel:SetRemainTime(remainTime)
    self:GetActivitySingleData().remainTime = remainTime
    -- 通知
    EventSystem.SendEvent("NationalWelfareView.UpdateRemainTime", remainTime)
end

-- 获取奖励列表
function NationalWelfareModel:GetRewardData(rewardType)
    if rewardType == NationalWelfareRewardType.NORMAL then
        return self:GetNationalRewardData()
    elseif rewardType == NationalWelfareRewardType.VIP then
        return self:GetVipRewardData()
    end
end

-- 全民领取奖励
function NationalWelfareModel:GetNationalRewardData()
    self.rewardDataList = {}
    for i = 1, 8 do
        table.insert(self.rewardDataList, self:GetActivitySingleData().list[i])
    end
    return self.rewardDataList
end

-- VIP领取奖励
function NationalWelfareModel:GetVipRewardData()
    self.rewardDataList = {}
    for i = 9, #self:GetActivitySingleData().list do
        table.insert(self.rewardDataList, self:GetActivitySingleData().list[i])
    end
    return self.rewardDataList
end

-- 获取奖励的条件
function NationalWelfareModel:GetRewardConditionByIndex(index)
    return self.rewardDataList[index].condition
end

function NationalWelfareModel:StartTimer()
    self:StopTimer()
    self.remainTimer = Timer.new(self:GetRemainTime(), function(remainTime)
        self:SetRemainTime(remainTime)
    end)
end

function NationalWelfareModel:StopTimer()
    if self.remainTimer ~= nil then
        self.remainTimer:Destroy()
    end
end

return NationalWelfareModel
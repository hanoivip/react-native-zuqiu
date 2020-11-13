local EventSystem = require ("EventSystem")
local CustomEvent = require("ui.common.CustomEvent")
local ActivityModel = require("ui.models.activity.ActivityModel")
local SignModel = class(ActivityModel)

function SignModel:InitWithProtocol()
end

function SignModel:SetSign(isSign)
    self.singleData.isSigned = isSign
end

function SignModel:GetSign()
    return self.singleData.isSigned
end

function SignModel:GetSignLastDay()
    return tonumber(self.singleData.lastDay)
end

-- 自动签到奖励数据和签到数据一并发送
function SignModel:GetSignRewardInfo()
    return self.singleData.signInfo
end

local MaxSignTip = 6 -- 签到在指定天数前会有一个小秘书提示
function SignModel:GetMaxSignDay()
    return MaxSignTip
end

function SignModel:SetSignDay(day)
    self.singleData.lastDay = tonumber(day)
end

function SignModel:GetSignSortData()
    local sign = self.singleData.sign
    local sortDay = {}
    for day, v in pairs(sign) do
        local dayData = clone(v)
        dayData.day = tonumber(day)
        table.insert(sortDay, dayData)
    end
    table.sort(sortDay, function(a, b) return a.day < b.day end)
    return sortDay
end

-- 是否开启关闭按钮
function SignModel:SetCloseButtonState(isOpen)
    self.isOpenCloseButton = isOpen
end

function SignModel:GetCloseButtonState()
    return self.isOpenCloseButton
end

function SignModel:GetRewardData()
    return self.rewardData
end

function SignModel:SetSignCollect(data)
    local contents = data.contents
    if contents.d and tonumber(contents.d) > 0 then
        CustomEvent.GetDiamond("3", tonumber(contents.d))
    end
    if contents.m and tonumber(contents.m) > 0 then
        CustomEvent.GetMoney("6", tonumber(contents.m))
    end
    self.rewardData = data.contents
    self:SetSign(true)
    self:SetSignDay(data.lastDay)
    self:SetNextDayRewardData(data.nr or {})
    EventSystem.SendEvent("SignDay_Change", self)
end

-- 下一天签到的奖励信息
function SignModel:GetNextDayRewardData()
    return (self.singleData.nr and self.singleData.nr.contents) or {}
end

function SignModel:SetNextDayRewardData(nextReward)
    self.singleData.nr = nextReward
end

return SignModel

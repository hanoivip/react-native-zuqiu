local UnityEngine = clr.UnityEngine
local Time = UnityEngine.Time
local Item = require("data.Item")
local ActivityModel = require("ui.models.activity.ActivityModel")
local CurrencyType = require("ui.models.itemList.CurrencyType")
local ChainBoxState = require("ui.scene.activity.content.timeLimitChainBox.ChainBoxState")
local ChainBoxLimitType = require("ui.scene.activity.content.timeLimitChainBox.ChainBoxLimitType")
local TimeLimitChainBoxModel = class(ActivityModel)

function TimeLimitChainBoxModel:ctor(data)
    TimeLimitChainBoxModel.super.ctor(self, data)
    self.singleData = self:GetActivitySingleData()
    self.serverTime = self.singleData.serverTime
    self.lastRealTime = Time.realtimeSinceStartup
end

function TimeLimitChainBoxModel:InitWithProtocol()
    self.singleData = self:GetActivitySingleData()
    self.serverTime = self.singleData.serverTime
    self.lastRealTime = Time.realtimeSinceStartup
end

function TimeLimitChainBoxModel:GetPeriod()
    return self.singleData.ID
end

function TimeLimitChainBoxModel:GetDesc()
    return self.singleData.t_desc
end

function TimeLimitChainBoxModel:GetFinalItemDesc()
    local displayRewards = self:GetDisplayReward()
    local index, finalItem = next(displayRewards.item or {})
    local finalItemId = index and finalItem and finalItem.id
    if finalItemId then
        return Item[finalItemId].desc
    end
    return ""
end

function TimeLimitChainBoxModel:GetScrollData(data)
    local scrollData = self.singleData.list
    local maxBuyIndex = self:GetMaxBuyIndex()
    scrollData[#scrollData].isLast = true
    for i,v in ipairs(scrollData) do
        --礼盒是否买过
        v.clientBoxState = v.status
        if i > maxBuyIndex then
            v.clientBoxState = ChainBoxState.Disable
        else
            if v.limitType == ChainBoxLimitType.None then
                v.clientBoxState = ChainBoxState.Buy
            else
                if v.buyCount >= v.limitAmount and v.status ~= ChainBoxState.Buy then
                    v.clientBoxState = ChainBoxState.Sell
                else
                    v.clientBoxState = ChainBoxState.Buy
                end
            end
        end
        -- 礼盒所需的货币类型
        if v.price1_off > 0 then
            v.price = v.price1_off
            v.originPrice = v.price1
            v.currencyType = CurrencyType.Diamond
        elseif v.price2_off > 0 then
            v.price = v.price2_off
            v.currencyType = CurrencyType.BlackDiamond
            v.originPrice = v.price2
        end
        v.index = i
    end
    return scrollData
end

function TimeLimitChainBoxModel:GetMaxBuyIndex()
    local data = self.singleData.list
    for i,v in ipairs(data) do
        if v.status == ChainBoxState.Buy and v.buyCount == 0 then
            return i
        end
    end
    return #data
end

-- 最后的礼盒额外显示
function TimeLimitChainBoxModel:GetDisplayReward()
    local length = #self.singleData.list
    return self.singleData.list[length].contents, length
end

-- 获取活动剩余时间
function TimeLimitChainBoxModel:GetRemainTime()
    local endTime = tonumber(self.singleData.endTime)
    local osTime = self:GetOSTime()
    local remainTime = endTime - osTime
    if remainTime > 0 then
        return remainTime
    else
        return 0
    end
end

function TimeLimitChainBoxModel:GetOSTime()
    local nowRealTime = Time.realtimeSinceStartup
    local delataTime = math.ceil(nowRealTime - self.lastRealTime)
    local nowServerTime = self.serverTime + delataTime
    return nowServerTime
end

-- 是否在活动时间内
function TimeLimitChainBoxModel:IsTimeInActivity()
    if self.outOfTime then
        return false
    end
    return true
end

function TimeLimitChainBoxModel:SetRunOutOfTime()
    self.outOfTime = true
end

return TimeLimitChainBoxModel

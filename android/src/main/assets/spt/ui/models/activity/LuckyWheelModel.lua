local Coupon = require("data.Coupon")

local EventSystem = require("EventSystem")
local ActivityModel = require("ui.models.activity.ActivityModel")
local CouponModel = require("ui.models.activity.CouponModel")
local LuckyWheelModel = class(ActivityModel)

function LuckyWheelModel:ctor(data)
    LuckyWheelModel.super.ctor(self, data)
end

function LuckyWheelModel:InitWithProtocol()
end

--- 获取折扣商店信息列表
function LuckyWheelModel:GetDiscountStoreList()
    local singleData = self:GetActivitySingleData()
    return singleData.luckWheel.store.list   
end

function LuckyWheelModel:SetDiscountStore(store)
    local singleData = self:GetActivitySingleData()
    singleData.luckWheel.store = store

    EventSystem.SendEvent("LuckyWheelModel_SetDiscountStore", self)
end

function LuckyWheelModel:GetWheelItemsCount()
    local singleData = self:GetActivitySingleData()
    return #singleData.luckWheel.wheel
end

--- 通过Index获取单个抽卡数据
function LuckyWheelModel:GetWheelItemDataByIndex(index)
    local singleData = self:GetActivitySingleData()
    return singleData.luckWheel.wheel[index].contents
end

--- 获取活动开始时间
function LuckyWheelModel:GetStartTime()
    local singleData = self:GetActivitySingleData()
    return singleData.beginTime
end

--- 获取活动结束时间
function LuckyWheelModel:GetEndTime()
    local singleData = self:GetActivitySingleData()
    return singleData.endTime
end

-- 获取转盘剩余次数（需要考虑玩家VIP升级的情况）
function LuckyWheelModel:GetRestTimes()
    local singleData = self:GetActivitySingleData()
    return tonumber(singleData.luckWheel.restTimes)
end

function LuckyWheelModel:SetRestTimes(times)
    local singleData = self:GetActivitySingleData()
    singleData.luckWheel.restTimes = times

    EventSystem.SendEvent("LuckyWheelModel_SetRestTimes", times)
end

-- 折扣商店的剩余刷新次数
function LuckyWheelModel:GetRestRefreshTimes()
    local singleData = self:GetActivitySingleData()
    return tonumber(singleData.luckWheel.restRefreshTimes)
end

function LuckyWheelModel:SetRestRefreshTimes(times)
    local singleData = self:GetActivitySingleData()
    singleData.luckWheel.restRefreshTimes = times

    EventSystem.SendEvent("LuckyWheelModel_SetRestRefreshTimes", times)
end

-- 获取折扣券的数量
function LuckyWheelModel:GetCouponNum(couponID)
    local singleData = self:GetActivitySingleData()
    return singleData.luckWheel.treasure.coupon and tonumber(singleData.luckWheel.treasure.coupon[tostring(couponID)]) or 0
end

function LuckyWheelModel:GetCouponModel(couponID)
    local couponData = {
        id = couponID,
        num = self:GetCouponNum(couponID)
    }
    local couponModel = CouponModel.new(couponData)
    return couponModel
end

-- 获得的转盘奖励index
function LuckyWheelModel:SetCurrentRewardIndex(index)
    local singleData = self:GetActivitySingleData()
    singleData.currentRewardWheelIndex = index

    EventSystem.SendEvent("LuckyWheelModel_SetCurrentRewardIndex", index)
end

-- 设置奖励的折扣券
function LuckyWheelModel:SetTreasure(treasure)
    local singleData = self:GetActivitySingleData()
    singleData.luckWheel.treasure = treasure

    EventSystem.SendEvent("LuckyWheelModel_SetTreasure", self)
end

-- 设置其他奖项
function LuckyWheelModel:SetNormalReward(contents)

end

return LuckyWheelModel

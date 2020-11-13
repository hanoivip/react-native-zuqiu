local Model = require("ui.models.Model")
local AuctionMainConstants = require("ui.models.auction.main.AuctionMainConstants")

local AuctionHallModel = class(Model, "AuctionHallModel")

function AuctionHallModel:ctor()
    self.cacheData = nil
    self.currBtnGroup = nil
    self.content = nil
    self.myBidePrice = 0
    self.canBid = false
    self.isUpdating = false
    -- 定时刷新相关
    self.isTiming = false
    self.counter = 0
    self.interval = 0
end

function AuctionHallModel:InitWithProtocol(data)
    self.cacheData = data
    self.content = {}
    self.content[self.cacheData.itemType] = self.cacheData.itemID
    self.myBidePrice = self:GetLowBidPrice()
    if self.cacheData.canBid ~= nil then
        self.canBid = self.cacheData.canBid
    end
end

function AuctionHallModel:UpdateAfterBid(data)
    local bidData = self.cacheData.data
    if not bidData.count then
        bidData.count = 0
    end
    bidData.count = bidData.count + 1
    bidData.lastTime = data.data.time
    bidData.topPlayer = data.data
    if not bidData.recordList then
        bidData.recordList = {}
    end
    table.insert(bidData.recordList, 1, data.data)
    local recordNums = table.nums(bidData.recordList)
    if recordNums > AuctionMainConstants.AuctionHall_RecordMaxNum then
        table.remove(bidData.recordList)
    end
    -- 第四阶段直接刷新界面时间至1分钟
    if self.cacheData.step == AuctionMainConstants.AuctionStep.STEP_4 and self.cacheData.showRemainTime <= AuctionMainConstants.Auction_Step4_Core_Time then
        self.cacheData.showRemainTime = AuctionMainConstants.Auction_Step4_Core_Time
    end

    self:UpdateLastMyBidMoney(data.data.money)
end

function AuctionHallModel:GetCacheData()
    return self.cacheData
end

function AuctionHallModel:SetStatusData(statusData)
    self:SetMyBidPrice(statusData.myBidePrice)
end

function AuctionHallModel:GetStatusData()
    local statusData = {}
    statusData.id = self.cacheData.id
    statusData.subId = self.cacheData.subId
    statusData.myBidePrice = self.myBidePrice
    return statusData
end

-- 获得本次拍卖期数
function AuctionHallModel:GetPeriod()
    return tonumber(self.cacheData.id)
end

-- 获得拍卖厅ID，subID
function AuctionHallModel:GetSubID()
    return self.cacheData.subId
end

-- 获得本次拍卖开始时间
function AuctionHallModel:GetBeginTime()
    return self.cacheData.beginTime
end

-- 获得本次拍卖各阶段持续时间数组
function AuctionHallModel:GetDuration()
    return self.cacheData.duration
end

-- 获得本次拍卖当前阶段
function AuctionHallModel:GetCurrStep()
    return self.cacheData.step
end

-- 是否在竞拍中
function AuctionHallModel:IsInAuction()
    local step = self:GetCurrStep()
    return step ~= AuctionMainConstants.AuctionStep.NOT_START and step ~= AuctionMainConstants.AuctionStep.FINISH
end

-- 获得当前倒计时
function AuctionHallModel:GetRemainTime()
    return self.cacheData.showRemainTime
end

-- 获得本次拍卖的当前阶段应持续时间，分钟单位
function AuctionHallModel:GetCurrStepDuration()
    local step = tonumber(self.cacheData.step)
    if step > 0 and step < 5 then
        return tonumber(self.cacheData.duration[step])
    else
        return 0
    end
end

-- 获得本次拍卖的物品类型
function AuctionHallModel:GetAuctionItemType()
    return self.cacheData.itemType
end

-- 获得本次拍卖的物品ID
function AuctionHallModel:GetAuctionItemID()
    return self.cacheData.itemID[1].id
end

-- 获得本次拍卖的物品数量
function AuctionHallModel:GetAuctionItemCount()
    return self.cacheData.itemID[1].num
end

-- 获得本次拍卖物品，标准格式
function AuctionHallModel:GetAuctionItem()
    return self.content
end

-- 获得本次拍卖每次点击锤子消耗钻石
function AuctionHallModel:GetBidDiamondPrice()
    return self.cacheData.bidDiamondPrice or 0
end

-- 获得本次拍卖物品单次加价数值
function AuctionHallModel:GetSingleBidPrice()
    return self.cacheData.bidPrice or 1
end

-- 获得本次拍卖第一次竞拍直扣初始价格
function AuctionHallModel:GetInitialPrice()
    return self.cacheData.initialPrice or 0
end

-- 获得本次拍卖物品的最低出价
function AuctionHallModel:GetLowBidPrice()
    return self.cacheData.lowBidPrice or 1
end

-- 获得本次拍卖物品的最高出价
function AuctionHallModel:GetHighBidPrice()
    return self.cacheData.highBidPrice or 1
end

-- 获得我的出价
function AuctionHallModel:GetMyBidPrice()
    return self.myBidePrice
end

-- 设置我的出价
function AuctionHallModel:SetMyBidPrice(price)
    self.myBidePrice = price or self:GetLowBidPrice()
end

-- 获得本次拍卖物品当前价格
function AuctionHallModel:GetCurrPrice()
    local currPrice = 0
    if table.nums(self:GetRecordList()) == 0 then
        currPrice = self.cacheData.initialPrice or 0
    else
        currPrice = self:GetTheTopPlayer().money or 0
    end
    return currPrice
end

-- 获得我上次的出价
function AuctionHallModel:GetLastMyBidMoney()
    return self.cacheData.lastAuctionMoney or 0
end

-- 更新我上次的出价
function AuctionHallModel:UpdateLastMyBidMoney(money)
    self.cacheData.lastAuctionMoney = money or 0
end

-- 获得我本次出价应该扣除的欧元数目
function AuctionHallModel:GetWholeBidMoney()
    return self:GetCurrPrice() + self.myBidePrice - self:GetLastMyBidMoney()
end

-- 获得竞拍次数
function AuctionHallModel:GetBidCount()
    return self.cacheData.data.count or 0
end

-- 获得上次有玩家竞拍时间，时间戳
function AuctionHallModel:GetTheLastBidTime()
    return self.cacheData.data.lastTime or 0
end

-- 获得当前出价最高玩家数据
function AuctionHallModel:GetTheTopPlayer()
    return self.cacheData.data.topPlayer or {}
end

-- 获得拍卖纪录
function AuctionHallModel:GetRecordList()
    return self.cacheData.data.recordList or {}
end

-- 当前阶段是否可以进行竞拍
function AuctionHallModel:CanBid()
    return self.canBid == 1
end

-- 是否处于更新中
function AuctionHallModel:GetIsUpdating()
    return self.isUpdating
end

function AuctionHallModel:SetIsUpdating(value)
    self.isUpdating = value
end

-- 定时刷新功能相关
function AuctionHallModel:StartTiming()
    self.isTiming = true
end

function AuctionHallModel:StopTiming()
    self.isTiming = false
end

function AuctionHallModel:IsTiming()
    return self.isTiming and self.interval > 0 and self:IsInAuction()
end

function AuctionHallModel:GetTimingCounter()
    return self.counter
end

function AuctionHallModel:SetTimingInterval(interval)
    self.interval = interval
end

function AuctionHallModel:UpdateTimingCounter(deltaTime)
    self.counter = self.counter - deltaTime
end

function AuctionHallModel:ResetTimingCounter()
    self.counter = self.interval
end

return AuctionHallModel

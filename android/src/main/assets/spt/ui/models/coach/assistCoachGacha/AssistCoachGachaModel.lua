local UnityEngine = clr.UnityEngine
local Time = UnityEngine.Time
local Model = require("ui.models.Model")
local ItemsMapModel = require("ui.models.ItemsMapModel")

local AssistCoachGachaModel = class(Model, "AssistCoachGachaModel")

function AssistCoachGachaModel:ctor()
    self.itemsMapModel = ItemsMapModel.new()
    self.Diamond_Gacha = 1  -- 抽卡类型 钻石抽卡
    self.Item_Gacha = 2  -- 抽卡类型 道具抽卡
end

function AssistCoachGachaModel:InitWithProtocol(gachaData)
    self.gachalist = {}
    self.cacheGachaList = {}
    for k,v in pairs(gachaData.gachalist) do
        local gachaId = tonumber(k)
        v.gachaId = gachaId
        table.insert(self.gachalist, v)
        self.cacheGachaList[k] = v
    end

    table.sort(self.gachalist, function(a, b) return a.gachaId < b.gachaId end)
    self.serverTime = gachaData.serverTime
    self.luckyPoint = gachaData.luckyPoint or gachaData.lickyPoint
    self.monthBuyTimes = gachaData.monthBuyTimes or 0
    self.monthExchangeTimes = gachaData.monthExchangeTimes or 0
    self.lastRealTime = Time.realtimeSinceStartup
end

-- 当前Tab的抽卡Id
function AssistCoachGachaModel:GetCurrentGachaId()
    return self.gachaId or 1
end

-- 当前Tab的抽卡Id
function AssistCoachGachaModel:SetCurrentGachaId(gachaId)
    local gachaId = tonumber(gachaId or 1)
    self.gachaId = gachaId
end

-- 当前Tab的抽卡数据
function AssistCoachGachaModel:GetGachaDataByGachaId(gachaId)
    gachaId = tostring(gachaId)
    local gachaData = self.cacheGachaList[gachaId]
    return gachaData or {}
end

-- 当前单抽的抽卡单价
function AssistCoachGachaModel:GetCachaOnePrice(gachaId)
    local gachaData = self:GetGachaDataByGachaId(gachaId)
    return gachaData.price or 0
end

-- 当前十连抽的抽卡单价
function AssistCoachGachaModel:GetCachaTenPrice(gachaId)
    local gachaData = self:GetGachaDataByGachaId(gachaId)
    return gachaData.tenPrice or 0
end

-- 当前单抽券的id
function AssistCoachGachaModel:GetCachaOneItemId(gachaId)
    local gachaData = self:GetGachaDataByGachaId(gachaId)
    return gachaData.itemId
end

-- 当前十连抽券的id
function AssistCoachGachaModel:GetCachaTenItemId(gachaId)
    local gachaData = self:GetGachaDataByGachaId(gachaId)
    return gachaData.tenItemId
end

-- 拥有当前单抽券的数量
function AssistCoachGachaModel:GetCachaOneItemCount(gachaId)
    gachaId = gachaId or self:GetCurrentGachaId()
    local id = self:GetCachaOneItemId(gachaId)
    local count = self.itemsMapModel:GetItemNum(id)
    return count or 0
end

-- 拥有当前十连抽券的数量
function AssistCoachGachaModel:GetCachaTenItemCount(gachaId)
    gachaId = gachaId or self:GetCurrentGachaId()
    local id = self:GetCachaTenItemId(gachaId)
    local count = self.itemsMapModel:GetItemNum(id)
    return count or 0
end

-- 当前单抽的抽卡类型 钻石 和 抽卡券  有抽卡券的情况下 不能用钻石
function AssistCoachGachaModel:GetCachaOneConsumeType(gachaId)
    gachaId = gachaId or self:GetCurrentGachaId()
    local count = self:GetCachaOneItemCount(gachaId)
    if count > 0 then
        return self.Item_Gacha
    else
        return self.Diamond_Gacha
    end
end

-- 当前十抽的抽卡类型 钻石 和 抽卡券  有抽卡券的情况下 不能用钻石
function AssistCoachGachaModel:GetCachaTenConsumeType(gachaId)
    gachaId = gachaId or self:GetCurrentGachaId()
    local count = self:GetCachaTenItemCount(gachaId)
    if count > 0 then
        return self.Item_Gacha
    else
        return self.Diamond_Gacha
    end
end

-- 当前十连抽的真实抽卡单价（每月会有几次折扣）
function AssistCoachGachaModel:GetCachaTenDiscountPrice(gachaId)
    local gachaData = self:GetGachaDataByGachaId(gachaId)
    -- 当前的抽卡次数 是否在折扣区间内
    local monthBuyTimes = self:GetMonthBuyTimes()
    local monthDiscountAmount = self:GetCachaMonthDiscountAmount(gachaId)
    local isDiscount = monthDiscountAmount > 0 and monthBuyTimes < monthDiscountAmount
    if isDiscount then
        local monthTenPrice = self:GetCachaMonthTenPrice(gachaId)
        return monthTenPrice
    else
        local price = self:GetCachaTenPrice(gachaId)
        return price
    end
end

-- 当前抽卡每个月的十连优惠价格
function AssistCoachGachaModel:GetCachaMonthTenPrice(gachaId)
    local gachaData = self:GetGachaDataByGachaId(gachaId)
    return gachaData.monthTenPrice or 0
end

-- 当前抽卡的剩余时间
function AssistCoachGachaModel:GetCachaRemainTime(gachaId)
    local gachaData = self:GetGachaDataByGachaId(gachaId)
    local endTime =  tonumber(gachaData.endTime)
    if endTime > 0 then
        local cOSTime = self:GetOSTime()
        return endTime - cOSTime
    end
end

-- 当前抽卡的描述
function AssistCoachGachaModel:GetCachaDesc(gachaId)
    local gachaData = self:GetGachaDataByGachaId(gachaId)
    return gachaData.desc or ""
end

-- 当前抽卡的幸运值描述
function AssistCoachGachaModel:GetCachaLuckyRewardDesc(gachaId)
    local gachaData = self:GetGachaDataByGachaId(gachaId)
    return gachaData.luckyRewardDesc or ""
end

-- 当前抽卡的折扣描述
function AssistCoachGachaModel:GetCachaDiscountDesc(gachaId)
    local gachaData = self:GetGachaDataByGachaId(gachaId)
    return gachaData.monthDiscountDesc or ""
end

-- 每月特殊大奖道具
function AssistCoachGachaModel:GetCachaMonthDiscountReward(gachaId)
    local gachaData = self:GetGachaDataByGachaId(gachaId)
    return gachaData.monthDiscountReward or {}
end

-- 每个月特殊大奖的次数
function AssistCoachGachaModel:GetCachaMonthDiscountAmount(gachaId)
    local gachaData = self:GetGachaDataByGachaId(gachaId)
    return gachaData.monthDiscountAmount or 0
end

-- 幸运点大奖，需要的幸运点数量
function AssistCoachGachaModel:GetCachaLuckyPointReward(gachaId)
    local gachaData = self:GetGachaDataByGachaId(gachaId)
    return gachaData.luckyPointReward or 0
end

-- 幸运点兑换道具
function AssistCoachGachaModel:GetCachaLuckyReward(gachaId)
    local gachaData = self:GetGachaDataByGachaId(gachaId)
    return {gachaData.luckyReward}
end

-- 幸运点兑换道具
function AssistCoachGachaModel:GetCachaMonthExchangeTimes()
    return self.monthExchangeTimes or 0
end

-- 幸运点兑换道具
function AssistCoachGachaModel:SetCachaMonthExchangeTimes(monthExchangeTimes)
    self.monthExchangeTimes = monthExchangeTimes or 0
end

function AssistCoachGachaModel:GetScrollIndexByGachaId(gachaId)
    for i,v in ipairs(self.gachalist) do
        if tonumber(v.gachaId) == tonumber(gachaId) then
            return i
        end
    end
    return 1
end

function AssistCoachGachaModel:GetTabScrollData()
    return self.gachalist or {}
end

function AssistCoachGachaModel:GetGachaDataByScrollIndex(scrollIndex)
    return self.gachalist[scrollIndex] or {}
end

function AssistCoachGachaModel:GetLuckyPoint()
    return self.luckyPoint or 0
end

function AssistCoachGachaModel:GetMonthBuyTimes()
    return self.monthBuyTimes or 0
end

function AssistCoachGachaModel:SetMonthBuyTimes(monthBuyTimes)
    self.monthBuyTimes = monthBuyTimes or 0
end

function AssistCoachGachaModel:SetLuckyPoint(luckyPoint) 
    self.luckyPoint  = luckyPoint or 0
end

function AssistCoachGachaModel:GetNextGachaId(nowGachaId)
    nowGachaId = tonumber(nowGachaId)
    for i,v in ipairs(self.gachalist) do
        if v.gachaId == nowGachaId then
            local nextData = self.gachalist[i + 1]
            return nextData and nextData.gachaId
        end
    end
end

function AssistCoachGachaModel:GetPreGachaId(nowGachaId)
    nowGachaId = tonumber(nowGachaId)
    for i,v in ipairs(self.gachalist) do
        if v.gachaId == nowGachaId then
            local nextData = self.gachalist[i - 1]
            return nextData and nextData.gachaId
        end
    end
end

--当前抽卡页的礼包是可选礼包还是服务器直接随机下发礼包
function AssistCoachGachaModel:GetGiftContent(gachaId)
    local gachaData = self:GetGachaDataByGachaId(gachaId)
    local monthExchangeTimes = self:GetCachaMonthExchangeTimes()
    local luckyReward = self:GetCachaLuckyReward(gachaId)
    if monthExchangeTimes >= 1 then
        return self:SetRewardContentId(luckyReward)
    end
    local monthDiscountReward = gachaData.monthDiscountReward
    if monthDiscountReward and next(monthDiscountReward) then
        return self:SetRewardContentId(monthDiscountReward)
    else
        return self:SetRewardContentId(luckyReward)
    end
end

function AssistCoachGachaModel:SetRewardContentId(rewardTable)
    local contents = {}
    for k,v in pairs(rewardTable) do
        v.contentId = k
        table.insert(contents, v)
    end
    return contents
end

function AssistCoachGachaModel:GetOSTime()
    local nowRealTime = Time.realtimeSinceStartup
    local delataTime = math.ceil(nowRealTime - self.lastRealTime)
    local nowServerTime = self.serverTime + delataTime
    return nowServerTime
end

return AssistCoachGachaModel

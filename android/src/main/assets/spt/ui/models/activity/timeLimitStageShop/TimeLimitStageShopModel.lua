local UnityEngine = clr.UnityEngine
local Time = UnityEngine.Time
local ActivityModel = require("ui.models.activity.ActivityModel")
local TimeLimitStageShopModel = class(ActivityModel)

function TimeLimitStageShopModel:InitWithProtocol()
    self.singleData = self:GetActivitySingleData()
    self:InitStoreData(self.singleData.store)

    self.serverTime = self.singleData.serverTime
    self.lastRealTime = Time.realtimeSinceStartup
    self.subID = self.singleData.subID
end

function TimeLimitStageShopModel:InitStoreData(data)
    self.store = {}
    for i, v in pairs(data) do
        local index = tonumber(i)
        v.storeType = index
        self.store[index] = v
    end

    -- 给最后一个商店一个标记 做特殊显示
    local stageCount = #self.store
    local lastStoreData = self.store[stageCount]
    if next(lastStoreData) then
        lastStoreData.isLast = true
    end

    --商店的开启状态
    for i, v in pairs(self.store) do
        local isOpen = self:GetStoreIsOpen(i)
        v.isOpen = isOpen
    end
end

-- 最大可购买次数 不超过5
function TimeLimitStageShopModel:GetMaxBuyCount()
    local curStoreType = self:GetCurStoreType()
    local rewardData = self.store[curStoreType].reward
    local buyCount = 0
    for i, v in pairs(rewardData) do
        buyCount = buyCount + (v.rewardCount - v.buyCount)
    end
    if buyCount > 5 then
        buyCount = 5
    end
    return buyCount
end

-- 商店开启的最大层数
function TimeLimitStageShopModel:GetMaxOpenStoreType()
    local maxStoreType = 1
    for i, v in pairs(self.store) do
        local isOpen = self:GetStoreIsOpen(i)
        if isOpen and i > maxStoreType then
            maxStoreType = i
        end
    end
    return maxStoreType
end

-- 默认商店的阶层
function TimeLimitStageShopModel:GetDefaultStoreType()
    return self.curStoreType or self:GetMaxOpenStoreType()
end

-- 标题
function TimeLimitStageShopModel:GetTitle()
    return self.singleData.title or ""
end

-- 描述
function TimeLimitStageShopModel:GetDesc()
    return self.singleData.desc or ""
end

-- 刷新数据
function TimeLimitStageShopModel:RefreshDataList(data)
    for k, v in pairs(data) do
        self.singleData[k] = v
    end
end

-- 获取活动剩余时间
function TimeLimitStageShopModel:GetRemainTime()
    local endTime = tonumber(self.singleData.endTime)
    local osTime = self:GetOSTime()
    local remainTime = endTime - osTime
    if remainTime > 0 then
        return remainTime
    else
        return 0
    end
end

-- 获取活动持续时间描述
function TimeLimitStageShopModel:GetLastTime()
    local endTime = tonumber(self.singleData.endTime)
    local beginTime = tonumber(self.singleData.beginTime)
    local endStr = string.convertSecondToMonth(endTime)
    local startStr = string.convertSecondToMonth(beginTime)
    return lang.trans("time_last", startStr, endStr)
end

function TimeLimitStageShopModel:GetOSTime()
    local nowRealTime = Time.realtimeSinceStartup
    local deltaTime = math.ceil(nowRealTime - self.lastRealTime)
    local nowServerTime = self.serverTime + deltaTime
    return nowServerTime
end

function TimeLimitStageShopModel:GetCurStoreType()
    return self.curStoreType
end

function TimeLimitStageShopModel:SetCurStoreType(storeType)
    self.curStoreType = storeType
end

function TimeLimitStageShopModel:GetStoreData()
    return self.store
end

function TimeLimitStageShopModel:GetRewardData()
    local curStoreType = self:GetCurStoreType()
    local rewardData = self.store[curStoreType].reward
    local reward = {}
    for i, v in pairs(rewardData) do
        table.insert(reward, v)
    end
    table.sort(reward, function(a, b) return a.rewardType < b.rewardType end)
    return reward
end

function TimeLimitStageShopModel:GetStoreOpenTip()
    local curStoreType = self:GetCurStoreType()
    local isOpen = self:GetStoreIsOpen(curStoreType)
    local storeData = self:GetStoreData()
    local storeTypeData = storeData[curStoreType]
    local storeUnlockCount = storeTypeData.storeUnlockCount
    local totalCount = storeTypeData.totalCount
    local preStoreType = tonumber(storeUnlockCount[1])

    if isOpen then
        for i, v in pairs(storeData) do
            local unlockCount = v.storeUnlockCount
            local storeType = tonumber(unlockCount[1])
            local storeCount = tonumber(unlockCount[2])
            if storeType == curStoreType then
                local storeTypeStr = lang.transstr("number_" .. v.storeType)
                if storeCount > totalCount then
                    return lang.trans("stage_shop_tip3", storeCount - totalCount, storeTypeStr)
                else
                    return lang.trans("stage_shop_tip2", storeTypeStr)
                end
            end
        end
    else
        local preStoreTypeStr = lang.transstr("number_" .. preStoreType)
        return lang.trans("stage_shop_tip1", preStoreTypeStr)
    end
end

function TimeLimitStageShopModel:GetStoreTicketCount()
    local curStoreType = self:GetCurStoreType()
    local storedData = self.store[curStoreType]
    local storeTicketCount = storedData.storeTicketCount
    return storeTicketCount
end

function TimeLimitStageShopModel:GetStoreIsOpen(storeType)
    local storeData = self:GetStoreData()
    local storeUnlockCount = storeData[storeType].storeUnlockCount
    if type(storeUnlockCount) == "table" and next(storeUnlockCount) then
        local preStoreType = tonumber(storeUnlockCount[1])
        local preStoreCount = tonumber(storeUnlockCount[2])
        return storeData[preStoreType].totalCount >= preStoreCount
    else
        return true
    end
    return false
end

-- 拥有的阶梯卡的数量
function TimeLimitStageShopModel:GetTicketCnt()
    return self.singleData.ticketCnt
end

function TimeLimitStageShopModel:RefreshKeyCount(keyCount)
    self.singleData.ticketCnt = keyCount
end

---- 是否在活动时间内
function TimeLimitStageShopModel:IsTimeInActivity()
    if self.outOfTime then
        return false
    end
    return true
end

function TimeLimitStageShopModel:SetRunOutOfTime()
    self.outOfTime = true
end

return TimeLimitStageShopModel

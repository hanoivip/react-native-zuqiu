local Model = require("ui.models.Model")
local AuctionMainConstants = require("ui.models.auction.main.AuctionMainConstants")

local AuctionMainModel = class(Model, "AuctionMainModel")

function AuctionMainModel:ctor()
    self.cacheData = nil
    self.cacheAuctions = nil
    self.cacheHistory = nil
    self.currBtnGroup = nil
    self.auctionHallData = nil
    self.myHistoryData = nil
    self.isUpdating = false
    -- 定时刷新相关
    self.isTiming = false
    self.counter = 0
    self.interval = 0
end

function AuctionMainModel:InitWithProtocol(data, menuTag)
    self.cacheData = data
    if not menuTag then menuTag = AuctionMainConstants.AuctionHall end
    local scrollIndex = 1
    if menuTag == AuctionMainConstants.AuctionHall then
        self.cacheAuctions = data
        -- 往期未竞拍完数据
        self.auctionHallData = {}
        for periodID, auctionDatas in pairs(data.historyData) do
            for subID, auctionData in pairs(auctionDatas) do
                auctionData.scrollItemType = AuctionMainConstants.AuctionHall
                auctionData.isPast = true
                auctionData.index = tonumber(auctionData.subId) % 10
                table.insert(self.auctionHallData, auctionData)
            end
        end
        -- 当前期数据
        for subID, auctionData in pairs(data.data) do
            auctionData.scrollItemType = AuctionMainConstants.AuctionHall
            auctionData.isPast = false
            auctionData.index = tonumber(auctionData.subId) % 10
            table.insert(self.auctionHallData, auctionData)
        end
        table.sort(self.auctionHallData, function(a, b)
            if tonumber(a.id) < tonumber(b.id) then
                return true
            elseif tonumber(a.id) > tonumber(b.id) then
                return false
            elseif tonumber(a.id) == tonumber(b.id) then
                return tonumber(a.subId) < tonumber(b.subId)
            end
        end)
        scrollIndex = 1
        for k, auctionData in ipairs(self.auctionHallData) do
            auctionData.scrollIndex = scrollIndex
            scrollIndex = scrollIndex + 1
        end
    elseif menuTag == AuctionMainConstants.History then
        self.cacheHistory = data
        self.myHistoryData = {}
        for periodID, auctionDatas in pairs(data) do
            for subID, auctionData in pairs(auctionDatas) do
                auctionData.scrollItemType = AuctionMainConstants.History
                auctionData.isPast = false
                auctionData.index = tonumber(auctionData.subId) % 10
                table.insert(self.myHistoryData, auctionData)
            end
        end
        -- 竞拍中>未领取>已领取
        table.sort(self.myHistoryData, function(a, b)
            if a.step < AuctionMainConstants.AuctionStep.FINISH and b.step < AuctionMainConstants.AuctionStep.FINISH then
                -- 都在竞拍中
                if tonumber(a.id) < tonumber(b.id) then
                    return true
                elseif tonumber(a.id) > tonumber(b.id) then
                    return false
                elseif tonumber(a.id) == tonumber(b.id) then
                    return tonumber(a.subId) < tonumber(b.subId)
                end
            elseif a.step == AuctionMainConstants.AuctionStep.FINISH and b.step < AuctionMainConstants.AuctionStep.FINISH then
                return false
            elseif a.step < AuctionMainConstants.AuctionStep.FINISH and b.step == AuctionMainConstants.AuctionStep.FINISH then
                return true
            else
                -- 都完成竞拍
                if a.canGain == 0 and b.canGain == 0 then
                    -- 都已领取
                    if tonumber(a.id) < tonumber(b.id) then
                        return true
                    elseif tonumber(a.id) > tonumber(b.id) then
                        return false
                    elseif tonumber(a.id) == tonumber(b.id) then
                        return tonumber(a.subId) < tonumber(b.subId)
                    end
                elseif a.canGain == 1 and b.canGain == 0 then
                    return true
                elseif a.canGain == 0 and b.canGain == 1 then
                    return false
                else
                    -- 都未领取
                    if tonumber(a.id) < tonumber(b.id) then
                        return true
                    elseif tonumber(a.id) > tonumber(b.id) then
                        return false
                    elseif tonumber(a.id) == tonumber(b.id) then
                        return tonumber(a.subId) < tonumber(b.subId)
                    end
                end
            end
        end)
        scrollIndex = 1
        for k, auctionData in ipairs(self.myHistoryData) do
            auctionData.scrollIndex = scrollIndex
            scrollIndex = scrollIndex + 1
        end
    end
end

function AuctionMainModel:UpdateAfterReceive(scrollIndex)
    self.myHistoryData[scrollIndex].canGain = 0
end

function AuctionMainModel:GetCacheData()
    return self.cacheData
end

function AuctionMainModel:SetStatusData(statusData)
    self:SetCurrBtnGroup(statusData)
end

function AuctionMainModel:GetStatusData()
    return self:GetCurrBtnGroup()
end

function AuctionMainModel:SetCurrBtnGroup(tag)
    if not tag then
        self.currBtnGroup = AuctionMainConstants.AuctionHall
    else
        self.currBtnGroup = tag
    end
end

function AuctionMainModel:GetCurrBtnGroup()
    return self.currBtnGroup
end

function AuctionMainModel:GetCurrPeriod()
    if self.cacheAuctions then
        return self.cacheAuctions.curPeriod
    else
        return 0
    end
end

function AuctionMainModel:GetAuctionHallData()
    return self.auctionHallData or {}
end

function AuctionMainModel:GetMyHistoryData()
    return self.myHistoryData or {}
end

function AuctionMainModel:GetNextStartTime()
    if self.cacheAuctions then
        return self.cacheAuctions.nextStartTime
    else
        return 0
    end
end

function AuctionMainModel:IsOpen()
    return table.nums(self.auctionHallData or {}) > 0
end

function AuctionMainModel:GetIsUpdating()
    return self.isUpdating
end

function AuctionMainModel:SetIsUpdating(value)
    self.isUpdating = value
end

-- 定时刷新功能相关
function AuctionMainModel:StartTiming()
    self.isTiming = true
end

function AuctionMainModel:StopTiming()
    self.isTiming = false
end

function AuctionMainModel:IsTiming()
    return self.isTiming and self.interval > 0
end

function AuctionMainModel:GetTimingCounter()
    return self.counter
end

function AuctionMainModel:SetTimingInterval(interval)
    self.interval = interval
end

function AuctionMainModel:UpdateTimingCounter(deltaTime)
    self.counter = self.counter - deltaTime
end

function AuctionMainModel:ResetTimingCounter()
    self.counter = self.interval
end

return AuctionMainModel
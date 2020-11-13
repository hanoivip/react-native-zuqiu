local ActivityModel = require("ui.models.activity.ActivityModel")
local LuckyWheelModelEx = class(ActivityModel)

function LuckyWheelModelEx:ctor(data)
    LuckyWheelModelEx.super.ctor(self, data)
    self:InitWheelItemsData()
    self:SetPointRewardList()

    -- 跳过动画
    self.isSkipAnim = true
end

function LuckyWheelModelEx:GetPeriodID()
    return self:GetActivitySingleData().ID
end

--- 获取活动开始时间
function LuckyWheelModelEx:GetStartTime()
    local singleData = self:GetActivitySingleData()
    return singleData.beginTime
end

--- 获取活动结束时间
function LuckyWheelModelEx:GetEndTime()
    local singleData = self:GetActivitySingleData()
    return singleData.endTime
end

function LuckyWheelModelEx:GetOneIndianaCost()
    local singleData = self:GetActivitySingleData()
    return singleData.oneGachaPrice
end

function LuckyWheelModelEx:GetMoreIndianaCost()
    local singleData = self:GetActivitySingleData()
    return singleData.fiveGachaPrice
end

function LuckyWheelModelEx:SetCurrentRewardIds(gachaRewardIDs)
    self.gachaRewardIDs = gachaRewardIDs
    EventSystem.SendEvent("LuckyWheelModelEx_SetCurrentReward")
end

function LuckyWheelModelEx:GetCurrentRewardIds()
    return self.gachaRewardIDs or {}
end

function LuckyWheelModelEx:GetOpenCount()
    local singleData = self:GetActivitySingleData()
    return singleData.gachaCount
end

function LuckyWheelModelEx:SetOpenCount(gachaCount)
    local singleData = self:GetActivitySingleData()
    singleData.gachaCount = gachaCount
    self:UpdateRewardList(gachaCount)
    EventSystem.SendEvent("LuckyWheelModelEx_ResetOpenCount")
end

function LuckyWheelModelEx:GetRewardIndex(count)
    local key = self.gachaRewardIDs[count]
    local sortData = self:GetWheelItemsData()
    local itemIndex
    for i, v in ipairs(sortData) do
        if tonumber(v.key) == tonumber(key) then
            itemIndex = i
            break 
        end
    end
    return itemIndex
end

function LuckyWheelModelEx:InitWheelItemsData()
    local singleData = self:GetActivitySingleData()
    self.sortData = {}
    for k, v in pairs(singleData.gacha) do
        local data = v
        data.key = k
        table.insert(self.sortData, data)
    end
    table.sort(self.sortData, function(a, b) return tonumber(a.key) < tonumber(b.key) end)
end

function LuckyWheelModelEx:GetWheelItemsData()
    return self.sortData
end

function LuckyWheelModelEx:GetWheelItemsIndex(key)
    for i, v in ipairs(self.sortData) do
        if tostring(v.key) == tostring(key) then 
            return i
        end
    end
    return 0
end

function LuckyWheelModelEx:UpdateRewardList(gachaCount)
    for i, v in ipairs(self.pointRewardList) do
        if v.condition <= gachaCount and v.status == -1 then
            v.status = 0
        end
    end
    EventSystem.SendEvent("TimeLimitExplore.UpdatePointRewardInfo")
end

function LuckyWheelModelEx:SetPointRewardList()
    self.pointRewardList = {}
    local pointRewards = self:GetActivitySingleData().chestReward or {}
    for k, v in pairs(pointRewards) do
        table.insert(self.pointRewardList, v)
    end
    table.sort(self.pointRewardList, function(a, b) return a.condition < b.condition end)
end

function LuckyWheelModelEx:GetPointRewardList()
    return self.pointRewardList
end

function LuckyWheelModelEx:UpdatePointRewardInfo(rewardId)
    for i, v in ipairs(self.pointRewardList) do
        if v.subID == rewardId and v.status == 0 then
            v.status = 1
        end
    end
    EventSystem.SendEvent("TimeLimitExplore.UpdatePointRewardInfo")
end

-- 是否跳过动画
function LuckyWheelModelEx:SetIsSkipAnim(flag)
    self.isSkipAnim = flag
end

function LuckyWheelModelEx:GetIsSkipAnim()
    return self.isSkipAnim
end

return LuckyWheelModelEx

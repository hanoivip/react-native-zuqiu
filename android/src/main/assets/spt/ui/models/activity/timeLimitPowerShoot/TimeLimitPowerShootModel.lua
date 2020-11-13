local UnityEngine = clr.UnityEngine
local Time = UnityEngine.Time
local ActivityModel = require("ui.models.activity.ActivityModel")
local TimeLimitPowerShootModel = class(ActivityModel)

-- 格子数量 固定10个
TimeLimitPowerShootModel.Max_Count = 10

function TimeLimitPowerShootModel:InitWithProtocol()
    self.singleData = self:GetActivitySingleData()
    self.serverTime = self.singleData.serverTime
    self.lastRealTime = Time.realtimeSinceStartup
    self.subID = self.singleData.subID
end

-- 标题
function TimeLimitPowerShootModel:GetTitle()
    return self.singleData.title or ""
end

-- 描述
function TimeLimitPowerShootModel:GetDesc()
    return self.singleData.desc or ""
end

-- 价格描述
function TimeLimitPowerShootModel:GetPriceTips()
    return self.singleData.desc1 or ""
end

-- 格子数据
function TimeLimitPowerShootModel:GetContents()
    local contentData = {}
    for i = 1, self.Max_Count do
        local t = {}
        local cData = self:GetContentData(i)
        t.content = cData
        t.pos = i
        table.insert(contentData, t)
    end
    return contentData
end

-- 每个格子 是否打开
function TimeLimitPowerShootModel:GetContentState(index)
    if self.singleData.shootFlag == 0 then
        return true
    end
    local shootData = self.singleData.powerShootList[index]
    return tobool(shootData)
end

-- 每个格子的数据
function TimeLimitPowerShootModel:GetContentData(index)
    local rewardId
    if self.singleData.shootFlag == 0 then
        rewardId = self.singleData.powerShootRewardList[index]
    else
        local powerShootList = self.singleData.powerShootList or {}
        rewardId = powerShootList[tostring(index)]
    end
    return self:GetRewardByRewardId(rewardId)
end

-- 根据id获取奖池的奖励数据
function TimeLimitPowerShootModel:GetRewardByRewardId(rewardId)
    if rewardId then
        return self.singleData.rewardList[tostring(rewardId )] or false
    end
end

-- 刷新数据
function TimeLimitPowerShootModel:RefreshDataList(data)
    for k, v in pairs(data) do
        self.singleData[k] = v
    end
end

-- 购买次数价格
function TimeLimitPowerShootModel:GetCountPrice()
    local shootTimes = self:GetBuyCount() + 1
    return self.singleData.purchasePrice[shootTimes] or 0
end

-- 刷新价格
function TimeLimitPowerShootModel:GetRefreshPrice()
    return self.singleData.refreshPrice
end

-- 购买次数
function TimeLimitPowerShootModel:GetBuyCount()
    local shootTimes = self.singleData.shootTimes
    return shootTimes
end

-- 奖励预览
function TimeLimitPowerShootModel:GetRewardBonds()
    local bonds = {}
    local allRewards = self.singleData.rewardList
    for k, v in pairs(allRewards) do
        v.id = k
        v.quality = tonumber(v.quality)
        local quality = v.quality
        if not bonds[quality] then
            bonds[quality] = {}
        end
        bonds[quality].quality = quality
        table.insert(bonds[quality], v)
    end
    dump(bonds, "bondsbondsbonds")
    table.sort(bonds, function(a, b)
        return a.quality > b.quality
    end)
    return bonds
end

function TimeLimitPowerShootModel:GetShootFlag()
    return self.singleData.shootFlag
end

-- 获取活动剩余时间
function TimeLimitPowerShootModel:GetRemainTime()
    local endTime = tonumber(self.singleData.endTime)
    local osTime = self:GetOSTime()
    local remainTime = endTime - osTime
    if remainTime > 0 then
        return remainTime
    else
        return 0
    end
end

function TimeLimitPowerShootModel:GetOSTime()
    local nowRealTime = Time.realtimeSinceStartup
    local deltaTime = math.ceil(nowRealTime - self.lastRealTime)
    local nowServerTime = self.serverTime + deltaTime
    return nowServerTime
end

function TimeLimitPowerShootModel:GetSubID()
    return self.subID
end

---- 是否在活动时间内
function TimeLimitPowerShootModel:IsTimeInActivity()
    if self.outOfTime then
        return false
    end
    return true
end

function TimeLimitPowerShootModel:SetRunOutOfTime()
    self.outOfTime = true
end

return TimeLimitPowerShootModel

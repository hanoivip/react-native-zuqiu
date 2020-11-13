local Model = require("ui.models.Model")
local AdventureBase = require("data.AdventureBase")

local GreenswardMoraleSupplyModel = class(Model, "GreenswardMoraleSupplyModel")

-- 我领取的状态
GreenswardMoraleSupplyModel.RcvStu = {
    NotRcv = -1, -- 好友未赠送
    Rcved = 0 --已领取
    -- CanRcv = 1 -- 大于0表示可领取
}

-- 我赠送的状态
GreenswardMoraleSupplyModel.SendStu = {
    NotSent = 0, -- 今日未赠送
    Sent = 1 -- 今日已赠送
}

function GreenswardMoraleSupplyModel:ctor(greenswardBuildModel)
    GreenswardMoraleSupplyModel.super.ctor(self)
    self.greenswardBuildModel = greenswardBuildModel
    self.limitTimes = tonumber(AdventureBase["1"].friendMoraleCount) -- 每日领取上限
    self.singleMorale = tonumber(AdventureBase["1"].friendMorale) -- 每单人次赠送数量
    self.leftTimes = 0 -- 剩余可领取的次数
    self.friendList = nil
end

function GreenswardMoraleSupplyModel:InitWithProtocol(cacheData)
    self.cacheList = cacheData.list or {}
    self.friendList = {}
    self.leftTimes = cacheData.count
    for pid, data in pairs(self.cacheList) do
        data.pid = tostring(pid)
        data.advRcv = tonumber(data.advRcv)
        data.advSend = tonumber(data.advSend)
        table.insert(self.friendList, data)
    end
    table.sort(self.friendList, function(a, b)
        return a.pid < b.pid
    end)
    for k, v in ipairs(self.friendList) do
        v.idx = tonumber(k)
    end
end

function GreenswardMoraleSupplyModel:GetFriendList()
    return self.friendList
end

-- 获得每单人次赠送数量
function GreenswardMoraleSupplyModel:GetSingleMorale()
    return self.singleMorale or 0
end

-- 获得剩余次数
function GreenswardMoraleSupplyModel:GetLeftTimes()
    return self.leftTimes
end

-- 获得总数
function GreenswardMoraleSupplyModel:GetLimitTimes()
    return self.limitTimes or 0
end

-- 士气上限
function GreenswardMoraleSupplyModel:IsMoraleLimit()
    local greenswardBuildModel = self:GetGreenswardBuildModel()
    local moraleNum = greenswardBuildModel:GetMoraleNum()
    local moraleLimit = AdventureBase["1"].moraleLimit
    return moraleNum >= moraleLimit
end

-- 状态判断，未领取
function GreenswardMoraleSupplyModel:IsNotReceive(advRcv)
    return advRcv > 0
end

-- 状态判断，好友未赠送
function GreenswardMoraleSupplyModel:IsNotRcv(advRcv)
    return advRcv == GreenswardMoraleSupplyModel.RcvStu.NotRcv
end

-- 状态判断，未赠送
function GreenswardMoraleSupplyModel:IsNotSend(advSend)
    return advSend == self.SendStu.NotSent
end

-- 是否有未领取的好友
function GreenswardMoraleSupplyModel:HasNotReceived()
    local flag = false
    for k, itemData in pairs(self.friendList) do
        if self:IsNotReceive(itemData.advRcv) then
            flag = true
            break
        end
    end
    return flag
end

-- 是否有未赠送的好友
function GreenswardMoraleSupplyModel:HasNotSend()
    local flag = false
    for k, itemData in pairs(self.friendList) do
        if self:IsNotSend(itemData.advSend) then
            flag = true
            break
        end
    end
    return flag
end

-- 一键领取后更新
function GreenswardMoraleSupplyModel:UpdateAfterGetBatch(data)
    local contents = data.contents
    local greenswardBuildModel = self:GetGreenswardBuildModel()
    greenswardBuildModel:RewardDetail(contents)
    self:InitWithProtocol(data)
end

-- 一键赠送后更新
function GreenswardMoraleSupplyModel:UpdateAfterSendBatch(data)
    self:InitWithProtocol(data)
end

function GreenswardMoraleSupplyModel:GetGreenswardBuildModel()
    return self.greenswardBuildModel
end

return GreenswardMoraleSupplyModel

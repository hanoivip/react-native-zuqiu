local UnityEngine = clr.UnityEngine
local Time = UnityEngine.Time
local ActivityModel = require("ui.models.activity.ActivityModel")
local DialogManager = require("ui.control.manager.DialogManager")
local MultiGetGiftModel = class(ActivityModel, "MarblesModel")
local MultiGetGiftTaskItemModel = require("ui.models.activity.multiGetGift.MultiGetGiftTaskItemModel")

function MultiGetGiftModel:ctor(data)
    MultiGetGiftModel.super.ctor(self, data)
end

function MultiGetGiftModel:InitWithProtocol()
    if table.isEmpty(self.singleData) then return end
    self.requestTime = Time.realtimeSinceStartup
end

-- 获取积分
function MultiGetGiftModel:GetScore()
    local score = self.singleData.score
    return score
end

-- 获取任选币
function MultiGetGiftModel:GetCoin()
    local coin = self.singleData.coin
    return coin
end

-- 获取每日奖励列表
function MultiGetGiftModel:GetDayRewardList()
    local giftList = self.singleData.giftList
    local gList = {}
    for i, v in pairs(giftList) do
        v.showIndex = i
        table.insert(gList, v)
    end
    table.sort(gList, function(a, b)
        return a.score < b.score
    end)
    return gList
end

-- 获取每日任务列表
function MultiGetGiftModel:GetTaskModelList()
    local taskList = self.singleData.taskList
    local tList = {}
    for i, v in pairs(taskList) do
        v.showIndex = i
        local m = MultiGetGiftTaskItemModel.new(v, self)
        table.insert(tList, m)
    end
    table.sort(tList, function(a, b)
        local aState = a:GetState()
        local bState = b:GetState()
        local ida = a:GetTaskId()
        local idb = b:GetTaskId()
        if aState == 0 then
            aState = -2
        end
        if bState == 0 then
            bState = -2
        end
        if aState == bState then
            return ida < idb
        end
        return aState < bState
    end)
    return tList
end

-- 获取商店列表
function MultiGetGiftModel:GetStoreList()
    local storeList = self.singleData.mallList
    local sList = {}
    for i, v in pairs(storeList) do
        v.showIndex = i
        table.insert(sList, v)
    end
    table.sort(sList, function(a, b)
        return a.subID < b.subID
    end)
    return sList
end

-- 刷新每日奖励
function MultiGetGiftModel:RefreshGiftData(data)
    self.singleData.coin = self.singleData.coin + data.coin
    local giftId = tostring(data.giftId)
    self.singleData.giftList[giftId].receive = data.receive
end

-- 刷新每日奖励
function MultiGetGiftModel:RefreshTaskData(data)
    self.singleData.coin = self.singleData.coin + data.coinReward
    self.singleData.score = self.singleData.score + data.scoreReward
    local taskId = tostring(data.taskId)
    self.singleData.taskList[taskId].progress = data.taskInfo.progress
    self.singleData.taskList[taskId].state = data.taskInfo.state
end

-- 刷新多个每日奖励
function MultiGetGiftModel:RefreshAllRewardData(data)
    self.singleData.coin = self.singleData.coin + data.coin
    for i, v in pairs(data.giftInfo) do
        local id = tostring(i)
        self.singleData.giftList[id].receive = v
    end
end

-- 刷新商店
function MultiGetGiftModel:RefreshStoreData(data)
    local itemId = tostring(data.itemId)
    self.singleData.mallList[itemId].buyCnt = data.buyCnt
    self.singleData.coin = self.singleData.coin - data.needCoin
end

-- 每日奖励红点
function MultiGetGiftModel:GetGiftRedPoint()
    local nowTime = self:GetNowTime()
    local score = self:GetScore()
    for i, giftData in pairs(self.singleData.giftList) do
        if giftData.receive ~= 1 then
            local scoreLimit = giftData.score
            if giftData.beginTime <= nowTime and score >= scoreLimit then
                return true
            end
        end
    end
    return false
end

-- 每日任务红点
function MultiGetGiftModel:GetTaskRedPoint()
    for i, v in pairs(self.singleData.taskList) do
        if v.state == 0 then
            return true
        end
    end
    return false
end

-- 获取活动类型
function MultiGetGiftModel:GetActivityType()
    return self.singleData.activityType
end

-- 获取活动期数
function MultiGetGiftModel:GetPeriodId()
    return self.singleData.id
end

-- 获取活动开始时间
function MultiGetGiftModel:GetBeginTime()
    return self.singleData.beginTime
end

-- 获取活动结束时间
function MultiGetGiftModel:GetEndTime()
    return self.singleData.endTime
end

-- 获取活动展示结束时间
function MultiGetGiftModel:GetShowEndTime()
    return self.singleData.activityEndTime
end

-- 获取活动剩余时间
function MultiGetGiftModel:GetShowRemainTime()
    local nowTime = self:GetNowTime()
    local endTime = self:GetShowEndTime()
    local remainTime = endTime - nowTime
    if remainTime < 0 then
        remainTime = 0
    end
    return remainTime
end

-- 获取活动剩余时间
function MultiGetGiftModel:GetRemainTime()
    local nowTime = self:GetNowTime()
    local endTime = self:GetEndTime()
    local remainTime = endTime - nowTime
    if remainTime < 0 then
        remainTime = 0
    end
    return remainTime
end

-- 获取当前时间
function MultiGetGiftModel:GetNowTime()
    local serverTime = self.singleData.serverTime
    local realtimeSinceStartup = Time.realtimeSinceStartup
    local nowTime = serverTime + realtimeSinceStartup - self.requestTime
    return nowTime
end

-- 获得玩法说明
function MultiGetGiftModel:GetIntro()
    return 21, "TimeLimitMultiGetGift"
end

function MultiGetGiftModel:SetRunOutOfTime()
    self.outOfTime = true
end

-- 是否在活动时间内
function MultiGetGiftModel:IsTimeInActivity()
    local remainTime = self:GetRemainTime()
    if remainTime < 1 then
        DialogManager.ShowToastByLang("visit_endInfo")
        return false
    end
    return true
end

return MultiGetGiftModel

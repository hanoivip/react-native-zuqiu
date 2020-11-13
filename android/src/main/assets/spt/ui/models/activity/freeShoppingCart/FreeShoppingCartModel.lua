local UnityEngine = clr.UnityEngine
local Time = UnityEngine.Time
local ActivityModel = require("ui.models.activity.ActivityModel")
local DialogManager = require("ui.control.manager.DialogManager")
local CartStateType = require("ui.models.activity.freeShoppingCart.CartStateType")
local FreeShoppingCartModel = class(ActivityModel, "MarblesModel")

function FreeShoppingCartModel:ctor(data)
    FreeShoppingCartModel.super.ctor(self, data)
end

function FreeShoppingCartModel:InitWithProtocol()
    if table.isEmpty(self.singleData) then return end
    self.requestTime = Time.realtimeSinceStartup
end

-- 今日免费奖励是否已经领取
function FreeShoppingCartModel:GetFreeReceive()
    return self.singleData.freeReceive
end

-- 今日免费奖励的内容
function FreeShoppingCartModel:GetFreeContents()
    return self.singleData.freeContents
end

-- 六天奖励的信息
function FreeShoppingCartModel:GetDayChooseData()
    local dayChooseData = {}
    local chooseReward = self.singleData.chooseReward
    for i, v in pairs(chooseReward) do
        local chooseRewardGroupID = v.chooseRewardGroupID
        if not dayChooseData[chooseRewardGroupID] then
            dayChooseData[chooseRewardGroupID] = {}
        end
        table.insert(dayChooseData[chooseRewardGroupID], v)
    end
    return dayChooseData
end

-- 每个格子的状态信息
function FreeShoppingCartModel:GetGroupState()
    local dayChooseData = self:GetDayChooseData()
    local chooseList = self:GetChooseList()
    local nowTime = self:GetNowTime()
    local groupState = {}
    for i, v in ipairs(dayChooseData) do
        local groupID = i
        local key, gfData = next(v)
        local chooseRewardBeginTime = gfData.chooseRewardBeginTime
        local chooseRewardEndTime = gfData.chooseRewardEndTime
        for index, value in ipairs(v) do
            local rewardID = value.chooseRewardID
            if chooseList[rewardID] then
                if chooseRewardBeginTime < nowTime and chooseRewardEndTime > nowTime then
                    groupState[groupID] = CartStateType.TodaySelected
                else
                    groupState[groupID] = CartStateType.Selected
                end
                break
            end
        end
        if not groupState[groupID] then
            if chooseRewardBeginTime > nowTime then
                groupState[groupID] = CartStateType.Disable
            elseif chooseRewardBeginTime < nowTime and chooseRewardEndTime > nowTime then
                groupState[groupID] = CartStateType.CanSelect
            elseif chooseRewardEndTime < nowTime then
                groupState[groupID] = CartStateType.Miss
            end
        end
    end
    return groupState
end

-- 已经选择的奖励
function FreeShoppingCartModel:GetChooseList()
    local chooseList = {}
    local chooseReward = self.singleData.chooseReward
    for i, v in ipairs(self.singleData.chooseList) do
        chooseList[v] = chooseReward[tostring(v)]
    end
    return chooseList
end

-- 是否有已选择的奖励
function FreeShoppingCartModel:IsChooseReward()
    local chooseList = self.singleData.chooseList
    return tobool(next(chooseList))
end

-- 每天已选择奖励的详细信息
function FreeShoppingCartModel:GetGroupChooseList()
    local groupChooseList = {}
    local chooseReward = self.singleData.chooseReward
    for i, v in ipairs(self.singleData.chooseList) do
        local groupData = chooseReward[tostring(v)]
        local groupID = groupData.chooseRewardGroupID
        groupChooseList[groupID] = groupData
    end
    return groupChooseList
end

-- 购物车图片索引=当前选择的物品个数
function FreeShoppingCartModel:GetChooseListCount()
    local chooseList = self.singleData.chooseList
    local count = table.nums(chooseList)
    return count
end

-- 领取奖励的时间
function FreeShoppingCartModel:GetReceiveDayTime()
    local receiveDayTime  = self.singleData.receiveDayTime
    return receiveDayTime
end

-- 是否是可领取奖励的时间
function FreeShoppingCartModel:IsReceiveDay()
    local receiveDayTime  = self.singleData.receiveDayTime
    local nowTime = self:GetNowTime()
    return receiveDayTime < nowTime
end

-- 是否领取周一奖励
function FreeShoppingCartModel:GetReceive()
    local receive  = self.singleData.receive
    return receive
end

-- 期数
function FreeShoppingCartModel:GetPeriodId()
    return self.singleData.id
end

-- 获取活动类型
function FreeShoppingCartModel:GetActivityType()
    return self.singleData.activityType
end

-- 获取活动开始时间
function FreeShoppingCartModel:GetBeginTime()
    return self.singleData.beginTime
end

-- 获取活动结束时间
function FreeShoppingCartModel:GetEndTime()
    return self.singleData.endTime
end

-- 获取活动剩余时间
function FreeShoppingCartModel:GetRemainTime()
    local nowTime = self:GetNowTime()
    local endTime = self:GetEndTime()
    local remainTime = endTime - nowTime
    if remainTime < 0 then
        remainTime = 0
    end
    return remainTime
end

-- 获取当前时间
function FreeShoppingCartModel:GetNowTime()
    local serverTime = self.singleData.serverTime
    local realtimeSinceStartup = Time.realtimeSinceStartup
    local nowTime = serverTime + realtimeSinceStartup - self.requestTime
    return nowTime
end

-- 获得玩法说明
function FreeShoppingCartModel:GetIntro()
    return 20, "TimeLimitFreeShoppingCart"
end

function FreeShoppingCartModel:SetRunOutOfTime()
    self.outOfTime = true
end

function FreeShoppingCartModel:SetReceiveDayRewardInfo(dayRewardInfo)
    self.singleData.freeReceive = true
end

function FreeShoppingCartModel:SetChooseRewardInfo(chooseRewardInfo)
    if not self.singleData.chooseList then
        self.singleData.chooseList = {}
    end
    table.insert(self.singleData.chooseList, chooseRewardInfo.rewardId)
end

function FreeShoppingCartModel:SetFreeRewardInfo(freeRewardInfo)
    self.singleData.receive = true
end

-- 是否在活动时间内
function FreeShoppingCartModel:IsTimeInActivity()
    local remainTime = self:GetRemainTime()
    if remainTime < 1 then
        DialogManager.ShowToastByLang("visit_endInfo")
        return false
    end
    return true
end

return FreeShoppingCartModel

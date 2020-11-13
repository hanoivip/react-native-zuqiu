local UnityEngine = clr.UnityEngine
local Time = UnityEngine.Time
local ActivityModel = require("ui.models.activity.ActivityModel")
local MarblesExchangeItem = require("data.MarblesExchangeItem")
local DialogManager = require("ui.control.manager.DialogManager")
local MarblesModel = class(ActivityModel, "MarblesModel")

function MarblesModel:ctor(data)
    MarblesModel.super.ctor(self, data)
end

function MarblesModel:InitWithProtocol()
    if table.isEmpty(self.singleData) then return end
    self.requestTime = Time.realtimeSinceStartup
    self:InitTimesBallCount()
end

-- 添加球按钮上写的消耗球的数量和添加的球的个数
-- 转换一下格式 次数少的写上面 次数多的写下面
function MarblesModel:InitTimesBallCount()
    local timesBallCount = self.singleData.timesBallCount
    self.countList = {}
    for k, v in pairs(timesBallCount) do
        local t = {}
        t.count = tonumber(k)
        t.ballNum = tonumber(v)
        table.insert(self.countList, t)
    end
    table.sort(self.countList, function(a, b)
        return a.count < b.count
    end)
end

-- 添加球按钮上写的消耗球的数量和添加的球的个数
function MarblesModel:GetTimesBallCount()
    return self.countList
end

-- 当前拥有的发射次数（右上角）
function MarblesModel:GetBallCnt()
    return self.singleData.ballCnt or 0
end

-- 当前拥有的发射次数（右上角）
function MarblesModel:SetBallCnt(ballCnt)
    self.singleData.ballCnt = ballCnt
end

-- 已经掉入发射机中的球的个数
function MarblesModel:GetSelectShootCount()
    return self.singleData.selectShootCount or 0
end

-- 随机隐藏的障碍物
function MarblesModel:GetHideMapPosInfo()
    return self.singleData.hideMapPosInfo or {}
end

-- 期数
function MarblesModel:GetPeriodId()
    return self.singleData.id
end

-- 当前拥有的兑换道具的数量
function MarblesModel:SetOwnItemOrigin(items)
    self.singleData.items = items
end

-- 当前拥有的兑换道具的数量
function MarblesModel:GetOwnItemOrigin()
    return self.singleData.items
end

-- 当前拥有的兑换道具的数量 排序
function MarblesModel:GetOwnItem()
    local items = self:GetOwnItemOrigin()
    local itemList = {}
    for k, v in pairs(items) do
        local itemData = clone(MarblesExchangeItem[k])
        itemData.ownCount = v
        table.insert(itemList, itemData)
    end
    table.sort(itemList, function(a, b) return a.baseID > b.baseID end)
    return itemList
end

-- 下方随机奖励格子中的奖励
function MarblesModel:GetRandItemList()
    return self.singleData.randItemList or {}
end

-- 下方随机奖励格子中的奖励
function MarblesModel:GetBallPrice()
    return self.singleData.ballDiamondPrice or 0
end

-- 获取活动类型
function MarblesModel:GetActivityType()
    return self.singleData.activityType
end

-- 获取活动开始时间
function MarblesModel:GetBeginTime()
    return self.singleData.beginTime
end

-- 获取活动结束时间
function MarblesModel:GetEndTime()
    return self.singleData.endTime
end

-- 获取活动剩余时间
function MarblesModel:GetRemainTime()
    local serverTime = self.singleData.serverTime
    local realtimeSinceStartup = Time.realtimeSinceStartup
    local nowTime = serverTime + realtimeSinceStartup - self.requestTime
    local endTime = self:GetEndTime()
    local remainTime = endTime - nowTime
    if remainTime < 0 then
        remainTime = 0
    end
    return remainTime
end

-- 获得玩法说明
function MarblesModel:GetIntro()
    return 18, "TimeLimitMarbles"
end

-- 刷新次数 球的数量 障碍物的隐藏
function MarblesModel:SetShootInfo(shootInfoData)
    for k, v in pairs(shootInfoData) do
        self.singleData[k] = v
    end
end

function MarblesModel:SetRunOutOfTime()
    self.outOfTime = true
end

function MarblesModel:SetRunOutOfTime()
    self.outOfTime = true
end

---- 是否在活动时间内
function MarblesModel:IsTimeInActivity()
    if self.outOfTime then
        DialogManager.ShowToastByLang("visit_endInfo")
        return false
    end
    return true
end

return MarblesModel

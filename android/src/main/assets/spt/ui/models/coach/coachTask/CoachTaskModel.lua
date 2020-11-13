local UnityEngine = clr.UnityEngine
local Time = UnityEngine.Time
local VIP = require("data.VIP")
local CoachMissionDetail = require("data.CoachMissionDetail")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CoachMainModel = require("ui.models.coach.CoachMainModel")
local CoachTaskState = require("ui.scene.coach.coachTask.CoachTaskState")
local CoachTaskHelper = require("ui.scene.coach.coachTask.CoachTaskHelper")
local Model = require("ui.models.Model")

local CoachTaskModel = class(Model, "CoachTaskModel")

function CoachTaskModel:ctor()
    self.super.ctor(self)
    self.coachMainModel = CoachMainModel.new()
end

function CoachTaskModel:Init(data)
    if data then
        self.data = data
    end
    self.playerInfoModel = PlayerInfoModel.new()
end

function CoachTaskModel:InitWithProtocol(data)
    self:Init(data)
    self.serverTime = data.serverTime
    self.lastRealTime = Time.realtimeSinceStartup
end

-- 可接受的任务列表
function CoachTaskModel:GetTaskList()
    local sortAList = {}
    for k,v in pairs(self.data.alist) do
        table.insert(sortAList, v)
    end
    table.sort(sortAList, function(a, b) return a.id > b.id end)
    return sortAList
end

-- 进行中的任务列表
function CoachTaskModel:GetExecutingTaskList()
    local sortDList = {}
    for k,v in pairs(self.data.dlist) do
        table.insert(sortDList, v)
    end

    table.sort(sortDList, function(a, b)
        if a.state == CoachTaskState.Reward and a.state == b.state then
            return a.bt > b.bt
        elseif b.state == CoachTaskState.Reward then
            return false
        elseif a.state == CoachTaskState.Reward then
            return true
        else
            return a.bt > b.bt
        end
    end)
    return sortDList
end

function CoachTaskModel:RefreshTaskData(data)
    local aTaskData = data.ai
    local aTaskId = aTaskData.id
    for k,v in pairs(self.data.alist) do
        if aTaskId == v.id then
            self.data.alist[k] = aTaskData
            break
        end
    end
    local taskId = tostring(data.di.id)
    self.data.dlist[taskId] = data.di
    for k,v in pairs(data.clist) do
        self.data.clist[k] = v
    end
    self.data.acnt = data.acnt
    self:SetCardsLockData(data.cardinfo)
end

function CoachTaskModel:GetCoachLevel()
    local level = self.coachMainModel:GetCredentialLevel()
    return level
end

function CoachTaskModel:GetStarLevel()
    local starLevel = self.coachMainModel:GetStarLevel()
    return starLevel
end

-- 已经在任务进行中的球员
function CoachTaskModel:GetTaskCardInfo()
    return self.data.clist or {}
end

function CoachTaskModel:GetTotalTime(cond)
    local totalTime = 0
    for i,v in ipairs(cond) do
        local index = tostring(v)
        totalTime = totalTime + CoachMissionDetail[index].missionTime
    end
    totalTime = totalTime * 60
    return totalTime
end

-- 刷新任务后 刷新任务数据
function CoachTaskModel:RefreshTaskList(data)
    for k,v in pairs(data) do
        self.data[k] = v
    end
end

-- 领取任务奖励后 刷新任务数据
function CoachTaskModel:RefreshRewardData(data)
    local di = data.di
    local taskId = tostring(di.id)
    self.data.dlist[taskId] = di
    self:SetCardsLockData(data.cardinfo)
end

-- 一键领取任务奖励后 刷新任务数据
function CoachTaskModel:RefreshRedeemAllData(data)
    for i,v in ipairs(data.rl) do
        local taskId = tostring(v.id)
        self.data.dlist[taskId] = v
    end
    self:SetCardsLockData(data.cardinfo)
end

-- 购买钥匙后 刷新数据
function CoachTaskModel:RefreshBuyCount(data)
    self.data.bcnt = data.bcnt
end


-- 今日刷新次数
function CoachTaskModel:GetRefreshCount()
    return self.data.rcnt
end

-- 今日购买次数
function CoachTaskModel:GetBuyCount()
    return self.data.bcnt
end

-- 今日接收任务次数
function CoachTaskModel:GetAcceptCount()
    return self.data.acnt
end

-- 最大购买次数  数量
function CoachTaskModel:GetMaxPurchaseCount()
    return #CoachTaskHelper.CoachMissionConfig.purchasePrice
end

-- 购买的次数的价格
function CoachTaskModel:GetPurchasePrice(index)
    return CoachTaskHelper.CoachMissionConfig.purchasePrice[index]
end

-- 刷新价格
function CoachTaskModel:GetFreshPrice()
    return CoachTaskHelper.CoachMissionConfig.freshPrice
end

-- 免费刷新次数
function CoachTaskModel:GetFreshAmount()
    return CoachTaskHelper.CoachMissionConfig.freshAmount
end

-- 任务完成次数的免费数量 
function CoachTaskModel:GetBaseDailyMission()
    return CoachTaskHelper.CoachMissionConfig.baseDailyMission
end

-- 单日最大任务
function CoachTaskModel:GetMaxDailyMission()
    return CoachTaskHelper.CoachMissionConfig.maxDailyMission
end

-- 当前最大任务数量限制 = 购买的次数 + 本身免费的次数
function CoachTaskModel:GetCurrentMaxDailyMission()
    local buyCount = self:GetBuyCount()
    local baseDailyMission = self:GetBaseDailyMission()
    return buyCount + baseDailyMission
end

-- VIP执行中最大任务限制
function CoachTaskModel:GetMaxCoachMission()
    local vipLevelData = self:GetVipLevelData()
    return vipLevelData.maxCoachMission
end

-- 是否有免费刷新次数
function CoachTaskModel:IsNeedDiamond()
    local freshAmount = self:GetFreshAmount()
    local refreshCount = self:GetRefreshCount()
    return freshAmount <= refreshCount 
end

-- 当前正在执行的任务个数（执行中 和 未领奖 都算）
function CoachTaskModel:GetExecutingAndRewardCount()
    local count = 0
    for k,v in pairs(self.data.dlist) do
        if v.state == CoachTaskState.Executing or v.state == CoachTaskState.Reward then
            count = count + 1
        end
    end
    return count
end

-- 设置球员卡 的锁
function CoachTaskModel:SetCardsLockData(cardinfo)
    if not cardinfo then return end
    local playerCardsMapModel = require("ui.models.PlayerCardsMapModel").new()
    for pcid, lock in pairs(cardinfo) do
        playerCardsMapModel:ResetCardLock(pcid, lock)
    end
end

-- 是否能购买任务次数
function CoachTaskModel:IsCanBuyCount()
    local vipLevelData = self:GetVipLevelData()
    local resetCream = vipLevelData.resetCream or 0 -- 教练执教任务可购买次数
    local buyCount = self:GetBuyCount()
    return buyCount < resetCream
end

-- 买任务次数的价格
function CoachTaskModel:GetBuyCountPrice()
    local buyCount = self:GetBuyCount() + 1
    local price = self:GetPurchasePrice(buyCount)
    return price
end

-- 是否有一键领取的任务
function CoachTaskModel:IsHasTaskCanRedeem()
    for k,v in pairs(self.data.dlist) do
        if v.state == CoachTaskState.Reward then
            return true
        end
    end
    return false
end

function CoachTaskModel:GetVipLevelData()
    local level = tonumber(self.playerInfoModel:GetVipLevel())
    return VIP[level + 1]
end

function CoachTaskModel:GetOSTime()
    local nowRealTime = Time.realtimeSinceStartup
    local delataTime = math.ceil(nowRealTime - self.lastRealTime)
    local nowServerTime = self.serverTime + delataTime
    return nowServerTime
end

return CoachTaskModel
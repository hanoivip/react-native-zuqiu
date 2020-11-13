local Model = require("ui.models.Model")
local EventSystem = require("EventSystem")
local SystemReward = require("data.SystemReward")
local RewardTaskType = require("ui.scene.rewards.RewardTaskType")
local TASK_TYPE = require("ui.controllers.rewards.TASK_TYPE")

local RewardItemModel = class(Model, "RewardItemModel")

function RewardItemModel:ctor(rewardID, state, value, remainDays, condition)
    self.rewardID = rewardID
    self.state = state
    self.value = value
    self.remainDays = remainDays
    self.condition = condition
    self.staticData = rewardID and SystemReward[tostring(rewardID)]
    self.isEmptyReward = false
end

function RewardItemModel:GetRewardID()
    return self.rewardID
end

-- 中文版在没有奖励的时候会默认选择空界面风格
function RewardItemModel:IsEmptyReward()
    return self.isEmptyReward
end

function RewardItemModel:SetRewardShowStyle(isEmpty)
    self.isEmptyReward = isEmpty
end

-- 奖励状态（-1：未达成；0：达成未领取；1；已领取）
function RewardItemModel:GetState()
    return self.state
end

-- 活跃度类型的奖励，当前值
function RewardItemModel:GetValue()
    return self.value
end

-- 月卡保留时间
function RewardItemModel:GetRemainDays()
    return self.remainDays
end

-- 是月卡，不是至尊月卡
function RewardItemModel:IsMonthCard()
    return tonumber(self.rewardID) == 601
end

-- 达成条件（客户端目前只有需要显示进度的任务用到）
-- 完成每日所有任务 读服务器 condition
function RewardItemModel:GetCondition()
    return self.condition and tonumber(self.condition) or self.staticData.condition
end

-- New新手任务Main主线任务Daily每日任务
function RewardItemModel:GetClass()
    return self.staticData.class
end

function RewardItemModel:GetType()
    return self.staticData.type
end

function RewardItemModel:GetTitle()
    return self.staticData.title
end

function RewardItemModel:IsProgress()
    return self.staticData.progress == 1
end

-- 排列方式（1堆叠2平铺）
function RewardItemModel:GetArrangement()
    return self.staticData.arrangement
end

-- 每类奖励的排列顺序
function RewardItemModel:GetTypeOrder()
    return self.staticData.order1
end

-- 每项奖励的排列顺序
function RewardItemModel:GetItemOrder()
    return self.staticData.order2
end

function RewardItemModel:GetDesc()
    return self.staticData.desc
end

-- 返回通用的奖励格式
function RewardItemModel:GetRewardContents()
    return self.staticData.contents
end

-- 跳转至指定界面
--具体的跳转逻辑如下：
--type=4 登录奖励，无跳转逻辑。
--type=10 通关奖励，跳转至最新进度生涯小关。
--type=11 强化球员奖励，跳转至相应的球员大卡页面。
--type=22 升级球员奖励，跳转至球员管理页面。
--type=23 新手任务，跳转到相应的功能页面。
--2301 生涯首页，2302球员来信首页，2303~2305阵容页面，2307~2309好友页面，2310转会市场页面，2311联赛首页，2312训练基地首页，2313球员管理，2314成就首页，2315~2317无
function RewardItemModel:IsJumpToAppointTask()
    local isJump = self:GetType() == RewardTaskType.Clearance or 
        self:GetType() == RewardTaskType.StrengthenPlayer or 
        self:GetType() == RewardTaskType.LevelUpPlayer or 
        self:GetType() == RewardTaskType.Rookie 
    return isJump
end

return RewardItemModel
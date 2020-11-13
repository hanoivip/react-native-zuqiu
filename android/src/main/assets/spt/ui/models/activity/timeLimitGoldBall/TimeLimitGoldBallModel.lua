local ActivityModel = require("ui.models.activity.ActivityModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CurrencyType = require("ui.models.itemList.CurrencyType")
local CurrencyNameMap = require("ui.models.itemList.CurrencyNameMap")local TimeLimitGoldBallModel = class(ActivityModel, "TimeLimitGoldBallModel")

TimeLimitGoldBallModel.MissionType = {
    Circular = "1", -- 循环任务
    Daily = "2", -- 每日任务
}

-- 任务奖励和位置奖励状态标识
TimeLimitGoldBallModel.RewardState = {
    CanNotReceive = -1, -- 不可领取
    CanReceive = 0, -- 可领取，未领取
    Received = 1 -- 已领取
}

-- 位置奖励类型
TimeLimitGoldBallModel.RewardType = {
    Common = 1, -- 普通奖励
    Advance = 2 -- 进阶奖励
}

TimeLimitGoldBallModel.AdvanceBought = 1 -- 已购买进阶奖励置1

-- 任务类型，客户端只需定义4种即可
TimeLimitGoldBallModel.TaskType = {
    diamond = 1,
    blackDiamond = 2,
    money = 3,
    charge = 6
}

function TimeLimitGoldBallModel:ctor(data)
    self.isHasAdvanced = false -- 是否购买进阶奖励
    self.currMisionType = self.MissionType.Daily -- 当前页面显示的任务类型，默认每日任务

    self.advancePriceType = CurrencyType.Diamond -- 购买进阶奖励所需货币类型
    self.advancePrice = 0 -- 购买进阶奖励所需货币金额

    TimeLimitGoldBallModel.super.ctor(self, data)
end

function TimeLimitGoldBallModel:InitWithProtocol()
    if table.isEmpty(self.singleData) then return end
    self.advancePrice = self.singleData.advanceRewardPrice or 0
    self.advancePriceType = self.singleData.advanceRewardType or CurrencyType.Diamond

    self:ParseAdvanceState(self.singleData.buyAdvanceState)
    -- 奖励
    self:ParseAllReward(self.singleData.posList)
    -- 任务
    self.circularMissionDatas = {}
    self.dailyMissionDatas = {}
    for k, mission in pairs(self.singleData.taskList) do
        mission = self:ParseMissionItemData(mission)
        if mission.missionType == self.MissionType.Circular then
            table.insert(self.circularMissionDatas, mission)
        elseif mission.missionType == self.MissionType.Daily then
            table.insert(self.dailyMissionDatas, mission)
        end
    end
    table.sort(self.circularMissionDatas, function(a, b)
        return tonumber(a.taskID) < tonumber(b.taskID)
    end)
    table.sort(self.dailyMissionDatas, function(a, b)
        return tonumber(a.taskID) < tonumber(b.taskID)
    end)
    for k, mission in ipairs(self.circularMissionDatas) do
        mission.idx = k
    end
    for k, mission in ipairs(self.dailyMissionDatas) do
        mission.idx = k
    end
end

function TimeLimitGoldBallModel:ParseAdvanceState(buyAdvanceState)
    self.isHasAdvanced = tobool(buyAdvanceState == self.AdvanceBought)
end

function TimeLimitGoldBallModel:ParseAllReward(posList)
    self.rewardDatas = {}
    for k, reward in pairs(posList or {}) do
        reward = self:ParseRewardItemData(reward, self.singleData.goldBallNum)
        table.insert(self.rewardDatas, reward)
    end
    table.sort(self.rewardDatas, function(a, b)
        return tonumber(a.pos) < tonumber(b.pos)
    end)
end

-- 解析奖励列表单项数据
function TimeLimitGoldBallModel:ParseRewardItemData(reward, currGoldBallNum)
    reward.idx = tonumber(reward.pos)
    -- 普通奖励
    if reward.commonReward ~= nil and reward.commonReward.contents ~= nil then
        local commonReward = reward.commonReward
        commonReward.state = reward.commonState
        commonReward.isReceived = tobool(commonReward.state == self.RewardState.Received) -- 是否已领取
        commonReward.canReceive = tobool(not commonReward.isReceived and currGoldBallNum >= reward.goldBallNum) -- 是否可以领取
    else
        reward.commonReward = {}
        reward.commonReward.isReceived = false
        reward.commonReward.canReceive = tobool(currGoldBallNum >= reward.goldBallNum)
    end
    -- 进阶奖励
    if reward.advanceReward ~= nil and reward.advanceReward.contents ~= nil then
        local advanceReward = reward.advanceReward
        advanceReward.state = reward.advanceState
        advanceReward.isReceived = tobool(advanceReward.state == self.RewardState.Received)
        advanceReward.canReceive = tobool(not advanceReward.isReceived and self.isHasAdvanced and currGoldBallNum >= reward.goldBallNum)
    else
        reward.advanceReward = {}
        reward.advanceReward.isReceived = false
        reward.advanceReward.canReceive = tobool(self.isHasAdvanced and currGoldBallNum >= reward.goldBallNum)
    end
    return reward
end

-- 解析任务列表单项数据
function TimeLimitGoldBallModel:ParseMissionItemData(mission)
    mission.missionType = tostring(mission.taskFirstType)
    mission.progress = mission.progress or 0
    mission.taskParam = mission.taskParam or 0
    mission.taskReward = mission.taskReward or 0

    mission.isReceived = tobool(mission.state == self.RewardState.Received)
    mission.canReceive = tobool(not mission.isReceived and mission.progress >= mission.taskParam)
    return mission
end

--- 获取活动开始时间
function TimeLimitGoldBallModel:GetBeginTime()
    return self.singleData.beginTime
end

--- 获取活动结束时间
function TimeLimitGoldBallModel:GetEndTime()
    return self.singleData.endTime
end

-- 获得当前页面显示的任务类型，页签
function TimeLimitGoldBallModel:GetCurrMissionType()
    return self.currMisionType
end

function TimeLimitGoldBallModel:SetCurrMissionType(tab)
    self.currMisionType = tab
end

-- 获得奖励数据
function TimeLimitGoldBallModel:GetRewardDatas()
    return self.rewardDatas or {}
end

-- 获得奖励数据的数量
function TimeLimitGoldBallModel:GetRewardCount()
    return #self.rewardDatas or 0
end

-- 获得当前页签下任务滑动框的数据
function TimeLimitGoldBallModel:GetCurrMissionDatas()
    if self.currMisionType == self.MissionType.Circular then
        return self.circularMissionDatas or {}
    elseif self.currMisionType == self.MissionType.Daily then
        return self.dailyMissionDatas or {}
    end
end

-- 获得当前拥有金球数目
function TimeLimitGoldBallModel:GetCurrGoldBallNum()
    return self.singleData.goldBallNum or 0
end

-- 设置拥有金球数目
function TimeLimitGoldBallModel:SetCurrGoldBallNum(num)
    self.singleData.goldBallNum = num
end

-- 增加金球数目
function TimeLimitGoldBallModel:AddCurrGoldBallNum(add)
    self:SetCurrGoldBallNum(self:GetCurrGoldBallNum() + add)
end

-- 是否已经购买进阶奖励
function TimeLimitGoldBallModel:GetIsHasAdvanced()
    return self.isHasAdvanced
end

-- 根据任务id获得任务在列表中的索引
function TimeLimitGoldBallModel:GetTaskIdxByTaskId(taskId)
    return self.singleData.taskList[tostring(taskId)].idx
end

-- 获得玩法说明
function TimeLimitGoldBallModel:GetIntro()
    return 12, "TimeLimitGoldBall"
end

-- 是否有循环任务奖励未领取
function TimeLimitGoldBallModel:HasCircularReward()
    for k, v in ipairs(self.circularMissionDatas) do
        if v.canReceive then
            return true
        end
    end
    return false
end

-- 是否有每日任务奖励未领取
function TimeLimitGoldBallModel:HasDailyReward()
    for k, v in ipairs(self.dailyMissionDatas) do
        if v.canReceive then
            return true
        end
    end
    return false
end

-- 购买进阶奖励资格成功后更新
function TimeLimitGoldBallModel:UpdateAfterAdvanceBought(data)
    self:InitWithProtocol()
    local cost = data.cost
    if cost ~= nil then
        -- 更新客户端消耗
        local playerInfoModel = PlayerInfoModel.new()
        playerInfoModel:CostDetail(cost)
    end
end

-- 领取位置奖励后更新
function TimeLimitGoldBallModel:UpdateAfterReceiveReward(data)
    local pos = tostring(data.posId)
    local rewardType = data.rewardType
    local reward = self.singleData.posList[pos]
    if reward ~= nil then
        -- 更新状态
        if rewardType == self.RewardType.Common then
            reward.commonState = data.posInfo.commonState
        elseif rewardType == self.RewardType.Advance then
            reward.advanceState = data.posInfo.advanceState
        end
        -- 重新解析数据
        reward = self:ParseRewardItemData(reward, self.singleData.goldBallNum)
        -- 更新列表
        if not table.isEmpty(self.rewardDatas) then
            self.rewardDatas[reward.idx] = reward
        end
    end
end

-- 领取任务奖励后更新
function TimeLimitGoldBallModel:UpdateAfterReceiveMissionReward(data)
    local addGoldBall = data.addGoldBallNum or 0
    self:AddCurrGoldBallNum(data.addGoldBallNum or 0)
    local taskId = tostring(data.taskId)
    local mission = self.singleData.taskList[taskId]
    local taskInfo = data.taskInfo or {}
    if mission ~= nil then
        -- 更新任务状态
        if taskInfo.progress ~= nil then
            mission.progress = taskInfo.progress
        end
        if taskInfo.state ~= nil then
            mission.state = taskInfo.state
        end
        if taskInfo.totalRewardTimes ~= nil then
            mission.totalRewardTimes = taskInfo.totalRewardTimes
        end
    end
    mission = self:ParseMissionItemData(mission)
    local idx = mission.idx
    if mission.missionType == self.MissionType.Circular then
        self.circularMissionDatas[idx] = mission
    elseif mission.missionType == self.MissionType.Daily then
        self.dailyMissionDatas[idx] = mission
    end
    -- 更新奖励状态
    self:ParseAllReward(self.singleData.posList)
end

-- 充值成功，更新与充值相关的任务
function TimeLimitGoldBallModel:UpdateAfterCharge(itemPrice)
    self:InitWithProtocol()
end

-- 购买进阶奖励所需
function TimeLimitGoldBallModel:GetAdvancePriceType()
    return self.advancePriceType
end

function TimeLimitGoldBallModel:GetAdvancePriceTypeStr()
    return lang.transstr(CurrencyNameMap[tostring(self:GetAdvancePriceType())])
end

function TimeLimitGoldBallModel:GetAdvancePrice()
    return self.advancePrice
end

return TimeLimitGoldBallModel

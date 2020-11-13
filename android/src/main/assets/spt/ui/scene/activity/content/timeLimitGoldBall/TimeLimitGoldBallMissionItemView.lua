local UnityEngine = clr.UnityEngine
local GameObjectHelper = require("ui.common.GameObjectHelper")

local TimeLimitGoldBallMissionItemView = class(unity.base, "TimeLimitGoldBallMissionItemView")

function TimeLimitGoldBallMissionItemView:ctor()
    -- 任务标题
    self.txtTitle = self.___ex.txtTitle
    -- 循环任务
    self.objCircularArea = self.___ex.objCircularArea
    self.txtCircularReward = self.___ex.txtCircularReward
    -- 循环任务进度
    self.txtCircularProgress = self.___ex.txtCircularProgress

    -- 每日任务
    self.objDailyArea = self.___ex.objDailyArea
    self.txtDailyProgress = self.___ex.txtDailyProgress

    -- 领取按钮和已领取
    self.objReceived = self.___ex.objReceived
    self.btnReceive = self.___ex.btnReceive
    self.buttonReceive = self.___ex.buttonReceive
    self.txtReceivedNum = self.___ex.txtReceivedNum
    self.txtReceiveNum = self.___ex.txtReceiveNum
    self.txtReceiveNum_1 = self.___ex.txtReceiveNum_1

    self.objCanReceive = self.___ex.objCanReceive
    self.objNotCanReceive = self.___ex.objNotCanReceive
end

function TimeLimitGoldBallMissionItemView:InitView(itemData, timeLimitGoldBallModel)
    self.data = itemData
    -- 标题
    self.txtTitle.text = tostring(self.data.desc)
    local isCircular = self.data.missionType == timeLimitGoldBallModel.MissionType.Circular
    local isDaily = self.data.missionType == timeLimitGoldBallModel.MissionType.Daily

    GameObjectHelper.FastSetActive(self.objCircularArea.gameObject, isCircular)
    GameObjectHelper.FastSetActive(self.objDailyArea.gameObject, isDaily)
    local isReceived = self.data.isReceived
    local canReceive = self.data.canReceive
    -- 循环任务
    if isCircular then
        local currProgress = self.data.progress or 0
        local currProgressStr = string.formatNumWithUnit(currProgress)
        -- 单次任务需要
        local singleRequire = self.data.taskParam or 0
        local singleRequireStr = string.formatNumWithUnit(singleRequire)
        -- 单次任务奖励
        local singleReward = self.data.taskReward or 0
        local singleRewardStr = string.formatNumWithUnit(singleReward)
        -- 奖励
        self.txtCircularReward.text = "X" .. singleRewardStr .. " /" .. singleRequireStr .. (self.data.desc1 or "")
        -- 进度
        self.txtCircularProgress.text = lang.trans("time_limit_gold_circular_progress", currProgressStr, singleRequireStr, self.data.desc1 or "")
        GameObjectHelper.FastSetActive(self.objReceived.gameObject, not canReceive)
        GameObjectHelper.FastSetActive(self.btnReceive.gameObject, canReceive)
        -- 已经领取过的总数
        self.txtReceivedNum.text = "X" .. string.formatNumWithUnit(singleReward * self.data.totalRewardTimes or 0)
        -- 要显示可领取的总数
        local times = math.floor(currProgress / singleRequire)
        self.txtReceiveNum.text = "X" .. string.formatNumWithUnit(singleReward * times)
        self.txtReceiveNum_1.text = "X" .. string.formatNumWithUnit(singleReward * times)
        self.buttonReceive.interactable = canReceive
        GameObjectHelper.FastSetActive(self.objCanReceive.gameObject, canReceive)
        GameObjectHelper.FastSetActive(self.objNotCanReceive.gameObject, not canReceive)
    end
    -- 每日任务
    if isDaily then
        -- 进度
        local currStr = string.formatNumWithUnit(self.data.progress)
        local sumStr = string.formatNumWithUnit(self.data.taskParam)
        self.txtDailyProgress.text = lang.trans("time_limit_gold_circular_progress", currStr, sumStr, self.data.desc1  or "")
        -- 是否领取
        GameObjectHelper.FastSetActive(self.objReceived.gameObject, isReceived)
        GameObjectHelper.FastSetActive(self.btnReceive.gameObject, not isReceived)
        -- 已领取的金球数目
        self.txtReceivedNum.text = "X" .. string.formatNumWithUnit(self.data.taskReward)
        -- 领取按钮上的数目
        self.txtReceiveNum.text = "X" .. string.formatNumWithUnit(self.data.taskReward)
        self.txtReceiveNum_1.text = "X" .. string.formatNumWithUnit(self.data.taskReward)
        self.buttonReceive.interactable = canReceive
        GameObjectHelper.FastSetActive(self.objCanReceive.gameObject, canReceive)
        GameObjectHelper.FastSetActive(self.objNotCanReceive.gameObject, not canReceive)
    end
end

function TimeLimitGoldBallMissionItemView:start()
end

return TimeLimitGoldBallMissionItemView

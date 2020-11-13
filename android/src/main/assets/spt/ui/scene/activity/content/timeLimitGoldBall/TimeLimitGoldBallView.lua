local GameObjectHelper = require("ui.common.GameObjectHelper")
local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")

local TimeLimitGoldBallView = class(ActivityParentView, "TimeLimitGoldBallView")

function TimeLimitGoldBallView:ctor()
    -- 玩法说明
    self.btnIntro = self.___ex.btnIntro
    -- 活动时间
    self.txtTime = self.___ex.txtTime
    -- 标题区域
    self.objTitleArea = self.___ex.objTitleArea
    -- 奖励区域
    self.objRewardArea = self.___ex.objRewardArea
    -- 任务区域
    self.objMissionArea = self.___ex.objMissionArea
    -- 获取进阶奖励按钮
    self.btnBuyAdvance = self.___ex.btnBuyAdvance
    -- 奖励滑动框
    self.rewardScroll = self.___ex.rewardScroll
    -- 奖励滑动框右侧箭头
    self.imgArrowRight = self.___ex.imgArrowRight
    -- 页签按钮
    self.tabs = self.___ex.tabs
    -- 当前金球数量
    self.txtCurrGoldBall = self.___ex.txtCurrGoldBall
    -- 任务滑动框
    self.missionScroll = self.___ex.missionScroll
    -- 每日任务提示文本
    self.txtDailyMissionTip = self.___ex.txtDailyMissionTip
    -- tab红点
    self.imgRedPoints = self.___ex.imgRedPoints
    -- 奖励滑动区域，用于隐藏箭头
    self.rctContent = self.___ex.rctContent
    self.rctViewport = self.___ex.rctViewport
end

local width_threshold = 800

function TimeLimitGoldBallView:start()
    self:RegBtnEvent()
    self.widthc = self.rctContent.sizeDelta.x
end

function TimeLimitGoldBallView:update()
    local isShow = self.rctContent.anchoredPosition.x > (width_threshold - self.widthc)
    if self.imgArrowRight.gameObject.activeSelf ~= isShow then
        GameObjectHelper.FastSetActive(self.imgArrowRight.gameObject, isShow)
    end
end

function TimeLimitGoldBallView:InitView(timeLimitGoldBallModel)
    self.model = timeLimitGoldBallModel
    self.missionScroll:RegOnItemButtonClick("btnReceive", function(itemData)
        self:OnReceiveMissionReward(itemData)
    end)
end

function TimeLimitGoldBallView:RefreshView()
    local begin_t = string.convertSecondToMonth(self.model:GetBeginTime())
    local end_t = string.convertSecondToMonth(self.model:GetEndTime())
    self.txtTime.text = lang.trans("cumulative_pay_time", begin_t, end_t)
    self:RefreshRewardView()
    self:RefreshMissionView()
end

function TimeLimitGoldBallView:RefreshContent()
    self:RefreshMissionView()
end

function TimeLimitGoldBallView:RegBtnEvent()
    -- 玩法说明按钮
    self.btnIntro:regOnButtonClick(function()
        self:OnBtnIntro()
    end)
    -- 获取进阶奖励按钮
    self.btnBuyAdvance:regOnButtonClick(function()
        self:OnBtnBuyAdvance()
    end)
    -- 页签
    self.tabs:BindMenuItem(self.model.MissionType.Circular, function()
        self:OnChangeMissionType(self.model.MissionType.Circular)
    end)
    self.tabs:BindMenuItem(self.model.MissionType.Daily, function()
        self:OnChangeMissionType(self.model.MissionType.Daily)
    end)
end

-- 刷新奖励区域
function TimeLimitGoldBallView:RefreshRewardView()
    GameObjectHelper.FastSetActive(self.btnBuyAdvance.gameObject, not self.model:GetIsHasAdvanced())
    self.rewardScroll:InitView(self.model:GetRewardDatas())
end

-- 更新奖励区域单个项目
function TimeLimitGoldBallView:UpdateRewardsItemView(idx, data)
    self.rewardScroll:UpdateItem(idx, data)
end

-- 刷新任务区域
function TimeLimitGoldBallView:RefreshMissionView()
    local currMissionType = self.model:GetCurrMissionType()
    GameObjectHelper.FastSetActive(self.txtDailyMissionTip.gameObject, currMissionType == self.model.MissionType.Daily)
    self.tabs:selectMenuItem(currMissionType)
    self:RefreshRedPoints()
    self:RefreshCurrGoldBallNum()
    self.missionScroll:InitView(self.model:GetCurrMissionDatas(), self.model)
end

-- 更新任务区域单个项目
function TimeLimitGoldBallView:UpdateMissionsItemView(idx, data)
    self.missionScroll:UpdateItem(idx, data)
end

-- 更新当前拥有金球数目
function TimeLimitGoldBallView:RefreshCurrGoldBallNum()
    self.txtCurrGoldBall.text = "X" .. string.formatNumWithUnit(self.model:GetCurrGoldBallNum())
end

function TimeLimitGoldBallView:RefreshRedPoints()
    GameObjectHelper.FastSetActive(self.imgRedPoints[self.model.MissionType.Circular].gameObject, self.model:HasCircularReward())
    GameObjectHelper.FastSetActive(self.imgRedPoints[self.model.MissionType.Daily].gameObject, self.model:HasDailyReward())
end

function TimeLimitGoldBallView:OnEnterScene()
    TimeLimitGoldBallView.super.OnEnterScene(self)
    EventSystem.AddEvent("TimeLimit_GoldBall_ReceiveReward", self, self.OnReceiveReward)
    EventSystem.AddEvent("TimeLimit_GoldBall_BuyAdvanceConfirm", self, self.OnBuyAdvanceConfirm)
end

function TimeLimitGoldBallView:OnExitScene()
    TimeLimitGoldBallView.super.OnExitScene(self)
    EventSystem.RemoveEvent("TimeLimit_GoldBall_ReceiveReward", self, self.OnReceiveReward)
    EventSystem.RemoveEvent("TimeLimit_GoldBall_BuyAdvanceConfirm", self, self.OnBuyAdvanceConfirm)
end

-- 点击玩法说明
function TimeLimitGoldBallView:OnBtnIntro()
    if self.onBtnIntro ~= nil and type(self.onBtnIntro) == "function" then
        self.onBtnIntro()
    end
end

-- 点击页签
function TimeLimitGoldBallView:OnChangeMissionType(missionType)
    if self.onChangeMissionType ~= nil and type(self.onChangeMissionType) == "function" then
        self.onChangeMissionType(missionType)
    end
end

-- 购买进阶奖励资格
function TimeLimitGoldBallView:OnBtnBuyAdvance()
    if self.onBtnBuyAdvance ~= nil and type(self.onBtnBuyAdvance) == "function" then
        self.onBtnBuyAdvance()
    end
end

-- 确认购买进阶奖励资格
function TimeLimitGoldBallView:OnBuyAdvanceConfirm()
    if self.onBuyAdvanceConfirm ~= nil and type(self.onBuyAdvanceConfirm) == "function" then
        self.onBuyAdvanceConfirm()
    end
end

-- 点击上方奖励领取位置奖励
function TimeLimitGoldBallView:OnReceiveReward(pos, isAdvance, itemData)
    if self.onReceiveReward ~= nil and type(self.onReceiveReward) == "function" then
        self.onReceiveReward(pos, isAdvance, itemData)
    end
end

-- 点击下方领取金球奖励
function TimeLimitGoldBallView:OnReceiveMissionReward(itemData)
    if self.onReceiveMissionReward ~= nil and type(self.onReceiveMissionReward) == "function" then
        self.onReceiveMissionReward(itemData)
    end
end

-- 购买进阶奖励资格成功后更新
function TimeLimitGoldBallView:UpdateAfterAdvanceBought()
    self:RefreshRewardView()
    self:RefreshMissionView()
end

-- 领取位置奖励后更新
function TimeLimitGoldBallView:UpdateAfterReceiveReward(posId)
    local idx = tonumber(posId)
    local rewardDatas = self.model:GetRewardDatas() or {}
    self:UpdateRewardsItemView(idx, rewardDatas[idx])
end

-- 领取任务奖励后更新
function TimeLimitGoldBallView:UpdateAfterReceiveMissionReward(taskId)
    local idx = self.model:GetTaskIdxByTaskId(taskId)
    local missionDatas = self.model:GetCurrMissionDatas()
    self:UpdateMissionsItemView(idx, missionDatas[idx])
    self:RefreshCurrGoldBallNum()
    self:RefreshRewardView()
    self:RefreshRedPoints()
end

-- 充值成功，刷新任务列表
function TimeLimitGoldBallView:RefreshContent()
    self.model:UpdateAfterCharge()
    self:UpdateAfterCharge()
    self:RefreshRewardView()
end
-- 充值后更新任务奖励区域
function TimeLimitGoldBallView:UpdateAfterCharge()
    self:RefreshMissionView()
end

return TimeLimitGoldBallView

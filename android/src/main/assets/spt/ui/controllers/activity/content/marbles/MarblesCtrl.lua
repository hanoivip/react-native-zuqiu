local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local SimpleIntroduceModel = require("ui.models.common.SimpleIntroduceModel")
local EventSystem = require("EventSystem")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")

local MarblesCtrl = class(ActivityContentBaseCtrl)

function MarblesCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent("CapsUnityLuaBehav")
    self.view.resetCousume = function (func) self:ResetCousume(func) end
    self:RegBtnEvent()
    self.view:InitView(self.activityModel)
end

-- 按钮事件注册
function MarblesCtrl:RegBtnEvent()
    self.view.onBtnIntro = function() self:OnBtnIntro() end
    self.view.onBtnRewardTask = function() self:OnBtnRewardTask() end
    self.view.onBtnGetReward = function() self:OnBtnGetReward() end
    self.view.onBtnCountReward = function() self:OnBtnCountReward() end
    self.view.onBtnBuyBall = function() self:OnBtnBuyBall() end
    self.view.runOutOfTime = function() self:RunOutOfTime() end

    self.view.addBallClick = function(shootBallInfo) self:OnAddBallClick(shootBallInfo) end
    self.view.onShootBallComplete = function(posTab) self:ShootBallComplete(posTab) end
end

-- 添加球的请求
function MarblesCtrl:OnAddBallClick(shootBallInfo)
    local periodId = self.activityModel:GetPeriodId()
    self.view:coroutine(function()
        local response = req.marblesSetShootInfo(periodId, shootBallInfo.count)
        if api.success(response) then
            local data = response.val
            self.activityModel:SetShootInfo(data)
            self.view:RefreshContent()
            self.view:InitBallCount()
            self.view:PlayRefreshAnim()
        end
    end)
end

-- 射完球的领奖请求
function MarblesCtrl:ShootBallComplete(posTab)
    self.view.currentEventSystem.enabled = true
    local periodId = self.activityModel:GetPeriodId()
    local rewardList = {}
    for i, v in pairs(posTab) do
        local c = table.nums(v)
        local index = math.abs(i-7)
        rewardList[index] = c
    end
    for i = 0, 6 do
        if type(rewardList[i]) ~= "number" then
            rewardList[i] = 0
        end
    end
    self.view:coroutine(function ()
        local response = req.marblesShootBall(periodId, rewardList)
        if api.success(response) then
            local data = response.val
            CongratulationsPageCtrl.new(data.contents)
            self.activityModel:SetShootInfo(data)
            coroutine.yield(WaitForSeconds(2))
            self.view:RollBallCompleteRefresh()
            self.view:RefreshContent()
        else
            self.view:RefreshContent()
        end
    end)
end

-- 玩法介绍
function MarblesCtrl:OnBtnIntro()
    local isTimeInActivity = self.activityModel:IsTimeInActivity()
    if isTimeInActivity then
        local simpleIntroduceModel = SimpleIntroduceModel.new(self.activityModel:GetIntro())
        res.PushDialog("ui.controllers.common.SimpleIntroduceCtrl", simpleIntroduceModel)
    end
end

-- 任务
function MarblesCtrl:OnBtnRewardTask()
    local isTimeInActivity = self.activityModel:IsTimeInActivity()
    if isTimeInActivity then
        res.PushDialog("ui.controllers.activity.content.marbles.MarblesTaskCtrl", self.activityModel)
    end
end

-- 兑换奖励
function MarblesCtrl:OnBtnGetReward()
    local isTimeInActivity = self.activityModel:IsTimeInActivity()
    if isTimeInActivity then
        res.PushDialog("ui.controllers.activity.content.marbles.MarblesExchangeCtrl", self.activityModel)
    end
end

-- 买球
function MarblesCtrl:OnBtnBuyBall()
    local isTimeInActivity = self.activityModel:IsTimeInActivity()
    if isTimeInActivity then
        res.PushDialog("ui.controllers.activity.content.marbles.MarblesBuyKeyCtrl", self.activityModel)
    end
end

-- 领取次数奖励
function MarblesCtrl:OnBtnCountReward()
    local isTimeInActivity = self.activityModel:IsTimeInActivity()
    if isTimeInActivity then
        res.PushDialog("ui.controllers.activity.content.marbles.MarblesCountRewardCtrl", self.activityModel)
    end
end

-- 刷新拥有兑换物的个数
function MarblesCtrl:OnItemsChanged(items)
    self.activityModel:SetOwnItemOrigin(items)
    self.view:InitOwnItemCount()
end

-- 刷新拥有的个数
function MarblesCtrl:OnBallCountChanged(count)
    self.view:SetOwnBallCount()
end

function MarblesCtrl:RunOutOfTime()
    self.activityModel:SetRunOutOfTime()
end

function MarblesCtrl:OnEnterScene()
    self.view:OnEnterScene()
    EventSystem.AddEvent("Marbles_ItemsChanged", self, self.OnItemsChanged)
    EventSystem.AddEvent("Marbles_BuyBall", self, self.OnBallCountChanged)

end

function MarblesCtrl:OnExitScene()
    self.view:OnExitScene()
    EventSystem.RemoveEvent("Marbles_ItemsChanged", self, self.OnItemsChanged)
    EventSystem.RemoveEvent("Marbles_BuyBall", self, self.OnBallCountChanged)
end

return MarblesCtrl

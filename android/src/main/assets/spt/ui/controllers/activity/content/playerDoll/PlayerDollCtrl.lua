local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local WaitForSeconds = UnityEngine.WaitForSeconds
local EventSystems = UnityEngine.EventSystems
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local SimpleIntroduceModel = require("ui.models.common.SimpleIntroduceModel")
local EventSystem = require("EventSystem")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local CurrencyType = require("ui.models.itemList.CurrencyType")

local PlayerDollCtrl = class(ActivityContentBaseCtrl)

function PlayerDollCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent("CapsUnityLuaBehav")
    self:RegBtnEvent()
    self.view.resetCousume = function (func) self:ResetCousume(func) end
    self.view:InitView(self.activityModel)
end

function PlayerDollCtrl:OnRefresh()
    self.view:OnRefresh(self.activityModel)
end

-- 按钮事件注册
function PlayerDollCtrl:RegBtnEvent()
    self.view.onBtnIntro = function() self:OnBtnIntro() end
    self.view.onBtnStart = function() self:OnBtnStart() end
    self.view.onBtnSliderCumulative = function() self:OnBtnSliderCumulative() end
    self.view.onBtnSliderReward = function() self:OnBtnSliderReward() end
    self.view.onBtnGet = function(times) self:OnBtnGet(times) end
    self.view.onBtnChange = function() self:OnBtnChange() end
    self.view.onBtnCountReward = function() self:OnBtnCountReward() end
end

-- 按钮事件定义
function PlayerDollCtrl:OnBtnIntro() -- 玩法介绍
    local simpleIntroduceModel = SimpleIntroduceModel.new(self.activityModel:GetIntro())
    res.PushDialog("ui.controllers.common.SimpleIntroduceCtrl", simpleIntroduceModel)
end

function PlayerDollCtrl:OnBtnStart() -- 启动娃娃机
    local ctrlPath = "ui.controllers.activity.content.playerDoll.PlayerDollRewardSelectCtrl"
    res.PushDialog(ctrlPath, self.activityModel)
end  

function PlayerDollCtrl:OnBtnSliderCumulative() -- 右侧侧奖励界面(模拟拉条效果)
    local rectTrans = self.view.rightContentTrans:GetComponent("RectTransform")
    rectTrans.anchoredPosition = Vector2(0, rectTrans.anchoredPosition.y + 140)
end

function PlayerDollCtrl:OnBtnSliderReward() -- 左侧奖励界面(模拟拉条效果)
    local rectTrans = self.view.leftContentTrans:GetComponent("RectTransform")
    rectTrans.anchoredPosition = Vector2(0, rectTrans.anchoredPosition.y + 102)
end

function PlayerDollCtrl:OnBtnGet(times) -- 开始抓取
    local cost = 0
    if times == 1 then
        cost = self.activityModel:GetOnePrice()
    else
        cost = self.activityModel:GetFivePrice()
    end
    self.view:ChangeRewardImg()
    local function Roll(times)
            local costType = ""
            if self.view.currencyType == CurrencyType.Diamond then
                costType = lang.transstr("diamond")
            elseif self.view.currencyType == CurrencyType.BlackDiamond then
                costType = lang.transstr("pasterSplit_activity_coin")
            end
            local tipContent = lang.trans("timeLimit_player_doll_rollConfirm", costType .. "x" .. cost, times)
            DialogManager.ShowToggleConfirmPop(lang.trans("tips"), tipContent, lang.trans("timeLimit_player_doll_tip"),
                function()
                    self:StartRoll(times)
                end, nil, function(selectState)
                        cache.SetPlayerDollTip(selectState)
                    end)
    end
    local dontShowTip = cache.GetPlayerDollTip()
    if self.view.newPeriod then
        dontShowTip = false
        self.view.newPeriod = false
        cache.SetPlayerDollTip(false)
    end
    if dontShowTip then
        CostDiamondHelper.CostCurrency(cost, self.view, function() self:StartRoll(times) end, self.view.currencyType)
    else
        CostDiamondHelper.CostCurrency(cost, self.view, function() Roll(times) end, self.view.currencyType)
    end
end

function PlayerDollCtrl:StartRoll(times)
    local peridId = self.activityModel:GetPeriodId()
    self.view:coroutine(function ()
        local response = req.dollStart(peridId, times)
        if api.success(response) then
            local currentEventSystem = EventSystems.EventSystem.current
            currentEventSystem.enabled = false
            self.view.middleAnim:SetTrigger("Clip")
            local data = response.val
            local dollCnt = data.dollCnt
            local rewards = data.rewardList
            local cost = data.cost
            PlayerInfoModel.new():CostDetail(cost)
            coroutine.yield(WaitForSeconds(5))
            self.activityModel:SetDollCnt(dollCnt)
            local receiveRewards = RewardDataCtrl.CombineReward(rewards)
            CongratulationsPageCtrl.new(receiveRewards)
            currentEventSystem.enabled = true
            EventSystem.SendEvent("PlayerDoll_Start")
        end
    end)
end

function PlayerDollCtrl:OnBtnChange() -- 进入更换奖励界面
    local ctrlPath = "ui.controllers.activity.content.playerDoll.PlayerDollRewardSelectCtrl"
    res.PushDialog(ctrlPath, self.activityModel)
end

function PlayerDollCtrl:OnBtnCountReward() -- 进入累计次数奖励界面
    local ctrlPath = "ui.controllers.activity.content.playerDoll.PlayerDollTaskCtrl"
    res.PushDialog(ctrlPath, self.activityModel)
end

function PlayerDollCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function PlayerDollCtrl:OnExitScene()
    self.view:OnExitScene()
end

return PlayerDollCtrl

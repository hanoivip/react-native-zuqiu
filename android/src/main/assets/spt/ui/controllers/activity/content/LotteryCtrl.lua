local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local LotteryMatchResult = require("ui.models.activity.LotteryMatchResult")
local Timer = require("ui.common.Timer")

local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")
local LotteryCtrl = class(ActivityContentBaseCtrl)

function LotteryCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)

    self.view.scrollView:RegOnItemButtonClick("winButton", function(model) self:OnStakeButtonClick(model, LotteryMatchResult.Win) end)
    self.view.scrollView:RegOnItemButtonClick("drawButton", function(model) self:OnStakeButtonClick(model, LotteryMatchResult.Draw) end)
    self.view.scrollView:RegOnItemButtonClick("loseButton", function(model) self:OnStakeButtonClick(model, LotteryMatchResult.Lose) end)

    self.view:InitView(self.activityModel.singleData)

    self.view.checkGroup:BindMenuItem("lobby", function() self:SwitchToLobby() end)
    self.view.checkGroup:BindMenuItem("history", function() self:SwitchToHistory() end)

    self.view.checkGroup:selectMenuItem("lobby")
    self:SwitchToLobby()

    -- setup timer to refresh data
    self.timer = Timer.new(10 * 60, nil, function(isOver) self:OnTimer(isOver) end)
    self:ScheduleNextTimer()
end

function LotteryCtrl:OnRefresh()
    self.view:OnRefresh()
end

function LotteryCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function LotteryCtrl:OnExitScene()
    self.view:OnExitScene()
    self.timer:Destroy()
end

function LotteryCtrl:OnStakeButtonClick(model, matchResult)
    clr.coroutine(function ()
        unity.waitForEndOfFrame()
        local ctrl = res.PushDialogImmediate("ui.controllers.activity.content.LotteryBettingCtrl", model, matchResult)
        ctrl.onRaisedBet = function(matchId, model) self:OnRaisedBet(matchId, model) end
    end)
end

function LotteryCtrl:OnRaisedBet(matchId, model)
    self.activityModel:UpdateModel(matchId, model)
end

function LotteryCtrl:SwitchToLobby()
    self.view.historyBoard:SetActive(false)
    self.view.lobbyBoard:SetActive(true)
end

function LotteryCtrl:SwitchToHistory()
    -- request my history
    clr.coroutine(function()
        local response = req.lotteryHistory()
        if api.success(response) then
            self.activityModel.history = response.val
            self.view.historyBoard:SetActive(true)
            self.view.lobbyBoard:SetActive(false)

            self.view.historyScrollView:RegOnItemButtonClick("prizedButton", function(model) self:OnPrizedButtonClick(model.matchId) end)

            self.view:InitHistoryView(self.activityModel.history, true)
        end
    end)
end

function LotteryCtrl:OnPrizedButtonClick(matchId)
    clr.coroutine(function()
        local response = req.lotteryBonus(matchId)
        if api.success(response) then

            CongratulationsPageCtrl.new(response.val)

            self.activityModel:UpdateHistory(response.val.list or response.val.stake, response.val.statistic)
        end
    end)
end

function LotteryCtrl:OnTimer(isOver)
    if isOver then
        return
    end

    self:ResetCousume(function()
        self:ScheduleNextTimer()
    end)
end

function LotteryCtrl:ScheduleNextTimer()
    -- time should be min of :

    -- 10 minutes
    local time = 10 * 60
    local now = self.activityModel.singleData.serverTime
    -- activity end
    time = math.min(time, self.activityModel.singleData.endTime - now)
    for key, item in pairs(self.activityModel.singleData.list) do
        if item.stakeEndTime and item.stakeEndTime > now then
            -- any model.stakeEndTime
            time = math.min(time, item.stakeEndTime - now)
        end
        if item.beginTime and item.beginTime + 105 * 60 > now then
            -- any model.beginTime + 105 minutes
            time = math.min(time, item.beginTime + 105 * 60 - now)
        end
    end

    -- time should be larger than 1 minute to avoid too many server requests
    time = math.max(time, 60)

    self.timer:SetTime(time)
    self.timer:Init()
end

return LotteryCtrl


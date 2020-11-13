local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local LeagueCtrl = require("ui.controllers.league.LeagueCtrl")
local BaseMenuBarModel = require("ui.models.menuBar.BaseMenuBarModel")
local MenuBarCtrl = require("ui.controllers.common.MenuBarCtrl")
local FormationConstants = require("ui.scene.formation.FormationConstants")
local CardPowerCtrl = require("ui.controllers.cardDetail.CardPowerCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local DialogManager = require("ui.control.manager.DialogManager")
local MatchInfoModel = require("ui.models.MatchInfoModel")

local LeagueMainPageCtrl = class(BaseCtrl)
LeagueMainPageCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/League/LeagueMain.prefab"

-- 参数leagueCtrl为空的情况只有在从比赛界面跳转回来的时候
function LeagueMainPageCtrl:Init(leagueInfoModel, leagueCtrl)
    self.leagueInfoModel = leagueInfoModel
    self.leagueCtrl = leagueCtrl
    self.view.onSweep = function() self:Sweep() end
    self.view.onNewSeason = function() self:OnNewSeason() end
    if self.leagueCtrl == nil then
        self:InitView(false)
        self.leagueCtrl = self.leagueInfoModel:GetLeagueCtrl()
        self.leagueCtrl:RequestInitData(self, self.leagueInfoModel)
    else
        self:InitView(true)
    end

    self.view:RegOnDynamicLoad(function (child)
        local infoBarCtrl = InfoBarCtrl.new(child, self)
        infoBarCtrl:RegOnBtnBack(function ()
            self.view:PlayMoveOutAnim()
        end)
    end)
    self.view.onMoveOutAnimEnd = function ()
        self:OnMoveOutAnimEnd()
    end
    local menuBarModel = BaseMenuBarModel.new(BaseMenuBarModel.MenuState.Close, FormationConstants.TeamType.LEAGUE)
    self.menuBarCtrl = MenuBarCtrl.new(self.view.menuBarDynParent, self, nil, menuBarModel)
end

function LeagueMainPageCtrl:Refresh(leagueInfoModel, leagueCtrl, isNewSeason)
    LeagueMainPageCtrl.super.Refresh(self)
    self.leagueInfoModel = leagueInfoModel
    self.leagueCtrl = leagueCtrl
    self.view:SetStartBtnAnimState(false)
    self:InitView(true, isNewSeason)
    self.view:BuildPage()
    self.view:SetAnimState()
end

local TotalTime = 3
local PowerNums = 7
function LeagueMainPageCtrl:InitView(isBuildPage, isNewSeason)
    self.view:InitView(self.leagueInfoModel, isBuildPage, isNewSeason, function(view, powerCtrl, powerParent, power)
        local retPowerCtrl = powerCtrl
        if not powerCtrl then
            retPowerCtrl = CardPowerCtrl.new(powerParent, TotalTime, PowerNums)
        end
        retPowerCtrl:InitPower(power)
        return retPowerCtrl
    end)
end

function LeagueMainPageCtrl:Sweep()
    local isEnded = self.leagueInfoModel:GetSeasonIsEnded()
    if not isEnded then
        if self.leagueInfoModel:GetRemainFreeTime() > 0 or self.leagueInfoModel:IsHasVIPTime() > 0 then
            self.view:coroutine(function()
                local response = req.leagueSweep()
                if api.success(response) then
                    local data = response.val
                    data.sweepRes.hasSettle = false

                    local matchInfoModel = MatchInfoModel.GetInstance()
                    matchInfoModel:InitWithProtocol(data.startRet)
                    local statistics = data.sweepRes.statistics
                    local playerTeamData = {}
                    local opponentTeamData = {}
                    playerTeamData.stats = statistics.player
                    opponentTeamData.stats = statistics.opponent
                    matchInfoModel:UpdatePlayerStatisticsData(playerTeamData)
                    matchInfoModel:UpdateOpponentStatisticsData(opponentTeamData)
                    local playerInfoModel = PlayerInfoModel.new()
                    playerInfoModel:CostDetail(data.cost)
                    cache.setMatchResult(data.sweepRes)
                    res.PushDialog("ui.controllers.league.LeagueSettlementCtrl")
                end
            end)
        elseif self.leagueInfoModel:GetTotalBuyTimes() > 0 and self.leagueInfoModel:GetLastBuyTimes() > 0 then
            res.PushDialog("ui.controllers.league.LeagueBuyChallengeTimesCtrl", self.leagueInfoModel)
        else
            local vipLevel = PlayerInfoModel.new():GetVipLevel()
            local dialogCallback = nil
            local dialogTip = nil

            if vipLevel < 7 then
                dialogCallback = function ()
                    res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl","vip", 7)
                end
                dialogTip = lang.trans("league_tip")
            elseif vipLevel >= 7 and vipLevel <= 10 then
                dialogCallback = function ()
                    res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl","vip", 11)
                end
                dialogTip = lang.trans("league_tip")
            else
                dialogCallback = nil
                dialogTip = lang.trans("match_time_is_zero")
            end
            if dialogCallback ~= nil then
                DialogManager.ShowConfirmPop(lang.trans("tips"), dialogTip, dialogCallback)
            else
                DialogManager.ShowToast(dialogTip)
            end
        end
    else
        local response = req.leagueNewSeason()
        if api.success(response) then
            LeagueCtrl.new()
        end
    end
end

function LeagueMainPageCtrl:OnNewSeason()
    local response = req.leagueNewSeason()
    if api.success(response) then
        LeagueCtrl.new()
    end
end

function LeagueMainPageCtrl:GetStatusData()
    return self.leagueInfoModel, nil
end

function LeagueMainPageCtrl:OnMoveOutAnimEnd()
    local backStep = self.leagueInfoModel:GetBackStep()
    -- 回退主界面
    res.PopAppointSceneImmediate(backStep, "ui.controllers.home.HomeMainCtrl")
end

function LeagueMainPageCtrl:OnSweepCallBack()
    self.leagueCtrl:RequestInitData(self)
    self.leagueCtrl:SettleMatchReward()
end

function LeagueMainPageCtrl:OnMonthCardStateChange()
    local isMonthCard = self.leagueInfoModel:IsMonthCard()
    if not isMonthCard then
        self.leagueCtrl:RequestInitData(self)
    end
end

function LeagueMainPageCtrl:OnEnterScene()
    EventSystem.AddEvent("SettlementPageView.ExitScene", self, self.OnSweepCallBack)
    EventSystem.AddEvent("Charge_Success", self, self.OnMonthCardStateChange)
end

function LeagueMainPageCtrl:OnExitScene()
    EventSystem.RemoveEvent("SettlementPageView.ExitScene", self, self.OnSweepCallBack)
    EventSystem.RemoveEvent("Charge_Success", self, self.OnMonthCardStateChange)
end

return LeagueMainPageCtrl

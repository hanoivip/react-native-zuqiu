local PeakMainModel = require("ui.models.peak.PeakMainModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local DialogManager = require("ui.control.manager.DialogManager")
local PeakInfoBarCtrl = require("ui.controllers.peak.PeakInfoBarCtrl")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local PeakRankBoardCtrl = require("ui.controllers.peak.PeakRankBoardCtrl")
local MatchConstants = require("ui.scene.match.MatchConstants")

local PeakMainCtrl = class(BaseCtrl, "PeakMainCtrl")

PeakMainCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Peak/Peak.prefab"

function PeakMainCtrl:AheadRequest()
    local response = req.peakInfo()
    if api.success(response) then
        local data = response.val
        self.peakMainModel = PeakMainModel.new()
        self.peakMainModel:InitWithProtocol(data)
    end
end

function PeakMainCtrl:Init()
    self.playerInfoModel = PlayerInfoModel.new()
    self.infoBarCtrl = PeakInfoBarCtrl.new(self.view.infoBar)
    self.infoBarCtrl:RegOnBtnBack(function ()
        res.PopScene()
    end)
    self.view.receiveBtnClick = function () self:ReceiveBtnClick() end
    self.view.toggleBtnClick = function () self:ToggleBtnClick() end
    self.view.lockBtnClick = function () self:LockBtnClick() end
    self.view.upOrDownBtnClick = function(sourceMess, targetMess) self:FormationItemSwapOrder(sourceMess, targetMess) end
    self.view.fireBtnClick = function () self:FireBtnClick() end
    self.view.historyBtnClick = function () self:HistoryBtnClick() end
    self.view.rankBtnClick = function () self:RankBtnClick() end
    self.view.storeBtnClick = function () self:StoreBtnClick() end
    self.view.everyTaskBtnClick = function () self:EveryTaskBtnClick() end
    self.view.ruleBtnClick = function () self:RuleBtnClick() end
    self:CheckIsOpenMatchDetailsWindow()
end

function PeakMainCtrl:Refresh()
    PeakMainCtrl.super.Refresh(self)
    self:CheckUseDefaultTeam()
    self.view:InitView(self.peakMainModel)
end

function PeakMainCtrl:RefreshPeakMainPage()
    local response = req.peakInfo()
    if api.success(response) then
        local data = response.val
        self.peakMainModel = PeakMainModel.new()
        self.peakMainModel:InitWithProtocol(data)
        self:CheckUseDefaultTeam()
        self.view:InitView(self.peakMainModel)
    end
end

function PeakMainCtrl:RuleBtnClick()
    res.PushScene("ui.controllers.peak.PeakRuleCtrl")
end

function PeakMainCtrl:EveryTaskBtnClick()
    res.PushDialog("ui.controllers.peak.PeakEveryTaskCtrl")
end

function PeakMainCtrl:StoreBtnClick()
    res.PushDialog("ui.controllers.peak.PeakStoreCtrl")
end

function PeakMainCtrl:ReceiveBtnClick()
    self.view:coroutine(function ()
        local response = req.peakReceivePeakPoint()
        if api.success(response) then
            local data = response.val
            self.playerInfoModel:SetPeakDiamond(data.currPeakPoint)
            EventSystem.SendEvent("Peak_Reveive_Diamond")
            EventSystem.SendEvent("Refresh_Peak_Main_Page")
        end
    end)
end

function PeakMainCtrl:RankBtnClick()
    res.PushScene("ui.controllers.peak.PeakRankMainCtrl", self.peakMainModel:GetPrePeakDailyCount())
end

function PeakMainCtrl:SwapTeamOrder()
    local orderData = self.peakMainModel:GetTeamOrderService()
    self.view:coroutine(function ()
        local response = req.peakSwapTeam(orderData.peak1, orderData.peak2, orderData.peak3)
        if api.success(response) then
            DialogManager.ShowToastByLang("peak_change_tip")
            EventSystem.SendEvent("Refresh_Peak_Main_Page")
        end
    end)
end

function PeakMainCtrl:LockFormation()
    local teamShow = self.peakMainModel:GetTeamShow()
    clr.coroutine(function ()
        local response = req.peakHideTeam(teamShow.peak1, teamShow.peak2, teamShow.peak3)
        if api.success(response) then
            if teamShow.peak1 == 0 or teamShow.peak2 == 0 or teamShow.peak3 == 0 then
                DialogManager.ShowToastByLang("peak_hide_warn")
            end
            if teamShow.peak1 == 1 and teamShow.peak2 == 1 and teamShow.peak3 == 1 then
                DialogManager.ShowToastByLang("peak_hide_warn_1")
            end
            EventSystem.SendEvent("Refresh_Peak_Main_Page")
        end
    end)
end

function PeakMainCtrl:ToggleBtnClick()
    local lockStatus = self.peakMainModel:GetIsLockStatus()
    if lockStatus then
        DialogManager.ShowToast(lang.trans("peak_warn_finsih_lock"))
        return
    end
    local status = self.peakMainModel:GetIsChangeOrderStatus()
    self.view:ChangeOrderStatus(not status)
    self.peakMainModel:SetChangeOrderStatus(not status)
    if status then
        self:SwapTeamOrder()
    end
end

function PeakMainCtrl:LockBtnClick()
    local changeOrderStatus = self.peakMainModel:GetIsChangeOrderStatus()
    local lockStatus = self.peakMainModel:GetIsLockStatus()
    if changeOrderStatus then
        DialogManager.ShowToast(lang.trans("peak_warn_finish_change"))
        return
    end
    self.peakMainModel:SetLockStatus(not lockStatus)
    self.view:LockFormationStatus(not lockStatus)
    if lockStatus then
        self.view:RefreshLockStatus()
        self:LockFormation()
    end
end

function PeakMainCtrl:FormationItemSwapOrder(sourceMess, dir)
    self.peakMainModel:SwapLocTeamOrder(sourceMess, dir)
end

function PeakMainCtrl:FireBtnClick()
    local isFireStatus = self.peakMainModel:GetCdRemainTime()
    if tonumber(isFireStatus) <= 0 then
        local canChallengeTime = self.peakMainModel:GetRemainChallengeTimes()
        if tonumber(canChallengeTime) == 0 then
            DialogManager.ShowConfirmPop(lang.trans("league_buyChallengeTimes"), 
                lang.trans("peak_buy_challenge_time", self.peakMainModel:GetBuyChallengeTimeConsume()), function ()
                    if tonumber(self.peakMainModel:GetBuyChallengeTimeConsume()) > tonumber(self.playerInfoModel:GetDiamond()) then
                        local confirmCallback = function()
                            res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl")
                        end
                        DialogManager.ShowConfirmPopByLang("tips", "diamondNotEnoughAndBuy", confirmCallback)
                    else
                        clr.coroutine(function ()
                            local response = req.peakBuyChallengeTimes()
                            if api.success(response) then
                                local data = response.val
                                if data.cost.type == "d" then
                                    self.playerInfoModel:SetDiamond(data.cost.curr_num)
                                end
                                EventSystem.SendEvent("Refresh_Peak_Main_Page")
                            end
                        end)
                    end
                end, nil, nil, DialogManager.DialogType.GeneralBox)
        else
            clr.coroutine(function ()
                local response2 = req.peakCanSweepChallenge()
                if api.success(response2) then
                    local sweepData = response2.val
                    cache.setPeakSweepFlag(sweepData.inSweepTime)
                    clr.coroutine(function ()
                        local data = cache.getPeakOpponentData()
                        if (not data) or (data.rank ~= sweepData.rank) then
                            local response = req.peakNewOpponent()
                            if api.success(response) then
                                data = response.val
                                cache.setPeakOpponentData(data)
                                if next(data) then
                                    res.PushDialog("ui.controllers.peak.PeakChallengeBoardCtrl", data)
                                else
                                    DialogManager.ShowToast(lang.trans("peak_no_data"));
                                end
                            end
                        else
                            if next(data) then
                                res.PushDialog("ui.controllers.peak.PeakChallengeBoardCtrl", data)
                            else
                                DialogManager.ShowToast(lang.trans("peak_no_data"));
                            end
                        end
                    end)
                end
            end)
        end
    else
        DialogManager.ShowConfirmPop(lang.trans("peak_reset_cd"), lang.trans("peak_reset_tip", 
            self.peakMainModel:GetResetCdTimeConsume()), function()
            self:ResetChallengeTime()
        end, nil, nil, DialogManager.DialogType.GeneralBox)
    end
end

function PeakMainCtrl:ResetChallengeTime()
    if tonumber(self.peakMainModel:GetResetCdTimeConsume()) > tonumber(self.playerInfoModel:GetDiamond()) then
        local confirmCallback = function()
            res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl")
        end
        DialogManager.ShowConfirmPopByLang("tips", "diamondNotEnoughAndBuy", confirmCallback)
    else
        clr.coroutine(function ()
            local response = req.peakResetPlayCd()
            if api.success(response) then
                local data = response.val
                if data.cost.type == "d" then
                    self.playerInfoModel:SetDiamond(data.cost.curr_num)
                    self.peakMainModel:SetCdRemainTime(0)
                end
            end
        end)
    end
end

function PeakMainCtrl:OnEnterScene()
    self.view:OnEnterScene()
    EventSystem.AddEvent("Refresh_Peak_Main_Page", self, self.RefreshPeakMainPage)
end

function PeakMainCtrl:OnExitScene()
    self.view:OnExitScene()
    EventSystem.RemoveEvent("Refresh_Peak_Main_Page", self, self.RefreshPeakMainPage)
end

function PeakMainCtrl:HistoryBtnClick()
    clr.coroutine(function ()
        local response = req.peakRecordList()
        if api.success(response) then
            local data = response.val
            if data.record and next(data.record) then
                res.PushDialog("ui.controllers.peak.PeakHistoryMainCtrl", data)
            else
                DialogManager.ShowToast(lang.trans("peak_no_data"));
            end
        end
    end)
end

function PeakMainCtrl:CheckIsOpenMatchDetailsWindow()
    local matchResultData = clone(cache.getMatchResult())
    --比赛的奖励是否已结算过
    if matchResultData and matchResultData.matchType == MatchConstants.MatchType.PEAK then
        cache.setMatchResult(nil)
        res.PushDialog("ui.controllers.peak.PeakMatchDetailsCtrl", matchResultData.settlement)
    end
end

function PeakMainCtrl:CheckUseDefaultTeam()
    --保存默认阵容，更新客户端锁
    if self.peakMainModel:IsTeamNull() then
        local defualtTeamData = self.peakMainModel:GetDefualtTeam()
        if next(defualtTeamData) then
            clr.coroutine(function ()
                local playerTeamsModel = require("ui.models.PlayerTeamsModel").new()
                local teamType = playerTeamsModel:GetTeamType()
                local keyPlayersData ={freeKickShoot = defualtTeamData.freeKickShoot, spotKick = defualtTeamData.spotKick,
                    captain = defualtTeamData.captain, freeKickPass = defualtTeamData.freeKickPass ,corner = defualtTeamData.corner}
                local resp = req.peakSaveTeam(defualtTeamData.ptid, defualtTeamData.formationID, defualtTeamData.init, teamType, defualtTeamData.rep, 
                    keyPlayersData, defualtTeamData.tactics, defualtTeamData.selectedType)
                if api.success(resp) then
                    playerTeamsModel:SetFormationId(defualtTeamData.ptid , defualtTeamData.formationID)
                    playerTeamsModel:SetInitPlayersData(defualtTeamData.ptid , defualtTeamData.init)
                    playerTeamsModel:SetReplacePlayersData(defualtTeamData.ptid , defualtTeamData.rep)
                    playerTeamsModel:SetSelectedType(defualtTeamData.selectedType)
                    playerTeamsModel:SetNowTeamKeyPlayersData(keyPlayersData)
                    playerTeamsModel:SetNowTeamTacticsData(defualtTeamData.tactics)
                    self:ResetCardsLock(resp.val)
                end
            end)
        end
    end
end

function PeakMainCtrl:ResetCardsLock(data)
    local locks = data.lock or {}
    local playerCardsMapModel = require("ui.models.PlayerCardsMapModel").new()
    for pcid, lock in pairs(locks) do
        playerCardsMapModel:ResetCardLock(pcid, lock)
    end
end

return PeakMainCtrl
local PeakPlayerDetailCtrl = require("ui.controllers.playerDetail.PeakPlayerDetailCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local MatchInfoModel = require("ui.models.MatchInfoModel")
local ItemModel = require("ui.models.ItemModel")
local ItemsMapModel = require("ui.models.ItemsMapModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local PeakChallengeBoardCtrl = class(BaseCtrl)

PeakChallengeBoardCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Peak/PeakChallengeBoard.prefab"

function PeakChallengeBoardCtrl:Init(data)
    self.data = data
    self.view.onViewDetail = function (sid, pid, resetPowerCallBack) self:OnViewDetail(sid, pid, resetPowerCallBack) end
    self.view.onChallengeOpponent = function (pid, sweep) self:OnChallengeOpponent(pid, sweep) end
end

function PeakChallengeBoardCtrl:Refresh(data)
    PeakChallengeBoardCtrl.super.Refresh(self)
    self.view:InitView(data or self.data)
end

function PeakChallengeBoardCtrl:OnEnterScene()
    EventSystem.AddEvent("Refresh_Peak_Opponent", self, self.RefreshOpponent)
end

function PeakChallengeBoardCtrl:OnExitScene()
    EventSystem.RemoveEvent("Refresh_Peak_Opponent", self, self.RefreshOpponent)
end

function PeakChallengeBoardCtrl:RefreshOpponent()
     clr.coroutine(function ()
        local response2 = req.peakCanSweepChallenge()
        if api.success(response2) then
            cache.setPeakSweepFlag(response2.val.inSweepTime)
            clr.coroutine(function ()
                local response = req.peakNewOpponent()
                if api.success(response) then
                    local data = response.val
                    cache.setPeakOpponentData(data)
                    self.data = data
                    self.view:InitView(self.data)
                end
            end)
        end
    end)
end

function PeakChallengeBoardCtrl:OnViewDetail(sid, pid, resetPowerCallBack)
    PeakPlayerDetailCtrl.ShowPlayerDetailView(function()
            local response = req.peakViewOpponent(sid, pid)
            resetPowerCallBack(response.val)
            return response
        end, 
        pid, sid, sid, require("ui.models.PlayerInfoModel").new():GetID() == pid)
end

function PeakChallengeBoardCtrl:GetStatusData()
    return self.data
end

function PeakChallengeBoardCtrl:OnChallengeOpponent(pid, sweep)
    if sweep and (not self:ReduceSweepCost()) then
        return
    end
    clr.coroutine(function ()
        local response = req.peakInitChallenge(pid)
        if api.success(response) then
            clr.coroutine(function ()
                local resp = nil
                if sweep then
                    resp = req.peakSweepChallenge(pid, response.val.challengeId, 1)
                else
                    resp = req.peakChallenge(pid, response.val.challengeId, 1)
                end
                if api.success(resp) then
                    self.view:CloseImmediate()
                    cache.setPeakOpponentData(nil)
                    if sweep and resp.val.sweepConsume then
                        self.itemsMapModel = ItemsMapModel.new()
                        self.itemsMapModel:UpdateFromReward(resp.val.sweepConsume)
                    end
                    local teamInfo = cache.getPeakTeamData()
                    local teamData = {}
                    teamData.teams = teamInfo
                    teamData.currTid = teamInfo["1"] and teamInfo["1"].tid
                    MatchInfoModel.GetInstance():SetMatchTeamData(teamData)
                    if resp.val.needMatch then
                        local MatchLoader = require("coregame.MatchLoader")
                        MatchLoader.startMatch(resp.val.matchData)
                    else
                        local matchData = sweep and resp.val.settlement or resp.val.matchData
                        if matchData and next(matchData) then
                            res.PushDialog("ui.controllers.peak.PeakMatchDetailsCtrl", matchData)
                        else
                            DialogManager.ShowToast(lang.trans("peak_nil_sweep"))
                        end
                    end
                end
            end)
        end
    end)
end

--扫荡券  id= 2
function PeakChallengeBoardCtrl:ReduceSweepCost()
    local itemModel = ItemModel.new(2)
    if itemModel:GetItemNum() <= 0 then
        self:AskBuySweepCuponOrNot()
        return false
    end
    return true
end

--- 询问是否购买扫荡券
function PeakChallengeBoardCtrl:AskBuySweepCuponOrNot()
    DialogManager.ShowConfirmPopByLang("tips", "sweepCuponNotEnoughAndBuy", function ()
        clr.coroutine(function ()
            coroutine.yield(clr.UnityEngine.WaitForSeconds(0.05))
            local StoreModel = require("ui.models.store.StoreModel")
            res.PushScene("ui.controllers.store.StoreCtrl", StoreModel.MenuTags.ITEM)
        end)
    end)
end

return PeakChallengeBoardCtrl
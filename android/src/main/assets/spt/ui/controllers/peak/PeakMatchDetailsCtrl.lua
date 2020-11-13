local BaseCtrl = require("ui.controllers.BaseCtrl")
local PeakMatchDetailsModel = require("ui.models.peak.PeakMatchDetailsModel")
local MatchInfoModel = require("ui.models.MatchInfoModel")
local DialogManager = require("ui.control.manager.DialogManager")
local ItemModel = require("ui.models.ItemModel")
local ItemsMapModel = require("ui.models.ItemsMapModel")
local MatchLoader = require("coregame.MatchLoader")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local NewYearOutPutPosType = require("ui.scene.activity.content.worldBossActivity.NewYearOutPutPosType")
local NewYearCongratulationsPageCtrl = require("ui.controllers.activity.content.worldBossActivity.NewYearCongratulationsPageCtrl")

local PeakMatchDetailsCtrl = class(BaseCtrl)

PeakMatchDetailsCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

PeakMatchDetailsCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Peak/PeakResultBoard.prefab"

function PeakMatchDetailsCtrl:Init(matchDetailsData)
    self.matchDetailsData = matchDetailsData
    self.view.onChildViewFightDetail = function(vid) self:OnChildViewFightDetail(vid) end
    self.view.onInitTeamLogo = function(img , imgid) self:OnInitTeamLogo(img , imgid) end
    self:InitAllView()
end

function PeakMatchDetailsCtrl:GetStatusData()
    return self.matchDetailsData
end

function PeakMatchDetailsCtrl:InitAllView()
    self.peakMatchDetailsModel = PeakMatchDetailsModel.new()
    self.peakMatchDetailsModel:InitWithParentProtocol(self.matchDetailsData)
    local  flagData = self.peakMatchDetailsModel:GetUrlData()
    if flagData.flag then
        self.view:ShowChangeContinue(true)
        self.view.onContineChallenge = function(reqStartCallback, sweep) self:OnContinueChallenge(reqStartCallback, flagData.pid, flagData.challengeId, flagData.Order, sweep) end
    else
        self.view:ShowChangeContinue(false)
        self:OnOverChallenge(flagData.pid, flagData.challengeId)
    end
    
    self.view:InitChildView(self.peakMatchDetailsModel:GetMatchResultDataList())
    self.view:InitView(self.peakMatchDetailsModel:GetMatchTitleData())

    NewYearCongratulationsPageCtrl.new(self.matchDetailsData, NewYearOutPutPosType.PEAK)
end

function PeakMatchDetailsCtrl:OnInitTeamLogo(teamLogo, logoData)
    TeamLogoCtrl.BuildTeamLogo(teamLogo, logoData)
end

function  PeakMatchDetailsCtrl:OnChildViewFightDetail(vid)
    if not vid then
        return
    end
    clr.coroutine(function()
        local respone = req.peakViewVideo(vid)
        if api.success(respone) then
            if respone.val then
                local ReplayCheckHelper = require("coregame.ReplayCheckHelper")
                ReplayCheckHelper.StartReplay(respone.val, vid)
            end
        end
    end)
end

--* mark！玩法内部换人架构不太友好
function PeakMatchDetailsCtrl:OnContinueChallenge(reqStartCallback, pid, challengeId, order, sweep)
    clr.coroutine(function()
        local resp = nil
        if sweep then
            if self:ReduceSweepCost() then
                resp = req.peakSweepChallenge(pid, challengeId, order)
            end
        else
            resp = req.peakChallenge(pid, challengeId, order)
        end
        reqStartCallback()
        if api.success(resp) then
            if resp.val then
                if sweep and resp.val.sweepConsume then
                    self.itemsMapModel = ItemsMapModel.new()
                    self.itemsMapModel:UpdateFromReward(resp.val.sweepConsume)
                end
                local teamInfo = cache.getPeakTeamData()
                local teamData = { }
                teamData.teams = teamInfo
                teamData.currTid = teamInfo[tostring(order)] and teamInfo[tostring(order)].tid
                MatchInfoModel.GetInstance():SetMatchTeamData(teamData)
                if sweep or not resp.val.needMatch then
                    self.matchDetailsData = sweep and resp.val.settlement or resp.val.matchData
                    if self.matchDetailsData and next(self.matchDetailsData) then
                        self:InitAllView()
                    else
                        DialogManager.ShowToast(lang.trans("peak_nil_sweep"))
                    end
                else
                    --直接关闭
                    self.view:CloseImmediate()
                    MatchLoader.startMatch(resp.val.matchData)
                end
            else
                DialogManager.ShowToast(lang.trans("peak_nil_sweep"))
            end
        end
    end)
end

function PeakMatchDetailsCtrl:OnOverChallenge(pid, challengeId)
    --两种状态
    if not pid then
        return
    end
    clr.coroutine(function()
        local resp = req.peakChallengeOver(pid, challengeId)
        if api.success(resp) then
            EventSystem.SendEvent("Refresh_Peak_Main_Page")
        end
    end)
    MatchInfoModel.GetInstance():SetMatchTeamData(nil)
end

--扫荡券  id= 2
function PeakMatchDetailsCtrl:ReduceSweepCost()
    local itemModel = ItemModel.new(2)
    if itemModel:GetItemNum() <= 0 then
        self:AskBuySweepCuponOrNot()
        return false
    end
    return true
end

--- 询问是否购买扫荡券
function PeakMatchDetailsCtrl:AskBuySweepCuponOrNot()
    DialogManager.ShowConfirmPopByLang("tips", "sweepCuponNotEnoughAndBuy", function ()
        clr.coroutine(function ()
            coroutine.yield(clr.UnityEngine.WaitForSeconds(0.05))
            local StoreModel = require("ui.models.store.StoreModel")
            res.PushScene("ui.controllers.store.StoreCtrl", StoreModel.MenuTags.ITEM)
        end)
    end)
end

return PeakMatchDetailsCtrl
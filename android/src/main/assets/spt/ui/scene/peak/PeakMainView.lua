local GameObjectHelper = require("ui.common.GameObjectHelper")
local Timer = require("ui.common.Timer")
local ReqEventModel = require("ui.models.event.ReqEventModel")
local ColorConversionHelper = require("ui.common.ColorConversionHelper")
local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local Tweening = clr.DG.Tweening
local DOTween = Tweening.DOTween
local Tweener = Tweening.Tweener
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease
local UnityActionBinder = clr.Capstones.UnityFramework.UnityActionBinder
local Button = UnityEngine.UI.Button
local Text = UnityEngine.UI.Text

local PeakMainView = class(unity.base)

function PeakMainView:ctor()
    self.endTimeTxt = self.___ex.endTimeTxt
    self.rankTxt = self.___ex.rankTxt
    self.newRankTxt = self.___ex.newRankTxt
    self.rewardCountTxt = self.___ex.rewardCountTxt
    self.receiveBtn = self.___ex.receiveBtn
    self.receiveBtnTxt = self.___ex.receiveBtnTxt
    self.receiveComponentBtn = self.___ex.receiveComponentBtn
    self.rewardTipTxt = self.___ex.rewardTipTxt
    self.historyBtn = self.___ex.historyBtn
    self.storeBtn = self.___ex.storeBtn
    self.rankBtn = self.___ex.rankBtn
    self.fireBtn = self.___ex.fireBtn
    self.toggleBtn =self.___ex.toggleBtn
    self.lockBtn = self.___ex.lockBtn
    self.lockBtnTxt = self.___ex.lockBtnTxt
    self.toggleBtnTxt = self.___ex.toggleBtnTxt
    self.remainTimeTxt = self.___ex.remainTimeTxt
    self.infoBarDynParent = self.___ex.infoBarDynParent
    self.formationView = self.___ex.formationView
    self.remainTimeFireTxt = self.___ex.remainTimeFireTxt
    self.fireOrResetTxt = self.___ex.fireOrResetTxt
    self.cdTxt = self.___ex.cdTxt
    self.everyTaskBtn = self.___ex.everyTaskBtn
    self.ruleBtn = self.___ex.ruleBtn
    self.everyTaskRedPoint = self.___ex.everyTaskRedPoint
    self.historyPoint = self.___ex.historyPoint
    self.particle = self.___ex.particle
    self.seasonTxt = self.___ex.seasonTxt
    self.cumulativePointTxt = self.___ex.cumulativePointTxt
    self.rankAnim =self.___ex.rankAnim
    self.countDownTxt = self.___ex.countDownTxt
    self.scoreTxt = self.___ex.scoreTxt
    self.infoBar = self.___ex.infoBar
    self.exchangeBoxCount = self.___ex.exchangeBoxCount
    self.showScore = self.___ex.showScore
    self.hideScore = self.___ex.hideScore
end

function PeakMainView:start()
    self.formationLocalPositions = {}
    self.formationSiblingIndexs = {}
    for k,v in pairs(self.formationView) do
        self.formationLocalPositions[k] = v.transform.localPosition
        self.formationSiblingIndexs[k] = v.transform:GetSiblingIndex()
    end
    self.tweenTime = 0.3
    self:RegBtn()
end

function PeakMainView:InitView(peakMainModel)
    self:ResetFormationViewTransform()
    self.peakMainModel = peakMainModel
    self:InitFormationItemView(peakMainModel)
    self.cumulativePointTxt.text = "x"  .. self.peakMainModel:GetPeakPoint() 
    self.exchangeBoxCount.text = "x"  .. self.peakMainModel:GetPeakCount()
    self.seasonTxt.text = lang.trans("peak_season", self.peakMainModel:GetSeasonTag())
    if self.endTimer then
        self.endTimer:Destroy()
        self.endTimer = nil
    end
    self.endTimer = Timer.new(self.peakMainModel:GetEndTime(), function (time)
        self.endTimeTxt.text = lang.trans("peak_end_time", string.convertSecondToTime(time))
        if time <= 0 then
            res.PopScene()
        end
    end)

    local rank = self.peakMainModel:GetSelfRank()
    if tonumber(rank) == -1 then
        self.rankTxt.text = "--"
    else
        self.rankTxt.text = tostring(rank)
    end
    self.scoreTxt.text = self.peakMainModel:GetSelfScore()
    local rewardPoint = self.peakMainModel:GetRewardPoint()
    self.rewardCountTxt.text = "x" .. tostring(rewardPoint)

    if tonumber(rank) ~= -1 then
        if self.rewardTimer then
            self.rewardTimer:Destroy()
            self.rewardTimer = nil
        end
        self.rewardTimer = Timer.new(self.peakMainModel:GetSendRewardTime(), function (time)
            if self.peakMainModel then
                self.peakMainModel:SetSendRewardTime(toint(time))
            end
        end)
    end
    self.remainTimeTxt.text = lang.trans("peak_remain_time", self.peakMainModel:GetRemainChallengeTimes(), self.peakMainModel:GetMaxChallengeTimes())
    if self.cdTimer then
        self.cdTimer:Destroy()
        self.cdTimer = nil
    end
    self.cdTimer = Timer.new(self.peakMainModel:GetCdRemainTime(), function (time)
        if self.peakMainModel then
            self.peakMainModel:SetCdRemainTime(toint(time))
            -- 刷新cd的钻石数随时间而降低
            self.peakMainModel:SetResetCdTimeConsume(math.ceil(time / 60 / 2) * 10)
        end
    end)
    GameObjectHelper.FastSetActive(self.showScore, not self.peakMainModel:IsHideScore())
    GameObjectHelper.FastSetActive(self.hideScore, self.peakMainModel:IsHideScore())
    self:InitRankContent()
    self:DisActiveParticle()
       --初次更新红点
    self:UpdateEveryTaskRedPoint()
    self:UpdateHistoryPoint()
end

function PeakMainView:InitFormationItemView(peakMainModel)
    for k, v in pairs(self.formationView) do
        local peakId = string.sub(peakMainModel:GetTeamOrder()[tostring(k)], -1)
        local isOn = peakMainModel:GetTeamShow()["peak" .. peakId]
        v:InitView(peakMainModel:GetTeamDataByLocIndex(k), peakId, isOn)
        v.upBtnClick = function()  self:SwapTowItemPosition(tonumber(k),1);  end
        v.downBtnClick = function() self:SwapTowItemPosition(tonumber(k),-1);  end
    end
end

function PeakMainView:RefreshFormationItemView(teamOrder)
    for k, v in pairs(self.formationView) do
        local peakId = string.sub(teamOrder[tostring(k)], -1)
        v:InitView(self.peakMainModel:GetTeamDataByLocIndex(k), peakId)
    end
end

function PeakMainView:RefreshLockStatus()
    local teamShow = self.peakMainModel:GetTeamShow()
    for k, v in pairs(self.formationView) do
        local peakId, isOn = v:GetLockStatus()
        teamShow["peak" .. peakId] = isOn and 0 or 1
    end
    self.peakMainModel:SetTeamShow(teamShow)
end

function PeakMainView:ChangeOrderStatus(changeOrderStatus)
    if changeOrderStatus then
        self.toggleBtnTxt.text = lang.trans("complete")
    else
        self.toggleBtnTxt.text = lang.trans("switch")
    end
    for k, v in pairs(self.formationView) do
        v:ShowToggleOrFormationBtn(changeOrderStatus)
    end
end

function PeakMainView:LockFormationStatus(status)
    if status then
        self.lockBtnTxt.text = lang.trans("complete")
    else
        self.lockBtnTxt.text = lang.trans("peak_lock_formation")
    end
    for k, v in pairs(self.formationView) do
        v:ShowLockOrFormationBtn(status)
    end
end

function PeakMainView:RegBtn()
    self.receiveBtn:regOnButtonClick(function ()
        if self.receiveBtnClick then
            self.receiveBtnClick()
        end
    end)
    self.historyBtn:regOnButtonClick(function ()
        if self.historyBtnClick then
            self.historyBtnClick()
        end
    end)
    self.storeBtn:regOnButtonClick(function ()
        if self.storeBtnClick then
            self.storeBtnClick()
        end
    end)
    self.fireBtn:regOnButtonClick(function ()
        if self.fireBtnClick then
            self.fireBtnClick()
        end
    end)
    self.rankBtn:regOnButtonClick(function ()
        if self.rankBtnClick then
            self.rankBtnClick()
        end
    end)
    self.toggleBtn:regOnButtonClick(function ()
        if self.toggleBtnClick then
            self.toggleBtnClick()
        end
    end)
    self.lockBtn:regOnButtonClick(function ()
        if self.lockBtnClick then
            self.lockBtnClick()
        end
    end)
    self.everyTaskBtn:regOnButtonClick(function ()
        if self.everyTaskBtnClick then
            self.everyTaskBtnClick()
        end
    end)
    self.ruleBtn:regOnButtonClick(function ()
        if self.ruleBtnClick then
            self.ruleBtnClick()
        end
    end)
end

function PeakMainView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function PeakMainView:InitRankContent()
    local isMaxScore = self.peakMainModel:GetIsMaxScore()
    if isMaxScore then
        self.rewardTipTxt.text = lang.trans("ladder_rewardHintInfoForFirstRank")
    else
        self.rewardTipTxt.text = lang.trans("peak_reward_tip", self.peakMainModel:GetNextScoreStage())
    end
end

function PeakMainView:RefreshRewardTime(time)
    self.receiveBtn:onPointEventHandle(time <= 0)
    self.receiveComponentBtn.interactable = time <= 0
    local r, g, b 
    if time <= 0 then
        r, g, b = 145, 125, 86
    else
        r, g, b = 125, 125, 125
    end
    local color = ColorConversionHelper.ConversionColor(r, g, b)
    self.receiveBtnTxt.color = color
    if time > 0 then
        self.countDownTxt.text = lang.trans("peak_reward_tip_1", string.convertSecondToTime(time))
    else
        self.countDownTxt.text = ""
    end
end

function PeakMainView:RefreshCdTime(time)
    self.cdTxt.text = lang.trans("peak_can_challenge", string.convertSecondToTime(time))
    GameObjectHelper.FastSetActive(self.cdTxt.gameObject, time > 0)
    if time <= 0 then
        self.fireOrResetTxt.text = lang.trans("peak_fire")
        if self.cdTimer then
            self.cdTimer:Destroy()
            self.cdTimer = nil
        end
    else
        self.fireOrResetTxt.text = lang.trans("reset")
    end
end

function PeakMainView:DisActiveParticle()
    for k, v in pairs(self.particle) do
        v:SetActive(false)
    end
end

function PeakMainView:ShowParticleByPos(pos)
    self:DisActiveParticle()
    for k, v in pairs(self.particle) do
        if tonumber(k) == pos then
            v:SetActive(true)
        end
    end
end

function PeakMainView:UpdateEveryTaskRedPoint()
    local task = ReqEventModel.GetInfo("peakDailyTask")
    GameObjectHelper.FastSetActive(self.everyTaskRedPoint, tonumber(task) > 0)
end

function PeakMainView:UpdateHistoryPoint()
    local history = ReqEventModel.GetInfo("peakRecord")
    GameObjectHelper.FastSetActive(self.historyPoint, tonumber(history) > 0)
end

function PeakMainView:OnEnterScene()
    EventSystem.AddEvent("Refresh_Formation_Item", self, self.RefreshFormationItemView)
    EventSystem.AddEvent("Refresh_Cd_Time", self, self.RefreshCdTime)
    EventSystem.AddEvent("Refresh_Reward_Time", self, self.RefreshRewardTime)
    EventSystem.AddEvent("ReqEventModel_peakDailyTask", self, self.UpdateEveryTaskRedPoint)
    EventSystem.AddEvent("ReqEventModel_peakRecord", self, self.UpdateHistoryPoint)
end

function PeakMainView:OnExitScene()
    EventSystem.RemoveEvent("Refresh_Formation_Item", self, self.RefreshFormationItemView)
    EventSystem.RemoveEvent("Refresh_Cd_Time", self, self.RefreshCdTime)
    EventSystem.RemoveEvent("Refresh_Reward_Time", self, self.RefreshRewardTime)
    EventSystem.RemoveEvent("ReqEventModel_peakDailyTask", self, self.UpdateEveryTaskRedPoint)
    EventSystem.RemoveEvent("ReqEventModel_peakRecord", self, self.UpdateHistoryPoint)
    if self.cdTimer then
        self.cdTimer:Destroy()
        self.cdTimer = nil
    end
    if self.rewardTimer then
        self.rewardTimer:Destroy()
        self.rewardTimer = nil
    end
    if self.endTimer then
        self.endTimer:Destroy()
        self.endTimer = nil
    end
end

function PeakMainView:SwapTowItemPosition(sourceMess, dir)
    if self.isTweenIng then 
        return 
    end
    self.isTweenIng = true

    local sourceIndex = self.itemPositionIndex[sourceMess]
    local targetIndex =  (sourceIndex - dir < 1) and 3 or ((sourceIndex - dir > 3) and 1 or sourceIndex - dir)
    local targetMess =  self.itemPositionMess[targetIndex]
    self.itemPositionMess[targetIndex] = sourceMess
    self.itemPositionMess[sourceIndex] = targetMess
    self.itemPositionIndex[targetMess] = sourceIndex
    self.itemPositionIndex[sourceMess] = targetIndex
    self.upOrDownBtnClick(tostring(sourceIndex), tostring(targetIndex))
    --上移，移完更改深度
    self.onComplete =nil
    if dir > 0 then
        self.onComplete = function() self:SwapSiblingIndex(self.formationView[tostring(targetMess)].transform,self.formationView[tostring(sourceMess)].transform) end
    else
        self:SwapSiblingIndex(self.formationView[tostring(targetMess)].transform,self.formationView[tostring(sourceMess)].transform)
    end
    self:MyItemSwapTweening(tostring(sourceMess),tostring(targetMess),tostring(sourceIndex),tostring(targetIndex))
end

function PeakMainView:MyItemSwapTweening(sourceMess, targetMess, sourceIndex, targetIndex)
    local tweener = ShortcutExtensions.DOLocalMoveY(self.formationView[sourceMess].transform, self.formationLocalPositions[targetIndex].y, self.tweenTime)
    local tweener2 = ShortcutExtensions.DOLocalMoveY(self.formationView[targetMess].transform, self.formationLocalPositions[sourceIndex].y, self.tweenTime)
    TweenSettingsExtensions.SetEase(tweener, Ease.InOutQuad)
    TweenSettingsExtensions.SetEase(tweener2, Ease.InOutQuad)
    TweenSettingsExtensions.OnComplete(tweener, function ()  --Lua assist checked flag
        if self.onComplete then self.onComplete() end
        self.isTweenIng = false
    end)
end

function PeakMainView:SwapSiblingIndex(aTransform, bTransform)
    local mSiblingIndex = aTransform:GetSiblingIndex()
    aTransform:SetSiblingIndex(bTransform:GetSiblingIndex())
    bTransform:SetSiblingIndex(mSiblingIndex)
end

function PeakMainView:ResetFormationViewTransform()
    for k,v in pairs(self.formationView) do
        v.transform.localPosition = self.formationLocalPositions[k]
        v.transform:SetSiblingIndex(self.formationSiblingIndexs[k])
    end
    self.itemPositionMess = {1,2,3}
    self.itemPositionIndex = {1,2,3}
end

return PeakMainView

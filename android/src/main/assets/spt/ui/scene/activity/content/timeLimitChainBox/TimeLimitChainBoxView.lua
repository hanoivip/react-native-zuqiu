local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Timer = require("ui.common.Timer")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")
local TimeLimitChainBoxView = class(ActivityParentView)

function TimeLimitChainBoxView:ctor()
--------Start_Auto_Generate--------
    self.descTxt = self.___ex.descTxt
    self.timeTxt = self.___ex.timeTxt
    self.finalDescTxt = self.___ex.finalDescTxt
    self.finalNumberTxt = self.___ex.finalNumberTxt
    self.finalRewardTrans = self.___ex.finalRewardTrans
--------End_Auto_Generate----------
    self.scrollBox = self.___ex.scrollBox
    self.residualTimer = nil
end

function TimeLimitChainBoxView:OnEnterScene()
    TimeLimitChainBoxView.super.OnEnterScene(self)
    self:ResetTimer()
end

function TimeLimitChainBoxView:InitView(timeLimitChainBoxModel)
    self.timeLimitChainBoxModel = timeLimitChainBoxModel
    self:RefreshContent()
end

function TimeLimitChainBoxView:RefreshContent()
    self:ResetTimer()
    local scrollData = self.timeLimitChainBoxModel:GetScrollData()
    self.scrollBox:RegOnItemButtonClick("boxBtn", self.onBoxBtnClick)
    self.scrollBox:InitView(scrollData)
    self:BuildRewardArea()
    self.descTxt.text = self.timeLimitChainBoxModel:GetDesc()
    self.finalDescTxt.text = self.timeLimitChainBoxModel:GetFinalItemDesc()
end

function TimeLimitChainBoxView:ResetTimer()
    if self.timeLimitChainBoxModel:GetRemainTime() > 0 then
        self:RefreshTimer()
    else
        self:SetRunOutOfTimeView()
    end
end

function TimeLimitChainBoxView:RefreshTimer()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
    local remainTime = self.timeLimitChainBoxModel:GetRemainTime()
    local timeTitleStr = lang.transstr("residual_time")
    self.residualTimer = Timer.new(remainTime, function(time)
        if time <= 1 then
            self:SetRunOutOfTimeView()
            return
        else
            self.timeTxt.text = timeTitleStr .. string.convertSecondToTime(time)
        end
    end)
end

function TimeLimitChainBoxView:SetRunOutOfTimeView()
    self.timeTxt.text = lang.trans("visit_endInfo")
    if self.runOutOfTime then
        self.runOutOfTime()
    end
end

function TimeLimitChainBoxView:BuildRewardArea()
    local rewards, index = self.timeLimitChainBoxModel:GetDisplayReward()
    res.ClearChildren(self.finalRewardTrans)
    local rewardParams = {
        parentObj = self.finalRewardTrans,
        rewardData = rewards,
        isShowName = true,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)
    self.finalNumberTxt.text = tostring(index)
end

function TimeLimitChainBoxView:OnExitScene()
    TimeLimitChainBoxView.super.OnExitScene(self)
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
end

return TimeLimitChainBoxView

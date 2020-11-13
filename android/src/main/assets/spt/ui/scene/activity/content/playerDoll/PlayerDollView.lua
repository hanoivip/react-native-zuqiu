local Timer = require('ui.common.Timer')
local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local CurrencyType = require("ui.models.itemList.CurrencyType")
local EventSystem = require ("EventSystem")

local PlayerDollView = class(ActivityParentView)

function PlayerDollView:ctor()
--------Start_Auto_Generate--------
    self.middleAnim = self.___ex.middleAnim
    self.gashaponBehindGo = self.___ex.gashaponBehindGo
    self.rewardGo = self.___ex.rewardGo
    self.gashaponFrontGo = self.___ex.gashaponFrontGo
    self.imgInfoGo = self.___ex.imgInfoGo
    self.infoTxt = self.___ex.infoTxt
    self.introBtn = self.___ex.introBtn
    self.timeRemainedTxt = self.___ex.timeRemainedTxt
    self.timesTxt = self.___ex.timesTxt
    self.countRewardBtn = self.___ex.countRewardBtn
    self.timesRewardScrollViewSpt = self.___ex.timesRewardScrollViewSpt
    self.rightContentTrans = self.___ex.rightContentTrans
    self.sliderCumulativeBtn = self.___ex.sliderCumulativeBtn
    self.rewardScrollViewSpt = self.___ex.rewardScrollViewSpt
    self.leftContentTrans = self.___ex.leftContentTrans
    self.sliderRewardBtn = self.___ex.sliderRewardBtn
    self.startBtn = self.___ex.startBtn
    self.getMoreBtn = self.___ex.getMoreBtn
    self.getMoreBtnTxt = self.___ex.getMoreBtnTxt
    self.imgDiamondMoreGo = self.___ex.imgDiamondMoreGo
    self.getMoreCostTxt = self.___ex.getMoreCostTxt
    self.imgBlackDiamondMoreGo = self.___ex.imgBlackDiamondMoreGo
    self.getOneBtn = self.___ex.getOneBtn
    self.getOneBtnTxt = self.___ex.getOneBtnTxt
    self.imgDiamondOneGo = self.___ex.imgDiamondOneGo
    self.getOneCostTxt = self.___ex.getOneCostTxt
    self.imgBlackDiamondOneGo = self.___ex.imgBlackDiamondOneGo
    self.changeBtn = self.___ex.changeBtn
    self.changeDisableGo = self.___ex.changeDisableGo
--------End_Auto_Generate----------
    self.rewardImg = self.___ex.rewardImg
    self.residualTimer = nil
    self.rewardImgs = {}
    self.curImgIndex = 1
    self.rewardImgPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Image/PlayerDoll/PlayerDoll_Gashapon_%d.png"
end

function PlayerDollView:start()
    self:RegBtnEvent()
    self:ResetStart(true)
end

function PlayerDollView:InitView(playerDollModel)
    self.playerDollModel = playerDollModel
    local getOneCost = self.playerDollModel:GetOnePrice()
    self.getOneBtnTxt.text = lang.trans("timeLimit_player_doll_getTimes", 1)
    self.getOneCostTxt.text = lang.trans("timeLimit_player_doll_cost", getOneCost)
    local getFiveCost = self.playerDollModel:GetFivePrice()
    self.getMoreBtnTxt.text = lang.trans("timeLimit_player_doll_getTimes", 5)
    self.getMoreCostTxt.text = lang.trans("timeLimit_player_doll_cost", getFiveCost)
    GameObjectHelper.FastSetActive(self.rewardGo, false)
    GameObjectHelper.FastSetActive(self.changeDisableGo, self.playerDollModel:IsFirstTime())
    self.currencyType = self.playerDollModel:GetCurrencyType()
    local isDiamond = self.currencyType == CurrencyType.Diamond
    GameObjectHelper.FastSetActive(self.imgDiamondOneGo, isDiamond)
    GameObjectHelper.FastSetActive(self.imgBlackDiamondOneGo, not isDiamond)
    GameObjectHelper.FastSetActive(self.imgDiamondMoreGo, isDiamond)
    GameObjectHelper.FastSetActive(self.imgBlackDiamondMoreGo, not isDiamond)
    self:ResetDollCnt()
    self:SetSelectedRewardItems()
    self:SetCountRewardItems()
    self:ResetTimer()
    self.preState = self.playerDollModel:IsRewardsFullFilled()
end

function PlayerDollView:OnRefresh(playerDollModel)
    self:ResetTimer()
end

-- 按钮触发事件注册
function PlayerDollView:RegBtnEvent()
    self.introBtn:regOnButtonClick(function()
        self:OnBtnIntro()
    end)
    self.sliderCumulativeBtn:regOnButtonClick(function()
        self:OnBtnSliderCumulative()
    end)
    self.sliderRewardBtn:regOnButtonClick(function()
        self:OnBtnSliderReward()
    end)
    self.startBtn:regOnButtonClick(function()
        self:OnBtnStart()
    end)
    self.getMoreBtn:regOnButtonClick(function()
        self:OnBtnGet(5)
    end)
    self.getOneBtn:regOnButtonClick(function()
        self:OnBtnGet(1)
    end)
    self.changeBtn:regOnButtonClick(function()
        self:OnBtnChange()
    end)
    self.countRewardBtn:regOnButtonClick(function()
        self:OnBtnCountReward()
    end)
end

function PlayerDollView:OnBtnIntro()
    if self.onBtnIntro and type(self.onBtnIntro) == "function" then
        self.onBtnIntro()
    end
end

function PlayerDollView:OnBtnStart()
    if self.onBtnStart and type(self.onBtnStart) == "function" then
        self.onBtnStart()
    end
end

function PlayerDollView:OnBtnSliderCumulative()
    if self.onBtnSliderCumulative and type(self.onBtnSliderCumulative) == "function" then
        self.onBtnSliderCumulative()
    end
end

function PlayerDollView:OnBtnSliderReward()
    if self.onBtnSliderReward and type(self.onBtnSliderReward) == "function" then
        self.onBtnSliderReward()
    end
end

function PlayerDollView:OnBtnGet(times)
    if self.onBtnGet and type(self.onBtnGet) == "function" then
        self.onBtnGet(times)
    end
end

function PlayerDollView:OnBtnChange()
    if self.onBtnChange and type(self.onBtnChange) == "function" then
        self.onBtnChange()
    end
end

function PlayerDollView:OnBtnCountReward()
    if self.onBtnCountReward and type(self.onBtnCountReward) == "function" then
        self.onBtnCountReward()
    end
end

-- 显示选择的奖品
function PlayerDollView:SetSelectedRewardItems()
    local itemDatas = self.playerDollModel:GetSortedRewardList()
    self.rewardScrollViewSpt:InitView(itemDatas)
end

-- 显示次数任务
function PlayerDollView:SetCountRewardItems()
    local itemDatas = self.playerDollModel:GetCountRewardListSorted()
    self.timesRewardScrollViewSpt:InitView(itemDatas, self.playerDollModel)
end

-- 设置倒计时
function PlayerDollView:ResetTimer()
    if self.playerDollModel:GetRemainTime() > 0 then
        self:RefreshTimer()
    else
        self:SetRunOutOfTimeView()
    end
end

function PlayerDollView:RefreshTimer()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
    local remainTime = self.playerDollModel:GetRemainTime()
    local timeTitleStr = lang.transstr("residual_time")
    self.residualTimer = Timer.new(remainTime, function(time)
        if time <= 1 then
            self:SetRunOutOfTimeView()
            return
        else
            self.timeRemainedTxt.text = timeTitleStr .. string.convertSecondToTime(time)
        end
    end)
end

function PlayerDollView:SetRunOutOfTimeView()
    self.timeRemainedTxt.text = lang.trans("visit_endInfo")
    if self.runOutOfTime then
        self.runOutOfTime()
    end
end

function PlayerDollView:ChangeRewardImg()
    local rewardImgMaxCount = self.playerDollModel:GetRewardImgMaxCount()
    self.curImgIndex = (self.curImgIndex + 1) % rewardImgMaxCount + 1
    if not self.rewardImgs[self.curImgIndex] then
        local imgPath = string.format(self.rewardImgPath, self.curImgIndex)
        self.rewardImgs[self.curImgIndex] = res.LoadRes(imgPath)
    end
    self.rewardImg.sprite = self.rewardImgs[self.curImgIndex]
end

-- 修改奖励后重置界面显示
function PlayerDollView:ResetStart(enter)
    local isFirstTime = self.playerDollModel:IsFirstTime()
    local isRewardsFullFilled = self.playerDollModel:IsRewardsFullFilled()
    if isFirstTime then
        self.newPeriod = true
    else
        GameObjectHelper.FastSetActive(self.changeDisableGo, isFirstTime)
    end
    GameObjectHelper.FastSetActive(self.imgInfoGo, not isRewardsFullFilled)
    GameObjectHelper.FastSetActive(self.getOneBtn.gameObject, isRewardsFullFilled)
    GameObjectHelper.FastSetActive(self.getMoreBtn.gameObject, isRewardsFullFilled)
    GameObjectHelper.FastSetActive(self.gashaponBehindGo, isRewardsFullFilled)
    GameObjectHelper.FastSetActive(self.gashaponFrontGo, isRewardsFullFilled)
    if not isRewardsFullFilled then
        if not enter then
            DialogManager.ShowToast(lang.trans("timeLimit_player_doll_rewardPoolNotice"))
        end
        if isFirstTime then
            self.infoTxt.text = lang.trans("timeLimit_player_doll_info")
        else
            self.infoTxt.text = lang.trans("timeLimit_player_doll_info_2")
        end
    else 
        if not enter and self.preState then
            DialogManager.ShowToast(lang.trans("timeLimit_player_doll_changes"))
        end
    end
    self.preState = self.playerDollModel:IsRewardsFullFilled()
end

-- 刷新次数显示
function PlayerDollView:ResetDollCnt()
    local dollCnt = self.playerDollModel:GetDollCnt()
    self.timesTxt.text = lang.trans("timeLimit_player_doll_times", dollCnt)
end

function PlayerDollView:ChangeRewardEvent(enter)
    self:SetSelectedRewardItems()
    self:ResetStart(enter)
end

function PlayerDollView:StartEvent()
    self:ResetDollCnt()
    self:SetCountRewardItems()
end

function PlayerDollView:OnEnterScene()
    self.super.OnEnterScene(self)
    EventSystem.AddEvent("PlayerDoll_ChangeReward", self, self.ChangeRewardEvent)
    EventSystem.AddEvent("PlayerDoll_Start", self, self.StartEvent)
    EventSystem.AddEvent("PlayerDoll_Receive", self, self.SetCountRewardItems)
end

function PlayerDollView:OnExitScene()
    self.super.OnExitScene(self)
    EventSystem.RemoveEvent("PlayerDoll_ChangeReward", self, self.ChangeRewardEvent)
    EventSystem.RemoveEvent("PlayerDoll_Start", self, self.StartEvent)
    EventSystem.RemoveEvent("PlayerDoll_Receive", self, self.SetCountRewardItems)
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
end

return PlayerDollView

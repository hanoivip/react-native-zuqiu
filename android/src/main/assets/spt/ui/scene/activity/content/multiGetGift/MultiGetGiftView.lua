local Timer = require("ui.common.Timer")
local DialogManager = require("ui.control.manager.DialogManager")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")
local SimpleIntroduceModel = require("ui.models.common.SimpleIntroduceModel")
local MultiGetGiftView = class(ActivityParentView, "MultiGetGiftView")

local TabTag = {}
TabTag.DayGift = "dayGift"
TabTag.Task = "task"
TabTag.Store = "store"

local DefaultTabTag = TabTag.DayGift

function MultiGetGiftView:ctor()
--------Start_Auto_Generate--------
    self.timeRemainedTxt = self.___ex.timeRemainedTxt
    self.helpBtn = self.___ex.helpBtn
    self.tabGroupSpt = self.___ex.tabGroupSpt
    self.dayGiftRedPointGo = self.___ex.dayGiftRedPointGo
    self.taskRedPointGo = self.___ex.taskRedPointGo
    self.activityEndGo = self.___ex.activityEndGo
    self.endDayGiftBtn = self.___ex.endDayGiftBtn
    self.endTaskBtn = self.___ex.endTaskBtn
    self.giftContentGo = self.___ex.giftContentGo
    self.scoreTxt = self.___ex.scoreTxt
    self.getAllRewardBtn = self.___ex.getAllRewardBtn
    self.giftScrollSpt = self.___ex.giftScrollSpt
    self.scoreTxt = self.___ex.scoreTxt
    self.itemAreaTrans = self.___ex.itemAreaTrans
    self.giftBoxImg = self.___ex.giftBoxImg
    self.rewardBtn = self.___ex.rewardBtn
    self.lockGo = self.___ex.lockGo
    self.timeTipTxt = self.___ex.timeTipTxt
    self.receivedGo = self.___ex.receivedGo
    self.taskContentGo = self.___ex.taskContentGo
    self.taskScrollSpt = self.___ex.taskScrollSpt
    self.itemAreaTrans = self.___ex.itemAreaTrans
    self.storeContentGo = self.___ex.storeContentGo
    self.storeScrollSpt = self.___ex.storeScrollSpt
    self.itemNameTxt = self.___ex.itemNameTxt
    self.itemLimitTxt = self.___ex.itemLimitTxt
    self.itemAreaTrans = self.___ex.itemAreaTrans
    self.rewardBtn = self.___ex.rewardBtn
    self.priceTxt = self.___ex.priceTxt
    self.coinTxt = self.___ex.coinTxt
--------End_Auto_Generate----------
    self.giftScrollRect = self.___ex.giftScrollRect
end

function MultiGetGiftView:start()
    self.getAllRewardBtn:regOnButtonClick(function()
        self:GetAllRewardBtnClick()
    end)
    self.helpBtn:regOnButtonClick(function()
        self:HelpBtnClick()
    end)
    self.endDayGiftBtn:regOnButtonClick(function()
        self:ShowEndTip()
    end)
    self.endTaskBtn:regOnButtonClick(function()
        self:ShowEndTip()
    end)
end

function MultiGetGiftView:InitView(multiGetGiftModel)
    self.model = multiGetGiftModel
    self:ResetTab()
    self:ResetTimer()
    self:InitRedPoint()
end

function MultiGetGiftView:RefreshContent()
    self:InitTaskArea()
    self:InitRedPoint()
end

-- 页签初始化
function MultiGetGiftView:ResetTab()
    for i, v in pairs(self.tabGroupSpt.menu) do
        self.tabGroupSpt:BindMenuItem(i, function()
            self:OnTabClick(i)
        end)
    end
    local showRemainTime = self.model:GetShowRemainTime()
    GameObjectHelper.FastSetActive(self.activityEndGo, showRemainTime < 2)
    if showRemainTime < 2 then
        DefaultTabTag = TabTag.Store
    end
    self.tabGroupSpt:selectMenuItem(DefaultTabTag)
    self:OnTabClick(DefaultTabTag)
end

-- 页签点击
function MultiGetGiftView:OnTabClick(tag)
    local showRemainTime = self.model:GetShowRemainTime()
    if showRemainTime < 2 and tag ~= TabTag.Store then
        DialogManager.ShowToastByLang("visit_endInfo")
        self.tabGroupSpt:selectMenuItem(TabTag.Store)
        return
    end
    GameObjectHelper.FastSetActive(self.giftContentGo, tag == TabTag.DayGift)
    GameObjectHelper.FastSetActive(self.taskContentGo, tag == TabTag.Task)
    GameObjectHelper.FastSetActive(self.storeContentGo, tag == TabTag.Store)
    if tag == TabTag.DayGift then
        self:InitDayGiftArea()
    elseif tag == TabTag.Task then
        self:InitTaskArea()
    elseif tag == TabTag.Store then
        self:InitStoreArea()
    end
end

-- 每日礼盒
function MultiGetGiftView:InitDayGiftArea()
    local dayGiftList = self.model:GetDayRewardList()
    local score = self.model:GetScore()
    self.giftScrollSpt:InitView(dayGiftList, self.model, self.giftScrollRect)
    self.scoreTxt.text = "x" .. score
    self:InitRedPoint()
end

-- 每日任务
function MultiGetGiftView:InitTaskArea()
    local taskList = self.model:GetTaskModelList()
    self.taskScrollSpt:InitView(taskList, function(taskData)
        self:OnTaskReceive(taskData)
    end)
end

-- 商店
function MultiGetGiftView:InitStoreArea()
    local storeList = self.model:GetStoreList()
    local coin = self.model:GetCoin()
    self.storeScrollSpt:InitView(storeList, self.model, function(subID)
        self:OnStoreItemBuy(subID)
    end)
    self.coinTxt.text = "x" .. coin
end

-- 红点
function MultiGetGiftView:InitRedPoint()
    local showRemainTime = self.model:GetShowRemainTime()
    if showRemainTime < 3 then
        GameObjectHelper.FastSetActive(self.dayGiftRedPointGo, false)
        GameObjectHelper.FastSetActive(self.taskRedPointGo, false)
        return
    end
    local giftRedPoint = self.model:GetGiftRedPoint()
    local taskRedPoint = self.model:GetTaskRedPoint()
    GameObjectHelper.FastSetActive(self.dayGiftRedPointGo, giftRedPoint)
    GameObjectHelper.FastSetActive(self.taskRedPointGo, taskRedPoint)
end

-- 设置倒计时
function MultiGetGiftView:ResetTimer()
    if self.model:GetRemainTime() > 0 then
        self:RefreshTimer()
    else
        self:SetRunOutOfTimeView()
    end
end

function MultiGetGiftView:RefreshTimer()
    local timeStr
    local showRemainTime = self.model:GetShowRemainTime()
    local beginTime = self.model:GetBeginTime()
    local beginStr = string.convertSecondToMonth(beginTime)
    if showRemainTime > 2 then
        local endTime = self.model:GetShowEndTime()
        local endStr = string.convertSecondToMonth(endTime)
        timeStr = lang.trans("cumulative_pay_time", beginStr, endStr)
        self.residualTimer = Timer.new(showRemainTime, function(time)
            if time < 2 then
                endTime = self.model:GetEndTime()
                endStr = string.convertSecondToMonth(endTime)
                timeStr = lang.trans("multi_get_exchange_time", beginStr, endStr)
                self.timeRemainedTxt.text = timeStr
                self.tabGroupSpt:selectMenuItem(TabTag.Store)
                self:OnTabClick(TabTag.Store)
                self:InitRedPoint()
            end
        end)
    else
        local endTime = self.model:GetEndTime()
        local endStr = string.convertSecondToMonth(endTime)
        timeStr = lang.trans("multi_get_exchange_time", beginStr, endStr)
    end
    self.timeRemainedTxt.text = timeStr
end

function MultiGetGiftView:SetRunOutOfTimeView()
    self.timeRemainedTxt.text = lang.trans("visit_endInfo")
    if self.runOutOfTime then
        self.runOutOfTime()
    end
end

-- 领取每日奖励
function MultiGetGiftView:OnGiftItemReceived()
    local coin = self.model:GetCoin()
    self.coinTxt.text = "x" .. coin
    self:InitRedPoint()
end

-- 领所有每日奖励
function MultiGetGiftView:GetAllRewardBtnClick()
    if self.getAllReward then
        self.getAllReward()
    end
    self:InitRedPoint()
end

-- 领任务
function MultiGetGiftView:OnTaskReceive(taskData)
    self.scoreTxt.text = "x" .. taskData.scoreReward
    self.model:RefreshTaskData(taskData)
    self:InitTaskArea()
    self:InitRedPoint()
end

-- 商店购买
function MultiGetGiftView:OnStoreItemBuy()
    local coin = self.model:GetCoin()
    self.coinTxt.text = "x" .. coin
end

-- 说明
function MultiGetGiftView:HelpBtnClick()
    local simpleIntroduceModel = SimpleIntroduceModel.new(self.model:GetIntro())
    res.PushDialog("ui.controllers.common.SimpleIntroduceCtrl", simpleIntroduceModel)
end

function MultiGetGiftView:ShowEndTip()
    DialogManager.ShowToastByLang("multi_get_end")
end

function MultiGetGiftView:OnEnterScene()
    self.super.OnEnterScene(self)
    EventSystem.AddEvent("MGDayGiftItemView_Receive", self, self.OnGiftItemReceived)
    EventSystem.AddEvent("MGStoreItemView_Buy", self, self.OnStoreItemBuy)
end

function MultiGetGiftView:OnExitScene()
    self.super.OnExitScene(self)
    EventSystem.RemoveEvent("MGDayGiftItemView_Receive", self, self.OnGiftItemReceived)
    EventSystem.RemoveEvent("MGStoreItemView_Buy", self, self.OnStoreItemBuy)
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
end

function MultiGetGiftView:onDestroy()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
end

return MultiGetGiftView

local DialogManager = require("ui.control.manager.DialogManager")
local ReqEventModel = require("ui.models.event.ReqEventModel")
local CoachHelper = require("ui.scene.coach.common.CoachHelper")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CommonConstants = require("ui.common.CommonConstants")
local SimpleIntroduceModel = require("ui.models.common.SimpleIntroduceModel")
local AssetFinder = require("ui.common.AssetFinder")

local CoachTaskView = class(unity.base)

-- 教练星级和等级的prefab
local CoachLevelPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/Common/Prefabs/CoachLevel.prefab"

function CoachTaskView:ctor()
    -- 顶部信息条框
    self.infoBarBox = self.___ex.infoBarBox
    -- 可接受任务列表scroll
    self.taskListScroll = self.___ex.taskListScroll
    self.acceptBtn = self.___ex.acceptBtn
    self.executingBtn = self.___ex.executingBtn
    self.redeemAllBtn = self.___ex.redeemAllBtn
    self.refreshBtn = self.___ex.refreshBtn
    self.freeCountTxt = self.___ex.freeCountTxt
    self.refreshDiamondGo = self.___ex.refreshDiamondGo
    self.diamondCountTxt = self.___ex.diamondCountTxt
    self.runingTxt = self.___ex.runingTxt
    self.allCountTxt = self.___ex.allCountTxt
    self.buyCountBtn = self.___ex.buyCountBtn
    self.coachLevelTrans = self.___ex.coachLevelTrans
    self.scrollRect = self.___ex.scrollRect
    self.helpBtn = self.___ex.helpBtn
    self.canBuyGo = self.___ex.canBuyGo
    self.canNotBuyGo = self.___ex.canNotBuyGo
    self.redeemAllButton = self.___ex.redeemAllButton
end

function CoachTaskView:start()
    self.acceptBtn:regOnButtonClick(function() self:OnAcceptTabClick() end)
    self.executingBtn:regOnButtonClick(function() self:OnExecutingTabClick() end)
    self.redeemAllBtn:regOnButtonClick(function() self:OnRedeemAllClick() end)
    self.refreshBtn:regOnButtonClick(function() self:OnRefreshClick() end)
    self.buyCountBtn:regOnButtonClick(function() self:OnBuyCountClick() end)
    self.helpBtn:regOnButtonClick(function() self:OnHelpClick() end)
end


function CoachTaskView:InitView(coachTaskModel)
    self.coachTaskModel = coachTaskModel
    self.taskListScroll:RegOnItemButtonClick("rewardBtn", self.onRewardClick)
    self.taskListScroll:RegOnItemButtonClick("unacceptedBtn", self.onTaskDetailClick)

    if not self.coachLevelSpt then
        local coachLevelObj, coachLevelSpt = res.Instantiate(CoachLevelPath)
        self.coachLevelSpt = coachLevelSpt
        coachLevelObj.transform:SetParent(self.coachLevelTrans, false)
    end

    self:OnAcceptTabClick()
    self:RefreshTaskCountArea()
    self:RefreshLevelArea()
end

function CoachTaskView:OnAcceptTabClick()
    local taskList = self.coachTaskModel:GetTaskList()
    self.taskListScroll:InitView(taskList, self.coachTaskModel)
    self:ChangeTabState(true)
end

function CoachTaskView:OnExecutingTabClick()
    local executingTaskList = self.coachTaskModel:GetExecutingTaskList()
    self.taskListScroll:InitView(executingTaskList, self.coachTaskModel)
    self:ChangeTabState(false)
end

function CoachTaskView:RegOnDynamicLoad(func)
    self.infoBarBox:RegOnDynamicLoad(func)
end

function CoachTaskView:ChangeTabState(tabState)
    self.tabState = tabState
    self.acceptBtn:ChangeState(tabState)
    self.executingBtn:ChangeState(not tabState)
    GameObjectHelper.FastSetActive(self.refreshBtn.gameObject, tabState)
    GameObjectHelper.FastSetActive(self.redeemAllBtn.gameObject, not tabState)
    self.scrollRect.enabled = (not tabState)
end

function CoachTaskView:RefreshContent()
    if self.tabState then
        self:OnAcceptTabClick()
    else
        self:OnExecutingTabClick()
    end
    self:RefreshTaskCountArea()
end

function CoachTaskView:RefreshTaskCountArea()
    local refreshCount = self.coachTaskModel:GetRefreshCount()
    local freshPrice = self.coachTaskModel:GetFreshPrice()
    local freshAmount = self.coachTaskModel:GetFreshAmount()
    local currentMaxDailyMission = self.coachTaskModel:GetCurrentMaxDailyMission()
    local maxCoachMission = self.coachTaskModel:GetMaxCoachMission()
    local executingAndRewardCount = self.coachTaskModel:GetExecutingAndRewardCount()
    local acceptCount = self.coachTaskModel:GetAcceptCount()
    local isNeedDiamond = self.coachTaskModel:IsNeedDiamond()
    local isCanBuyCount = self.coachTaskModel:IsCanBuyCount()
    local isHasTaskCanRedeem = self.coachTaskModel:IsHasTaskCanRedeem()

    GameObjectHelper.FastSetActive(self.refreshDiamondGo, isNeedDiamond)
    GameObjectHelper.FastSetActive(self.freeCountTxt.gameObject, not isNeedDiamond)
    GameObjectHelper.FastSetActive(self.canBuyGo, isCanBuyCount)
    GameObjectHelper.FastSetActive(self.canNotBuyGo, not isCanBuyCount)

    if isNeedDiamond then
        self.diamondCountTxt.text = "x" .. freshPrice
    else
        self.freeCountTxt.text = lang.trans("coach_task_free", freshAmount - refreshCount)
    end

    self.runingTxt.text = lang.trans("coach_task_execut_title", executingAndRewardCount, maxCoachMission)
    self.allCountTxt.text = lang.trans("coach_task_today", currentMaxDailyMission - acceptCount)
    self.redeemAllButton.interactable = isHasTaskCanRedeem
end

function CoachTaskView:RefreshLevelArea()
    local credentialLevel = self.coachTaskModel:GetCoachLevel()
    local starLevel = self.coachTaskModel:GetStarLevel()
    self.coachLevelSpt:InitView(credentialLevel, starLevel)
end

--- 注册事件
function CoachTaskView:RegisterEvent()
    -- EventSystem.AddEvent("QuestPageView.RefreshChapterPage", self, self.RefreshChapterPage)
end

--- 移除事件
function CoachTaskView:RemoveEvent()
    -- EventSystem.RemoveEvent("QuestPageView.RefreshChapterPage", self, self.RefreshChapterPage)
end

function CoachTaskView:OnRedeemAllClick()
    if self.onRedeemAllClick then
        self.onRedeemAllClick()
    end
end

function CoachTaskView:OnRefreshClick()
    if self.onRefreshClick then
        self.onRefreshClick()
    end
end

function CoachTaskView:OnBuyCountClick()
    if self.onBuyCountClick then
        self.onBuyCountClick()
    end
end

function CoachTaskView:OnHelpClick()
    local config = CoachHelper.Explain.CoachMission
    local simpleIntroduceModel = SimpleIntroduceModel.new()
    simpleIntroduceModel:InitModel(config.id, config.descID)
    res.PushDialog("ui.controllers.common.SimpleIntroduceCtrl", simpleIntroduceModel)
end

function CoachTaskView:onDestroy()
    self:RemoveEvent()
end

function CoachTaskView:IsShowFinishBubble()
    local letter = ReqEventModel.GetInfo("letterFinish")
    GameObjectHelper.FastSetActive(self.commonTip, tonumber(letter) > 0)
end

return CoachTaskView

local RewardListView = class(unity.base)
local ButtonColorConfig = require("ui.common.ButtonColorConfig")
local EventSystem = require("EventSystem")
local ButtonColorConfig = require("ui.common.ButtonColorConfig")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local TASK_TYPE = require("ui.controllers.rewards.TASK_TYPE")

local TASK_MAP = {
    [TASK_TYPE.DAILY] = "daily",
    [TASK_TYPE.MAIN] = "main",
    [TASK_TYPE.NEW] = "new"
}

local TASKREVERSE_MAP = {
    ["daily"] = TASK_TYPE.DAILY,
    ["main"] = TASK_TYPE.MAIN,
    ["new"] = TASK_TYPE.NEW
}

function RewardListView:ctor()
    self.close = self.___ex.close
    self.taskButtonGroup = self.___ex.taskButtonGroup
    self.scrollView = self.___ex.scrollView
    self.newBieTip = self.___ex.newBieTip
    self.mainlineTip = self.___ex.mainlineTip
    self.dailyTip = self.___ex.dailyTip
    self.scrollRect = self.___ex.scrollRect
    self.newObject = self.___ex.newObject
    self.newTextGradient = self.___ex.newTextGradient
    self.dailyTextGradient = self.___ex.dailyTextGradient
    self.mainTextGradient = self.___ex.mainTextGradient

    self.scrollView.clickReward = function(rewardID) self:OnReceiveClick(rewardID) end
    self:IsShowDisplayArea(false)
end

function RewardListView:OnReceiveClick(rewardID)
    if self.clickReward then
        self.clickReward(rewardID)
    end
end

function RewardListView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
            -- 关闭奖励列表
            -- GuideManager.Show(res.curSceneInfo.ctrl)
        end
    end)
end

function RewardListView:start()
    DialogAnimation.Appear(self.transform)
    self.close:regOnButtonClick(function()
        self:Close()
    end)

    local tasksMenu = self.taskButtonGroup.menu
    for key, v in pairs(tasksMenu) do
        v:regOnButtonClick(function()
            self:OnTaskTypeClick(TASKREVERSE_MAP[key])
        end)
    end

    EventSystem.AddEvent("RewardListModel_SetRewardReceiced", self, self.EventRewardReceived)
    EventSystem.AddEvent("TransferMarketModel_RefreshTransferMarketModel", self, self.ChargeToRewardCallback)
end

function RewardListView:IsShowDisplayArea(isShow)
    GameObjectHelper.FastSetActive(self.taskButtonGroup.gameObject, isShow)
end

function RewardListView:InitView(taskType, isShowNewTask)
    GameObjectHelper.FastSetActive(self.newObject.gameObject, isShowNewTask)
    self:IsShowDisplayArea(true)
    self.taskButtonGroup:selectMenuItem(TASK_MAP[taskType])
end

function RewardListView:RefreshTip(newBieBool, mainlineBool, dailyBool, isShowNewTask)
    local mainTip
    local dailyTip
    mainTip = self.mainlineTip
    dailyTip = self.dailyTip

    self.newBieTip:SetActive(newBieBool)
    mainTip:SetActive(mainlineBool)
    dailyTip:SetActive(dailyBool)
end

function RewardListView:RefreshView(data, currentTaskType)
    self.scrollView:InitView(data)
    
    local selectText
    if currentTaskType == TASK_TYPE.NEW then 
        selectText = self.newTextGradient
    elseif currentTaskType == TASK_TYPE.DAILY then
        selectText = self.dailyTextGradient
    elseif currentTaskType == TASK_TYPE.MAIN then
        selectText = self.mainTextGradient
    end
    ButtonColorConfig.SetNormalGradientColor(selectText)
    if self.preSelectText then 
        ButtonColorConfig.SetDisableGradientColor(self.preSelectText)
    end
    self.preSelectText = selectText
end

function RewardListView:OnTaskTypeClick(index)
    if self.clickTaskType then
        self.clickTaskType(index)
    end
end

function RewardListView:EventRewardReceived(rewardID)
    if self.rewardReceivedCallBack then
        self.rewardReceivedCallBack(rewardID)
    end
end

function RewardListView:ChargeToRewardCallback()
    if self.onChargeToRewardCallback then
        self.onChargeToRewardCallback()
    end
end

function RewardListView:onDestroy()
    EventSystem.RemoveEvent("RewardListModel_SetRewardReceiced", self, self.EventRewardReceived)
    EventSystem.RemoveEvent("TransferMarketModel_RefreshTransferMarketModel", self, self.ChargeToRewardCallback)
end

function RewardListView:ControlScrollRect()
    if GuideManager.GuideIsOnGoing("main") then
        self.scrollRect.enabled = false
    else
        self.scrollRect.enabled = true
    end
end

return RewardListView

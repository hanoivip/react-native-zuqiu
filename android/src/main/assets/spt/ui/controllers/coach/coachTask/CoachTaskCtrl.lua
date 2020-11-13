local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local CoachTaskModel = require("ui.models.coach.coachTask.CoachTaskModel")
local CoachTaskDetailModel = require("ui.models.coach.coachTask.CoachTaskDetailModel")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local CoachTaskCtrl = class(BaseCtrl)

CoachTaskCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/CoachTask/CoachTaskBoard.prefab"

function CoachTaskCtrl:Init()
    self.view:RegOnDynamicLoad(function (child)
        local infoBarCtrl = InfoBarCtrl.new(child, self)
        infoBarCtrl:RegOnBtnBack(function ()
            self.view:coroutine(function()
                unity.waitForEndOfFrame()
                res.PopSceneImmediate()
            end)
        end)
    end)
    self.view.onRewardClick = function(taskData) self:OnClickBtnReward(taskData) end
    self.view.onTaskDetailClick = function(taskData) self:OnClickBtnTaskDetail(taskData) end
    self.view.onRedeemAllClick = function() self:OnClickBtnRedeemAll() end
    self.view.onRefreshClick = function() self:OnClickRefresh() end
    self.view.onBuyCountClick = function() self:OnClickBuyCount() end
end

function CoachTaskCtrl:Refresh()
    CoachTaskCtrl.super.Refresh(self)
    self.view:InitView(self.coachTaskModel)
    GuideManager.Show(self)
end

function CoachTaskCtrl:AheadRequest()
    local response = req.coachGetMissionInfo()
    if api.success(response) then
        local data = response.val
        self.coachTaskModel = CoachTaskModel.new()
        self.coachTaskModel:InitWithProtocol(data)
    end
end

function CoachTaskCtrl:OnClickBtnReward(taskData)
    local taskId = taskData.id
    self.view:coroutine(function()
        local response = req.coachGetMissionReward(taskId)
        if api.success(response) then
            local data = response.val
            self.coachTaskModel:RefreshRewardData(data)
            CongratulationsPageCtrl.new(data.contents)
            self.view:RefreshContent()
        end
    end)
end

function CoachTaskCtrl:OnClickRefresh()
    local isNeedDiamond = self.coachTaskModel:IsNeedDiamond()
    if isNeedDiamond then
        local costDiamond = self.coachTaskModel:GetFreshPrice()
        CostDiamondHelper.CostDiamond(costDiamond, self.view, function()
            local contents = lang.trans("coach_task_tip_refresh", costDiamond)
            DialogManager.ShowConfirmPop(lang.trans("tips"), contents, function() self:RefreshRequest() end)
        end)
    else
        self:RefreshRequest()
    end
end

function CoachTaskCtrl:RefreshRequest()
    self.view:coroutine(function()
        local response = req.coachRefreshMission()
        if api.success(response) then
            local data = response.val
            self.coachTaskModel:RefreshTaskList(data)
            self.view:RefreshContent()
            local playerInfoModel = PlayerInfoModel.new()
            playerInfoModel:SetDiamond(data.d)
            DialogManager.ShowToastByLang("coach_task_refresh_success")
        end
    end)
end

function CoachTaskCtrl:OnClickBtnTaskDetail(taskData)
    local coachTaskDetailModel = CoachTaskDetailModel.new(taskData, self.coachTaskModel)
    res.PushDialog("ui.controllers.coach.coachTask.CoachTaskDetailCtrl", coachTaskDetailModel)
end

function CoachTaskCtrl:OnClickBtnRedeemAll()
    local isHasTaskCanRedeem = self.coachTaskModel:IsHasTaskCanRedeem()
    if not isHasTaskCanRedeem then
        DialogManager.ShowToastByLang("coach_task_no_reward")
        return
    end
    self.view:coroutine(function()
        local response = req.coachGetAllMissionReward()
        if api.success(response) then
            local data = response.val
            self.coachTaskModel:RefreshRedeemAllData(data)
            CongratulationsPageCtrl.new(data.contents)
            self.view:RefreshContent()
        end
    end)
end

function CoachTaskCtrl:OnClickBuyCount()
    local isCanBuyCount = self.coachTaskModel:IsCanBuyCount()
    if not isCanBuyCount then
        DialogManager.ShowToastByLang("peak_bought_time_none")
        return
    end
    local costDiamond = self.coachTaskModel:GetBuyCountPrice()
    CostDiamondHelper.CostDiamond(costDiamond, self.view, function()
        local contents = lang.trans("coach_task_tip_buycount", costDiamond)
        DialogManager.ShowConfirmPop(lang.trans("tips"), contents, function() self:BuyCountRequest() end)
    end)
end

function CoachTaskCtrl:BuyCountRequest()
    self.view:coroutine(function()
        local response = req.coachBuyMissionTimes()
        if api.success(response) then
            local data = response.val
            self.coachTaskModel:RefreshBuyCount(data)
            local playerInfoModel = PlayerInfoModel.new()
            playerInfoModel:SetDiamond(data.d)
            self.view:RefreshContent()
            DialogManager.ShowToastByLang("buy_item_success")
        end
    end)
end

function CoachTaskCtrl:OnAcceptClick(data)
    self.coachTaskModel:RefreshTaskData(data)
    self.view:RefreshContent()
    DialogManager.ShowToastByLang("coach_task_accept_success")
end

function CoachTaskCtrl:RequestRefreshView()
    self.view:coroutine(function()
        local response = req.coachGetMissionInfo()
        if api.success(response) then
            local data = response.val
            self.coachTaskModel:InitWithProtocol(data)
            self.view:RefreshContent()
        end
    end)
end

--- 注册事件
function CoachTaskCtrl:RegisterEvent()
    EventSystem.AddEvent("CoachTaskDetailCtrl_OnAcceptClick", self, self.OnAcceptClick)
    EventSystem.AddEvent("CoachTaskCtrl_TaskTimeOut", self, self.RequestRefreshView)
end

--- 移除事件
function CoachTaskCtrl:RemoveEvent()
    EventSystem.RemoveEvent("CoachTaskDetailCtrl_OnAcceptClick", self, self.OnAcceptClick)
    EventSystem.RemoveEvent("CoachTaskCtrl_TaskTimeOut", self, self.RequestRefreshView)
end

function CoachTaskCtrl:OnEnterScene()
    self:RegisterEvent()
end

function CoachTaskCtrl:OnExitScene()
    self:RemoveEvent()
end

return CoachTaskCtrl

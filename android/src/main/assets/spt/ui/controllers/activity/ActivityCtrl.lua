local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local ActivityListModel = require("ui.models.activity.ActivityListModel")
local ActivityLabelCtrl = require("ui.controllers.activity.ActivityLabelCtrl")
local ActivityContentCtrl = require("ui.controllers.activity.ActivityContentCtrl")
local ActivityRes = require("ui.scene.activity.ActivityRes")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local WaitForSeconds = clr.UnityEngine.WaitForSeconds
local ActivityCtrl = class(BaseCtrl, "ActivityCtrl")
ActivityCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/ActivityCanvas.prefab"

function ActivityCtrl:Init()
    self.view:RegOnDynamicLoad(function (child)
        self.infoBarCtrl = InfoBarCtrl.new(child, self, false, true)
        self.infoBarCtrl:RegOnBtnBack(function()
            self.view:PlayLeaveAnimation()
        end)
    end)

    self.view.onAnimationLevelComplete = function()
        clr.coroutine(function()
            unity.waitForEndOfFrame()
            res.PopSceneImmediate()
        end)
    end
end

-- 在每次重新进入活动界面时重新刷新服务器数据
function ActivityCtrl:PostMessage(activityType)
    local activityRes = ActivityRes.new()
    clr.coroutine(function()
        local response = req.activityList()
        if api.success(response) then
            local data = response.val
            local list = data and data.list
            self.activityListModel = ActivityListModel.new(activityRes)
            self.activityListModel:InitWithProtocol(list)
            self.activityContentCtrl = ActivityContentCtrl.new(self.view.contentRect, activityRes, self.activityListModel)
            self.activityLabelCtrl = ActivityLabelCtrl.new(self.view.scroll, self, activityRes, self.activityListModel)
            if activityType == nil then
                activityType = self.activityListModel:GetSelectActivityType()
            end
            local activityIndex, isExist = self.activityListModel:GetActivityIndex(activityType)
            self.activityLabelCtrl:InitView(activityIndex)
            self:IsActivityExist(isExist)
            self:StartTimer()
        end
    end)
end

function ActivityCtrl:Clear()
    self.view:Clear()
end

-- 更新数据后关掉之前实例的弹窗界面
function ActivityCtrl:IsActivityExist(isExist)
    if not isExist then 
        local dialogs = res.curSceneInfo and res.curSceneInfo.dialogs
        if type(dialogs) == "table" then 
            for i, v in ipairs(dialogs) do
                if v.view then 
                    v.view:closeDialog()
                end
            end
        end
    end
end

function ActivityCtrl:RefreshContent(selectIndex)
    self.activityContentCtrl:ShowActivityContent(selectIndex)
end

function ActivityCtrl:OnEnterScene()
    self.canAskFor = true
    EventSystem.AddEvent("Charge_Success", self, self.ResetActivityModel)
    EventSystem.AddEvent("ConsumeDiamond", self, self.ResetActivityModel)
    EventSystem.AddEvent("ConsumeBlackDiamond", self, self.ResetActivityModel)
    EventSystem.AddEvent("PlayerInfoModel_SetMoney", self, self.ResetActivityModel)
    if self.activityContentCtrl then 
        self.activityContentCtrl:OnEnterScene()
    end
end

function ActivityCtrl:OnExitScene()
    EventSystem.RemoveEvent("Charge_Success", self, self.ResetActivityModel)
    EventSystem.RemoveEvent("ConsumeDiamond", self, self.ResetActivityModel)
    EventSystem.RemoveEvent("ConsumeBlackDiamond", self, self.ResetActivityModel)
    EventSystem.RemoveEvent("PlayerInfoModel_SetMoney", self, self.ResetActivityModel)
    local activityType = self:GetActivityType()
    self.activityListModel:SetSelectActivityType(activityType)
    if self.activityContentCtrl then 
        self.activityContentCtrl:OnExitScene()
    end
    self:StopTimer()
    self:Clear()
end

function ActivityCtrl:RefreshCurActivityView()
    local selectActivityType = self:GetActivityType()
    local activityModels = self.activityListModel:GetActivityModelsByActivityType(selectActivityType)
    if activityModels and type(activityModels) == "table" then
        for i, v in pairs(activityModels) do
            local activityView = v:GetActivityView()
            if activityView and activityView.RefreshContent then
                activityView:RefreshContent()
            end
        end
    end
end

function ActivityCtrl:ResetActivityModel()
    if not self.canAskFor then return end
    self.canAskFor = false
    clr.coroutine(function()
        coroutine.yield(WaitForSeconds(0.01))
        local response = req.activityList(nil, nil, true)
        if api.success(response) then
            local data = response.val
            local list = data and data.list
            ActivityListModel.new(ActivityRes.new()):RefreshData(list)
            self:RefreshCurActivityView()
        end
        self.canAskFor = true
    end)
end

function ActivityCtrl:Refresh(activityType)
    ActivityCtrl.super.Refresh(self)
    if self.infoBarCtrl then
        self.infoBarCtrl:Refresh()
    end
    self:PostMessage(activityType)
end

function ActivityCtrl:GetStatusData()
    return self:GetActivityType()
end

function ActivityCtrl:GetActivityType()
    local labelModel = self.activityLabelCtrl:GetLabelModel()
    local selectIndex = labelModel:GetSelectLabel()
    local activityType = self.activityListModel:GetActivityType(selectIndex)
    return activityType
end

function ActivityCtrl:StartTimer()
    local activityDataModelMap = self.activityListModel:GetActivityDataMap()
    for activityType, ModelsWithActivityType in pairs(activityDataModelMap) do
        for activityId, ModelWithActivityId in pairs(ModelsWithActivityType) do
            if ModelWithActivityId.hasTimer then
                ModelWithActivityId:StartTimer()
            end
        end
    end
end

function ActivityCtrl:StopTimer()
    if self.activityListModel then
        local activityDataModelMap = self.activityListModel:GetActivityDataMap()
        for activityType, ModelsWithActivityType in pairs(activityDataModelMap) do
            for activityId, ModelWithActivityId in pairs(ModelsWithActivityType) do
                if ModelWithActivityId.hasTimer then
                    ModelWithActivityId:StopTimer()
                end
            end
        end
    end
end

return ActivityCtrl

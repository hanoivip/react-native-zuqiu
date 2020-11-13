local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local DialogManager = require("ui.control.manager.DialogManager")
local ActivityListModel = require("ui.models.activity.ActivityListModel")
local ActivityRes = require("ui.scene.activity.ActivityRes")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local BayernLuckyDrawCtrl = class(ActivityContentBaseCtrl)


function BayernLuckyDrawCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)
    self.view:InitView(self.activityModel)
    self.view.clickFreeDraw = function() self:ClickFreeDraw() end
end

function BayernLuckyDrawCtrl:OnRefresh()
end

function BayernLuckyDrawCtrl:ClickFreeDraw()
    local playerInfoModel = PlayerInfoModel.new()
    local playerLevel = playerInfoModel:GetLevel()
    local titleText = lang.trans("tips")

    local contentTextLevelNoEnough = lang.trans("bayernActivity_Not_EnoughLevel", self.activityModel:GetActivityNeedLevel(1))
    if self.activityModel:GetActivityNeedLevel(1) == nil then
        clr.coroutine(function()
            local response = req.activityBayernLuckyDraw(self.activityModel:GetActivityType(), self.activityModel:GetActivityId())
            if api.success(response)then
                local contentText = lang.trans("bayernActivity_Haved_Reward")
                self.view:InitFreeDrawButtonState(true)
                DialogManager.ShowAlertPop(titleText, contentText, nil)
            end
        end)
    elseif playerLevel <= self.activityModel:GetActivityNeedLevel(1) then
        DialogManager.ShowAlertPop(titleText, contentTextLevelNoEnough)
    else
        clr.coroutine(function()
            local response = req.activityBayernLuckyDraw(self.activityModel:GetActivityType(), self.activityModel:GetActivityId())
            if api.success(response)then
                local contentText = lang.trans("bayernActivity_Haved_Reward")
                self.view:InitFreeDrawButtonState(true)
                DialogManager.ShowAlertPop(titleText, contentText, nil)
            end
        end)
    end
end

function BayernLuckyDrawCtrl:OnEnterScene()
end

function BayernLuckyDrawCtrl:OnExitScene()
end

return BayernLuckyDrawCtrl


local EventSystem = require("EventSystem")
local DialogManager = require("ui.control.manager.DialogManager")
local MarblesTaskModel = require("ui.models.activity.marbles.MarblesTaskModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")

local MarblesTaskCtrl = class(BaseCtrl)

MarblesTaskCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Marbles/MarblesTaskBoard.prefab"

function MarblesTaskCtrl:AheadRequest(marblesModel)
    self.model = MarblesTaskModel.new()
    self.model:SetMarblesModel(marblesModel)
    local periodId = self.model:GetPeriodId()
    local response = req.marblesGetTaskInfo(periodId)
    if api.success(response) then
        local data =response.val
        self.model:InitWithProtocol(data)
    end
end

function MarblesTaskCtrl:Init()
    self.view.taskClickCallBack = function(taskId) self:OnTaskItemClick(taskId) end
    self.view:InitView(self.model)
end

function MarblesTaskCtrl:OnTaskItemClick(taskId)
    local periodId = self.model:GetPeriodId()
    self.view:coroutine(function()
        local response = req.marblesReceiveTask(periodId, taskId)
        if api.success(response) then
            local data = response.val
            self.view.scrollPos = self.view.scroll.verticalNormalizedPosition
            EventSystem.SendEvent("RefreshStageShopKey", data.ticketCnt)
            if data.taskInfo then
                local marblesModel = self.model:GetMarblesModel()
                marblesModel:SetBallCnt(data.ballCnt)
                EventSystem.SendEvent("Marbles_BuyBall")
                self.model:RefreshTaskData(data)
                self.view:InitView(self.model)
                local keyName = lang.transstr("marbles_ball")
                DialogManager.ShowToast(lang.trans("stage_shop_key_get", keyName, data.addBallCnt))
            else
                DialogManager.ShowToast(lang.trans("player_treasure_task_error"))
                self.view:Close()
            end
        end
    end)
end

function MarblesTaskCtrl:OnChargeRefresh()
    self.view:Close()
end

function MarblesTaskCtrl:OnEnterScene()
    EventSystem.AddEvent("Charge_Success", self, self.OnChargeRefresh)
end

function MarblesTaskCtrl:OnExitScene()
    EventSystem.RemoveEvent("Charge_Success", self, self.OnChargeRefresh)
end

return MarblesTaskCtrl

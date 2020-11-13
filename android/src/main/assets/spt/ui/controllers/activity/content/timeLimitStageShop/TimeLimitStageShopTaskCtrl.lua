local DialogManager = require("ui.control.manager.DialogManager")
local EventSystem = require("EventSystem")
local BaseCtrl = require("ui.controllers.BaseCtrl")

local TimeLimitStageShopTaskCtrl = class(BaseCtrl)

TimeLimitStageShopTaskCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/TimeLimitStageShop/TimeLimitStageShopTaskBoard.prefab"

function TimeLimitStageShopTaskCtrl:Init(timeLimitStageShopTaskCtrlModel)
    self.model = timeLimitStageShopTaskCtrlModel
    self.view.taskClickCallBack = function(taskId) self:OnTaskItemClick(taskId) end
    self.view:InitView(self.model)
end

function TimeLimitStageShopTaskCtrl:OnTaskItemClick(taskId)
    self.view:coroutine(function()
        local response = req.activityStageShopReceiveTask(taskId)
        if api.success(response) then
            local data = response.val
            self.view.scrollPos = self.view.scroll.verticalNormalizedPosition
            EventSystem.SendEvent("RefreshStageShopKey", data.ticketCnt)
            if data.taskInfo then
                self.model:RefreshTaskData(data)
                self.view:InitView(self.model)
                local keyName = lang.transstr("stage_shop_item")
                DialogManager.ShowToast(lang.trans("stage_shop_key_get", keyName, data.addCnt))
            else
                DialogManager.ShowToast(lang.trans("player_treasure_task_error"))
                self.view:Close()
            end
        end
    end)
end

function TimeLimitStageShopTaskCtrl:OnChargeRefresh()
    self.view:Close()
end

function TimeLimitStageShopTaskCtrl:OnEnterScene()
    EventSystem.AddEvent("Charge_Success", self, self.OnChargeRefresh)
end

function TimeLimitStageShopTaskCtrl:OnExitScene()
    EventSystem.RemoveEvent("Charge_Success", self, self.OnChargeRefresh)
end

return TimeLimitStageShopTaskCtrl

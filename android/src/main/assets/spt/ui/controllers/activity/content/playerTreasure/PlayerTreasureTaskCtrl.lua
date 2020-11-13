local DialogManager = require("ui.control.manager.DialogManager")
local EventSystem = require("EventSystem")
local BaseCtrl = require("ui.controllers.BaseCtrl")

local PlayerTreasureTaskCtrl = class(BaseCtrl)

PlayerTreasureTaskCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/PlayerTreasure/PlayerTreasureTaskBoard.prefab"

PlayerTreasureTaskCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function PlayerTreasureTaskCtrl:Init(playerTreasureTaskModel)
    self.playerTreasureTaskModel = playerTreasureTaskModel
    self.view.taskClickCallBack = function(taskId) self:OnTaskItemClick(taskId) end
    self.view:InitView(playerTreasureTaskModel)
end

function PlayerTreasureTaskCtrl:OnTaskItemClick(taskId)
    local taskData = self.playerTreasureTaskModel:GetTaskDataByTaskId(taskId)
    self.view:coroutine(function()
        local period = self.playerTreasureTaskModel:GetPeriod()
        local response = req.activityRedeemPlayerTreasureTaskBonus(period, taskId)
        if api.success(response) then
            local data = response.val
            self.view.scrollPos = self.view.scroll.verticalNormalizedPosition
            EventSystem.SendEvent("BuyPlayerTreasureKey", data.keysCount)
            if data.redeemedTask then
                self.playerTreasureTaskModel:SetRedeemedTaskData(data.redeemedTask)
                self.view:InitView(self.playerTreasureTaskModel)
                DialogManager.ShowToast(lang.trans("player_treasure_key_get", data.bonus))
            else
                DialogManager.ShowToast(lang.trans("player_treasure_task_error"))
                self.view:Close()
            end
        end
    end)
end

function PlayerTreasureTaskCtrl:OnChargeRefresh()
    self.view:Close()
end

function PlayerTreasureTaskCtrl:OnEnterScene()
    EventSystem.AddEvent("Charge_Success", self, self.OnChargeRefresh)
end

function PlayerTreasureTaskCtrl:OnExitScene()
    EventSystem.RemoveEvent("Charge_Success", self, self.OnChargeRefresh)
end

return PlayerTreasureTaskCtrl

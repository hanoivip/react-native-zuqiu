local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local CoachTaskHelper = require("ui.scene.coach.coachTask.CoachTaskHelper")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local CoachTaskDetailCtrl = class(BaseCtrl)

CoachTaskDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/CoachTask/CoachTaskDetailBoard.prefab"

function CoachTaskDetailCtrl:Init(coachTaskDetailModel)
    self.view.onAcceptClick = function() self:OnClickBtnAccept() end
    self.coachTaskDetailModel = coachTaskDetailModel
end

function CoachTaskDetailCtrl:Refresh(coachTaskDetailModel)
    self.coachTaskDetailModel = coachTaskDetailModel
    self.view:InitView(self.coachTaskDetailModel)
end

function CoachTaskDetailCtrl:OnClickBtnAccept()
    -- 选择是否为空判定
    local selectPcidMap = self.coachTaskDetailModel:GetSelectPcidMap()
    local playerNeed = CoachTaskHelper.CoachMissionConfig.playerNeed
    if (not next(selectPcidMap)) or #selectPcidMap ~= playerNeed then
        DialogManager.ShowToastByLang("coach_task_err")
        return
    end

    -- 是否达到任务上限判定
    local acceptTips = self.coachTaskDetailModel:GetCanAcceptTips()
    if acceptTips then
        DialogManager.ShowToastByLang(acceptTips)
        return
    end

    local taskId = self.coachTaskDetailModel:GetTaskID()
    local response = req.coachAcceptmission(taskId, selectPcidMap)
    self.view:coroutine(function()
        if api.success(response) then
            local data = response.val
            EventSystem.SendEvent("CoachTaskDetailCtrl_OnAcceptClick", data)
            self:Close()
        end
    end)
end

function CoachTaskDetailCtrl:Close()
    self.view:Close()
end

function CoachTaskDetailCtrl:OnExitScene()

end

function CoachTaskDetailCtrl:GetStatusData()
    return self.coachTaskDetailModel
end

return CoachTaskDetailCtrl

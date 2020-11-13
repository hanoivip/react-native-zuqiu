local BaseCtrl = require("ui.controllers.BaseCtrl")
local EventSystem = require ("EventSystem")
local PlayerDollRewardSelectCtrl = class(BaseCtrl)

PlayerDollRewardSelectCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/PlayerDoll/PlayerDollRewardSelectBoard.prefab"

function PlayerDollRewardSelectCtrl:Refresh(playerDollModel)
    self.playerDollModel = playerDollModel
    self.view.onBtnConfirm = function() self:OnBtnConfirm() end
    self.view:InitView(self.playerDollModel)
end

function PlayerDollRewardSelectCtrl:OnBtnConfirm()
    self.view.confirmChange = true
    local noChanges = self.view:CompareOriginData()
    if noChanges then 
        self.view:OnBtnClose()
        return
    end
    local periodId = self.playerDollModel:GetPeriodId()
    local rewards = self.playerDollModel:GetSelectedIdArr()
    self.view:coroutine(function ()
        local response = req.dollChangedReward(periodId, rewards)
        if api.success(response) then
            local data = response.val
            local first = data.first
            self.playerDollModel:SetFirstTime(first)
            EventSystem.SendEvent("PlayerDoll_ChangeReward")
            self.view:OnBtnClose()
        end
    end)
end

function PlayerDollRewardSelectCtrl:OnExitScene()
    self.view:OnExitScene()
end

function PlayerDollRewardSelectCtrl:GetStatusData()
    return self.playerDollModel
end

return PlayerDollRewardSelectCtrl
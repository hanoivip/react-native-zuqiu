local EventSystem = require("EventSystem")
local DialogManager = require("ui.control.manager.DialogManager")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local MarblesCountRewardModel = require("ui.models.activity.marbles.MarblesCountRewardModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")

local MarblesCountRewardCtrl = class(BaseCtrl)

MarblesCountRewardCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Marbles/MarblesCountRewardBoard.prefab"

function MarblesCountRewardCtrl:AheadRequest(marblesModel)
    local periodId = marblesModel:GetPeriodId()
    local response = req.marblesGetCountInfo(periodId)
    if api.success(response) then
        local data =response.val
        self.model = MarblesCountRewardModel.new(marblesModel)
        self.model:InitWithProtocol(data)
    end
end

function MarblesCountRewardCtrl:Init()
    self.view.getCountReward = function(rewardId) self:OnGetCountReward(rewardId) end
    self.view:InitView(self.model)
end

function MarblesCountRewardCtrl:OnGetCountReward(rewardId)
    self.view:coroutine(function()
        local periodId = self.model:GetPeriodId()
        local response = req.marblesReceiveCount(periodId, rewardId)
        if api.success(response) then
            local val = response.val
            CongratulationsPageCtrl.new(val.contents)
            local subID = val.subID
            self.model:ChangeRewardState(subID)
            self.view:RefreshContent()
        end
    end)
end

function MarblesCountRewardCtrl:OnChargeRefresh()
    self.view:Close()
end

return MarblesCountRewardCtrl

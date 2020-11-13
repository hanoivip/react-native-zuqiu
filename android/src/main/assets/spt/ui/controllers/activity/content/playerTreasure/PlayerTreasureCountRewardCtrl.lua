local BaseCtrl = require("ui.controllers.BaseCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerTreasureCountRewardCtrl = class(BaseCtrl, "PlayerTreasureCountRewardCtrl")
local EventSystem = require("EventSystem")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")

PlayerTreasureCountRewardCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

PlayerTreasureCountRewardCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/PlayerTreasure/PlayerTreasureCountRewardBoard.prefab"

function PlayerTreasureCountRewardCtrl:Init(playerTreasureModel)
    self.playerTreasureModel = playerTreasureModel
    self.view.collectCallBack = function(count) self:OnCollectCallBack(count) end
    self.view:InitView(playerTreasureModel)
end

function PlayerTreasureCountRewardCtrl:OnCollectCallBack(count)
    clr.coroutine(function()
        local period = self.playerTreasureModel:GetPeriod()
        local response = req.activityRedeemPlayerCountTreasure(period, count)
        if api.success(response) then
            local data = response.val
            CongratulationsPageCtrl.new(data.contents)
            self.playerTreasureModel:RefreshRedeemed(data.countRedeemed)
            self.view:InitView(self.playerTreasureModel)
            EventSystem.SendEvent("PlayerOpenCountBox")
        end
    end) 
end

return PlayerTreasureCountRewardCtrl
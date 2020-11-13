local BaseCtrl = require("ui.controllers.BaseCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local DialogManager = require("ui.control.manager.DialogManager")

local LotteryBettingCtrl = class(BaseCtrl)

LotteryBettingCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Lottery/LotteryBetting.prefab"

function LotteryBettingCtrl:Init()
    self.view.onConfirmClick = function(matchId, stakeNumber, matchResult)
        self:OnConfirmClick(matchId, stakeNumber, matchResult)
    end

    self.view.helpButton:regOnButtonClick(
        function()
            self:OnHelpButtonClick()
        end
    )
end

function LotteryBettingCtrl:Refresh(model, matchResult)
    self.view:InitView(model, matchResult)
end

function LotteryBettingCtrl:OnConfirmClick(matchId, stakeNumber, matchResult)
    clr.coroutine(
        function()
            local response = req.lotteryStake(matchId, stakeNumber, matchResult)
            if api.success(response) then
                DialogManager.ShowToast(lang.trans("betting_success"))
                local data = response.val
                local playerInfoModel = PlayerInfoModel.new()
                playerInfoModel:AddMoney(-1 * data.m)
                self:OnRaisedBet(matchId, data[matchId])
                self.view:Close()
            end
        end
    )
end

function LotteryBettingCtrl:OnRaisedBet(matchId, model)
    if self.onRaisedBet then
        self.onRaisedBet(matchId, model)
    end
end

function LotteryBettingCtrl:OnHelpButtonClick()
    res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Activties/Lottery/LotteryRuleBoard.prefab", "camera", true, true)
end

return LotteryBettingCtrl

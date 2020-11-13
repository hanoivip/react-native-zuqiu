local EventSystem = require("EventSystem")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local ChainBoxState = require("ui.scene.activity.content.timeLimitChainBox.ChainBoxState")

local ChainBoxBuyCtrl = class(BaseCtrl)

ChainBoxBuyCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/TimeLimitChainBox/ChainBoxBuyBoard.prefab"

function ChainBoxBuyCtrl:Init(chainBoxData)
    self.chainBoxData = chainBoxData
    self.view.onBuy = function() self:OnBuyClick() end
    self.view:InitView(chainBoxData)
end

function ChainBoxBuyCtrl:OnBuyClick()
    if self.runOutOfTime then
        DialogManager.ShowToastByLang("visit_endInfo")
        return
    end
    if self.chainBoxData.clientBoxState ~= ChainBoxState.Buy then
        return
    end
    self:OnChargeRefresh()
    EventSystem.SendEvent("TimeLimitChainBox.OnBuyReward", self.chainBoxData, self.view.buyCount)
end

function ChainBoxBuyCtrl:RunOutOfTime()
    self.runOutOfTime = true
end

function ChainBoxBuyCtrl:OnChargeRefresh()
    self.view:Close()
end

function ChainBoxBuyCtrl:OnEnterScene()
    EventSystem.AddEvent("TimeLimitChainBox.RunOutOfTime", self, self.RunOutOfTime)
end

function ChainBoxBuyCtrl:OnExitScene()
    EventSystem.RemoveEvent("TimeLimitChainBox.RunOutOfTime", self, self.RunOutOfTime)
end

return ChainBoxBuyCtrl

local BaseCtrl = require("ui.controllers.BaseCtrl")

local ExchangeItemDetailMultiCtrl = class(BaseCtrl, "ExchangeItemDetailMultiCtrl")

ExchangeItemDetailMultiCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/WorldBossActivity/ExchangeItemDetailMulti.prefab"

ExchangeItemDetailMultiCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function ExchangeItemDetailMultiCtrl:Init(exchangeItemDetailMultiModel, confirmCallBack)
    self.exchangeModel = exchangeItemDetailMultiModel
    self.view:InitView(self.exchangeModel)

    if confirmCallBack then
        self.confirmCallBack = confirmCallBack
    end
    self.view.onBtnConfirmClick = function(exchangeId, count) self:OnBtnConfirmClick(exchangeId, count) end
    self.view.onClickMax = function() self:OnClickMax() end
end

function ExchangeItemDetailMultiCtrl:OnBtnConfirmClick(exchangeId, count)
    if self.confirmCallBack then
        self.confirmCallBack(exchangeId, count)
        self.view:Close()
    end
end

function ExchangeItemDetailMultiCtrl:OnClickMax()
    local maxExchangeNum = self.exchangeModel:GetItemMaxExchangeNum()
    self.exchangeModel:SetExchangeCount(maxExchangeNum)
    self.view:UpdatePriceTotal(maxExchangeNum)
end

return ExchangeItemDetailMultiCtrl


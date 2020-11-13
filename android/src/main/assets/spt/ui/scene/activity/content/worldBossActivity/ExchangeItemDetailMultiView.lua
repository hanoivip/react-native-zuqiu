local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local DialogManager = require("ui.control.manager.DialogManager")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")

local ExchangeItemDetailMultiView = class(unity.base, "ExchangeItemDetailMultiView")

function ExchangeItemDetailMultiView:ctor()
    self.txtTitle = self.___ex.txtTitle
    self.btnClose = self.___ex.btnClose
    self.itemName = self.___ex.itemName
    
    self.btnMinus = self.___ex.btnMinus
    self.txtNumber = self.___ex.txtNumber
    self.btnAdd = self.___ex.btnAdd
    self.btnMax = self.___ex.btnMax
    self.itemContainer = self.___ex.itemContainer

    self.btnConfirm = self.___ex.btnConfirm
end

function ExchangeItemDetailMultiView:start()
    local pressAddData = {
        acceleration = 1,   -- 加速度，执行的越来越快
        clickCallback = function()
            self:AddExchangeCount()
        end,
        durationCallback = function(count)
            self:AddExchangeCount()
        end,
    }
    self.btnAdd:regOnButtonPressing(pressAddData)
    self.btnAdd:regOnButtonUp(function()
        self.hasShownDiamondNotEnough = false
    end)

    local pressMinusData = {
        acceleration = 1,   -- 加速度，执行的越来越快
        clickCallback = function()
            self:MinusExchangeCount()
        end,
        durationCallback = function(count)
            self:MinusExchangeCount()
        end,
    }
    self.btnMinus:regOnButtonPressing(pressMinusData)

    self.btnMax:regOnButtonClick(function()
        if self.onClickMax then
            self.onClickMax()
        end
    end)
end

function ExchangeItemDetailMultiView:InitView(exchangeItemDetailMultiModel)
    self.exchangeModel = exchangeItemDetailMultiModel
    self:RegOnBtnClose()
    self:RegOnBtnConfirm()

    DialogAnimation.Appear(self.transform, nil)

    self.itemName.text = self.exchangeModel:GetItemName()

    local rewardParams = {
        parentObj = self.itemContainer,
        rewardData = self.exchangeModel:GetOutContent(),
        isShowName = false,
        isReceive = false,
        isShowBaseReward = false,
        isShowCardReward = true,
        isShowDetail = false,
        hideCount = false
    }
    RewardDataCtrl.new(rewardParams)

    self:InitExchangeCount()
end

function ExchangeItemDetailMultiView:RegOnBtnClose()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
end

function ExchangeItemDetailMultiView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

function ExchangeItemDetailMultiView:RegOnBtnConfirm()
    self.btnConfirm:regOnButtonClick(function()
        self:CallbackConfirm(self.exchangeModel:GetExchangeCount())
    end)
end

function ExchangeItemDetailMultiView:CallbackConfirm(count)
    if self.onBtnConfirmClick then
        self.onBtnConfirmClick(self.exchangeModel:GetExchangeId(), count)
    end
end

function ExchangeItemDetailMultiView:InitExchangeCount()
    self.exchangeCount = 1
    self:UpdatePriceTotal()
end

function ExchangeItemDetailMultiView:UpdatePriceTotal(maxExchangeNum)
    if maxExchangeNum then
        self.exchangeCount = maxExchangeNum
    end
    self.txtNumber.text = tostring(self.exchangeCount)
end

function ExchangeItemDetailMultiView:AddExchangeCount()
    if self.exchangeCount >= self.exchangeModel:GetItemMaxExchangeNum() then
        if not self.hasShownDiamondNotEnough then
            DialogManager.ShowToastByLang("exchange_item_detail_multi_max")
            self.hasShownDiamondNotEnough = true
        end
    else
        self.exchangeCount = self.exchangeCount + 1
        self:UpdatePriceTotal()
    end

    self.exchangeModel:SetExchangeCount(self.exchangeCount)
end

function ExchangeItemDetailMultiView:MinusExchangeCount()
    if self.exchangeCount > 1 then
        self.exchangeCount = self.exchangeCount - 1
        self:UpdatePriceTotal()
    end

    self.exchangeModel:SetExchangeCount(self.exchangeCount)
end

return ExchangeItemDetailMultiView
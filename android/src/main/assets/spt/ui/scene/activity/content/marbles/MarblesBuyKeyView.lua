local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local MarblesBuyKeyView = class(unity.base)

function MarblesBuyKeyView:ctor()
    self.content = self.___ex.content
    self.priceTxt = self.___ex.priceTxt
    self.number = self.___ex.number
    self.addBtn = self.___ex.addBtn
    self.minusBtn = self.___ex.minusBtn
    self.closeBtn = self.___ex.closeBtn
    self.buyBtn = self.___ex.buyBtn
    self.buttonText = self.___ex.buttonText
    self.titleTxt = self.___ex.titleTxt

    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
    local pressAddData = {
        acceleration = 1,   -- 加速度，执行的越来越快
        clickCallback = function()
            self:AddBuyCount()
        end,
        durationCallback = function(count)
            self:AddBuyCount()
        end,
    }
    self.addBtn:regOnButtonPressing(pressAddData)
    self.addBtn:regOnButtonUp(function()
        self.hasShownDiamondNotEnough = false
    end)
    local pressMinusData = {
        acceleration = 1,   -- 加速度，执行的越来越快
        clickCallback = function()
            self:MinusBuyCount()
        end,
        durationCallback = function(count)
            self:MinusBuyCount()
        end,
    }
    self.minusBtn:regOnButtonPressing(pressMinusData)
end

function MarblesBuyKeyView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

function MarblesBuyKeyView:Clear()
    for i = self.content.childCount, 1, -1 do
        Object.Destroy(self.content:GetChild(i - 1).gameObject)
    end
end

function MarblesBuyKeyView:UpdatePriceTotal()
    self.number.text = tostring(self.buyCount)
    self.buyPriceTotal = self.buyCount * self.price
    self.buttonText.text = "x " .. tostring(self.buyPriceTotal)
end

function MarblesBuyKeyView:InitBuyCount()
    self.buyCount = 1
    self:UpdatePriceTotal()
end

function MarblesBuyKeyView:AddBuyCount()
    local playerInfoModel = PlayerInfoModel.new()
    local diamond = playerInfoModel:GetDiamond()
    if self.buyCount + 1 > 50 then
        return
    end
    if (self.buyCount + 1) * self.price > diamond then
        if not self.hasShownDiamondNotEnough then
            DialogManager.ShowToastByLang("diamondNotEnough")
            self.hasShownDiamondNotEnough = true
        end
    else
        self.buyCount = self.buyCount + 1
        self:UpdatePriceTotal()
    end
end

function MarblesBuyKeyView:MinusBuyCount()
    if self.buyCount > 1 then
        self.buyCount = self.buyCount - 1
        self:UpdatePriceTotal()
    end
end

function MarblesBuyKeyView:Init(price)
    self.price = price
    DialogAnimation.Appear(self.transform, nil)
    self.priceTxt.text = "x " .. tostring(price)
    self.titleTxt.text = lang.trans("buy_detail")
    self:InitBuyCount()
end

function MarblesBuyKeyView:RegOnBuyBtnClick(func)
    self.buyBtn:regOnButtonClick(function()
        func(self.buyCount)
    end)
end

return MarblesBuyKeyView

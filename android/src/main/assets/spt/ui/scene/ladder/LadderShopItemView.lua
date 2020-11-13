local GameObjectHelper = require("ui.common.GameObjectHelper")

local LadderShopItemView = class(unity.base)

function LadderShopItemView:ctor()
    self.btnBuy = self.___ex.btnBuy
    self.buyButton = self.___ex.buyButton
    self.txtBuyEnable = self.___ex.txtBuyEnable
    self.txtBuyDisable = self.___ex.txtBuyDisable
    self.fullPriceArea = self.___ex.fullPriceArea
    self.halfPriceArea = self.___ex.halfPriceArea
    self.txtFullPrice = self.___ex.txtFullPrice
    self.txtFullPriceWithHalfPrice = self.___ex.txtFullPriceWithHalfPrice
    self.txtHalfPrice = self.___ex.txtHalfPrice
    self.itemArea = self.___ex.itemArea
    self.equipUseSymbol = self.___ex.equipUseSymbol
end

function LadderShopItemView:start()
    self:BindButtonHandler()
end

function LadderShopItemView:InitView(data)
    -- 价格区域
    if data.discount == 0 then
        GameObjectHelper.FastSetActive(self.fullPriceArea, true)
        GameObjectHelper.FastSetActive(self.halfPriceArea, false)
        self.txtFullPrice.text = "x" .. tostring(data.price)
    elseif data.discount == 1 then
        GameObjectHelper.FastSetActive(self.fullPriceArea, false)
        GameObjectHelper.FastSetActive(self.halfPriceArea, true)
        self.txtFullPriceWithHalfPrice.text = lang.trans("ladder_shop_FullPrice", tostring(data.price))
        self.txtHalfPrice.text = "x" .. tostring(data.price / 2)
    end
    -- 买入按钮状态
    if data.buy == 0 then
        self.txtBuyDisable:SetActive(false)
        self.buyButton.interactable = true
        self.txtBuyEnable:SetActive(true)
        self.btnBuy:onPointEventHandle(true)
    else
        self.txtBuyDisable:SetActive(true)
        self.buyButton.interactable = false
        self.txtBuyEnable:SetActive(false)
        self.btnBuy:onPointEventHandle(false)
    end
    self:FillItemArea()
end

function LadderShopItemView:BindButtonHandler()
    self.btnBuy:regOnButtonClick(function()
        if self.onBuy then
            self.onBuy()
        end
    end)
end

function LadderShopItemView:FillItemArea()
    if self.fillItemArea then
        self.fillItemArea()
    end
end

function LadderShopItemView:InitEquipUseSymbol(isShow)
    GameObjectHelper.FastSetActive(self.equipUseSymbol, isShow)
end

function LadderShopItemView:AddItemBox(itemBox)
    itemBox.transform:SetParent(self.itemArea, false)
end

return LadderShopItemView

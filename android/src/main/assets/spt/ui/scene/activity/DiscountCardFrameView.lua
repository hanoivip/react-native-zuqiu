
local CardBuilder = require("ui.common.card.CardBuilder")

local DiscountCardFrameView = class(unity.base)

local couponMap = {
    SS6 = "1", 
    SS8 = "2", 
    S7 = "3", 
    S9 = "4", 
}

function DiscountCardFrameView:ctor()
    self.cardParent = self.___ex.cardParent
    self.cardClickArea = self.___ex.cardClickArea
    self.txtName = self.___ex.txtName
    self.txtOriginPrice = self.___ex.txtOriginPrice
    self.txtButtonDescTop = self.___ex.txtButtonDescTop
    self.imgTop = self.___ex.imgTop
    self.txtFactPriceTop = self.___ex.txtFactPriceTop
    self.btnBuyTop = self.___ex.btnBuyTop
    self.topButton = self.___ex.topButton
    self.txtButtonDescBottom = self.___ex.txtButtonDescBottom
    self.imgBottom = self.___ex.imgBottom
    self.txtFactPriceBottom = self.___ex.txtFactPriceBottom
    self.btnBuyBottom = self.___ex.btnBuyBottom
    self.bottomButton = self.___ex.bottomButton
end

function DiscountCardFrameView:InitView(luckyWheelModel, cardData)
    local baseCardModel = CardBuilder.GetBaseCardModel(cardData.cid)
    local quality = baseCardModel:GetCardQuality()
    self.quality = quality

    local topCouponID = couponMap.S7
    local bottomCouponID = couponMap.S9
    if quality == 5 then
        topCouponID = couponMap.S7
        bottomCouponID = couponMap.S9        
    elseif quality == 6 then
        topCouponID = couponMap.SS6
        bottomCouponID = couponMap.SS8
    end
    self.topCouponID = topCouponID
    self.bottomCouponID = bottomCouponID

    -- top
    local couponModel = luckyWheelModel:GetCouponModel(topCouponID)
    local discount = couponModel:GetDiscount()
    local couponNum = couponModel:GetNum()
    self.txtButtonDescTop.text = lang.trans("luckyWheel_buyWithCoupon", tostring(discount))
    self.imgTop.overrideSprite = res.LoadRes(couponModel:GetResPath())
    self.txtFactPriceTop.text = "x" .. tostring(cardData.price * discount / 10)
    self.topButton.interactable = couponNum > 0
    -- bottom
    couponModel = luckyWheelModel:GetCouponModel(bottomCouponID)
    discount = couponModel:GetDiscount()
    couponNum = couponModel:GetNum()
    self.txtButtonDescBottom.text = lang.trans("luckyWheel_buyWithCoupon", tostring(discount))
    self.imgBottom.overrideSprite = res.LoadRes(couponModel:GetResPath())
    self.txtFactPriceBottom.text = "x" .. tostring(cardData.price * discount / 10)
    self.bottomButton.interactable = couponNum > 0

    self.txtOriginPrice.text = "x" .. tostring(cardData.price)
    self.txtName.text = baseCardModel:GetName()

    if not self.cardView then
        local cardObject, cardSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
        self.cardView = cardSpt
        cardObject.transform:SetParent(self.cardParent.transform, false)
    end
    self.cardView:InitView(baseCardModel)
    self.cardView:IsShowName(false)
end

function DiscountCardFrameView:UpdateCouponInfo(luckyWheelModel)
    local couponNum = luckyWheelModel:GetCouponNum(self.topCouponID)
    self.topButton.interactable = couponNum > 0
    couponNum = luckyWheelModel:GetCouponNum(self.bottomCouponID)
    self.bottomButton.interactable = couponNum > 0
end

function DiscountCardFrameView:start()
    self.btnBuyTop:regOnButtonClick(function()
        if type(self.onBtnBuy) == "function" then
            self.onBtnBuy(self.topCouponID)
        end
    end)
    self.btnBuyBottom:regOnButtonClick(function()
        if type(self.onBtnBuy) == "function" then
            self.onBtnBuy(self.bottomCouponID)
        end
    end)
    self.cardClickArea:regOnButtonClick(function()
        if type(self.onCardClick) == "function" then
            self.onCardClick()
        end
    end)
end

return DiscountCardFrameView

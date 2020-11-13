local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local DiscountDetailBoardView = class(unity.base)

function DiscountDetailBoardView:ctor()
    self.close = self.___ex.close
    self.cardParent = self.___ex.cardParent
    self.txtName = self.___ex.txtName
    self.txtCostDiamond = self.___ex.txtCostDiamond
    self.imgCoupon = self.___ex.imgCoupon
    self.btnBuy = self.___ex.btnBuy
end

function DiscountDetailBoardView:start()
    self.close:regOnButtonClick(function()
        self:Close()
    end)
    self.btnBuy:regOnButtonClick(function()
        if type(self.onBtnBuy) == "function" then
            self.onBtnBuy(function()
                self:Close()
            end)
        end
    end)

    DialogAnimation.Appear(self.transform, nil)
end

function DiscountDetailBoardView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

function DiscountDetailBoardView:InitView(cardModel, price, couponModel)
    self.txtName.text = cardModel:GetName()
    self.txtCostDiamond.text = tostring(price)
    self.imgCoupon.overrideSprite = res.LoadRes(couponModel:GetResPath())
    if not self.cardView then
        local cardObject, cardSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
        self.cardView = cardSpt
        cardObject.transform:SetParent(self.cardParent.transform, false)
        self.cardView:InitView(cardModel)
        self.cardView:IsShowName(false)
    end
end

return DiscountDetailBoardView

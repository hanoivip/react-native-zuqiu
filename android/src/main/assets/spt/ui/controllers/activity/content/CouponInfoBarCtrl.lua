local CouponInfoBarCtrl = class()

function CouponInfoBarCtrl:ctor(infoBarView, parentCtrl, luckyWheelModel)
    self.infoBarView = infoBarView
    self.parentCtrl = parentCtrl
    self.infoBarView.clickBack = function() self:OnBtnBack() end
    self:InitView(luckyWheelModel)
end

function CouponInfoBarCtrl:InitView(luckyWheelModel)
    self.infoBarView:InitView(luckyWheelModel)
end

function CouponInfoBarCtrl:RegOnBtnBack(func)
    if type(func) == "function" then
        self.infoBarView.clickBack = func
    end
end

function CouponInfoBarCtrl:OnBtnBack()
    res.PopScene()
end    

return CouponInfoBarCtrl

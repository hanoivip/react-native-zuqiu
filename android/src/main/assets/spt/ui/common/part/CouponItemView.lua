
local CouponItemView = class(unity.base)

function CouponItemView:ctor()
    self.icon = self.___ex.icon
    self.nameTxt = self.___ex.name
    self.nameShadow = self.___ex.nameShadow
    self.addNum = self.___ex.addNum
    self.addNumText = self.___ex.addNumText
    self.rectTrans = self.___ex.rectTrans
    self.btnClick = self.___ex.btnClick
end

function CouponItemView:start()
    self.btnClick:regOnButtonClick(function()
        if self.isShowDetail then
            res.PushDialog("ui.controllers.activity.content.CouponDetailCtrl", self.couponModel)
        end
    end)
end

function CouponItemView:InitView(couponModel, isShowName, isShowAddNum, isShowDetail)
    self.couponModel = couponModel
    self.icon.overrideSprite = res.LoadRes(couponModel:GetResPath())
    self.isShowDetail = isShowDetail
    if isShowName then
        self.nameTxt.gameObject:SetActive(true)
        self.nameTxt.text = couponModel:GetName()
    else
        self.nameTxt.gameObject:SetActive(false)
    end
    if isShowAddNum then
        self.addNum.gameObject:SetActive(true)
        self.addNumText.text = "x" .. tostring(couponModel:GetNum())
    else
        self.addNum.gameObject:SetActive(false)
    end
end

return CouponItemView

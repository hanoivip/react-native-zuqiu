
local BaseCtrl = require("ui.controllers.BaseCtrl")
local CouponDetailCtrl = class(BaseCtrl, "CouponDetailCtrl")
CouponDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/LuckyWheel/CouponDetail.prefab"
CouponDetailCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function CouponDetailCtrl:Init(couponModel)
end

function CouponDetailCtrl:Refresh(couponModel)
    CouponDetailCtrl.super.Refresh(self)
    self.couponModel = couponModel
    self.view:InitView(self.couponModel)
end

function CouponDetailCtrl:GetStatusData()
    return self.couponModel
end

return CouponDetailCtrl

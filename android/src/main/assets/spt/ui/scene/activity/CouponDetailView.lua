local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2
local RectTransform = UnityEngine.RectTransform

local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local CouponDetailView = class(unity.base)

function CouponDetailView:ctor()
    self.btnClose = self.___ex.btnClose
    self.txtName = self.___ex.txtName
    self.txtOwnNum = self.___ex.txtOwnNum
    self.txtDesc = self.___ex.txtDesc
    self.couponItemParent = self.___ex.couponItemParent
    self.canvasGroup = self.___ex.canvasGroup
end

function CouponDetailView:start()
    self.btnClose:regOnButtonClick(function()
        if type(self.closeDialog) == "function" then
            DialogAnimation.Disappear(self.transform, nil, function()
                self.closeDialog()
            end)
        end
    end)
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function CouponDetailView:InitView(couponModel)
    self.txtName.text = couponModel:GetName()
    self.txtOwnNum.text = lang.trans("itemDetail_number", tostring(couponModel:GetOwnNum()))
    self.txtDesc.text = couponModel:GetDesc()

    local couponItemObj, couponItemView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Part/CouponItemBox.prefab")
    local couponItemRectTrans = couponItemObj:GetComponent(RectTransform)
    couponItemObj.transform:SetParent(self.couponItemParent.transform, false)
    couponItemRectTrans.sizeDelta = Vector2(140, 180)
    couponItemView:InitView(couponModel, false, false, false)
end

return CouponDetailView

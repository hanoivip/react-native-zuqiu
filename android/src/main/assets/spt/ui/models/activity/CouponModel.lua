local Coupon = require("data.Coupon")
local Model = require("ui.models.Model")

local CouponModel = class(Model, "CouponModel")

local couponResMap = {
    ["1"] = "wheel_ss_six",
    ["2"] = "wheel_ss_eight",
    ["3"] = "wheel_s_seven",
    ["4"] = "wheel_s_nine",
}

local couponResFormatStr = "Assets/CapstonesRes/Game/UI/Scene/Activties/Image/LuckyWheel/%s.png"

-- coupon = {
--     {
--         id = "2",
--         num = 1,
--         ownNum = 1,
--     },
-- },
function CouponModel:ctor(couponData)
    self.data = couponData
    self.staticData = Coupon[tostring(self.data.id)]
end

function CouponModel:GetID()
    return self.data.id
end

function CouponModel:GetName()
    return self.staticData.name
end

function CouponModel:GetDesc()
    return self.staticData.desc
end

function CouponModel:GetDiscount()
    return self.staticData.discount
end

function CouponModel:GetNum()
    return tonumber(self.data.num)
end

function CouponModel:GetOwnNum()
    return tonumber(self.data.ownNum)
end

function CouponModel:GetResPath()
    return string.format(couponResFormatStr, couponResMap[tostring(self:GetID())])
end

return CouponModel

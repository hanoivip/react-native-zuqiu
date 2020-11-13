local EventSystem = require("EventSystem")
local DynamicLoaded = require("ui.control.utils.DynamicLoaded")

local CouponInfoBarView = class(DynamicLoaded)

local couponMap = {
    SS6 = "1", 
    SS8 = "2", 
    S7 = "3", 
    S9 = "4", 
}

function CouponInfoBarView:ctor()
    self.btnBack = self.___ex.btnBack
    self.s7Text = self.___ex.s7Text
    self.s9Text = self.___ex.s9Text
    self.ss6Text = self.___ex.ss6Text
    self.ss8Text = self.___ex.ss8Text
end

function CouponInfoBarView:start()
    self.btnBack:regOnButtonClick(function()
        if type(self.clickBack) == "function" then
            self.clickBack()
        end
    end)

    -- 增加对折扣券更新的监听
    EventSystem.AddEvent("LuckyWheelModel_SetTreasure", self, self.EventUpdateCouponInfo)
end

function CouponInfoBarView:EventUpdateCouponInfo(luckyWheelModel)
    self:InitView(luckyWheelModel)
end

function CouponInfoBarView:InitView(luckyWheelModel)
    self.s7Text.text = tostring(luckyWheelModel:GetCouponNum(couponMap.S7))
    self.s9Text.text = tostring(luckyWheelModel:GetCouponNum(couponMap.S9))
    self.ss6Text.text = tostring(luckyWheelModel:GetCouponNum(couponMap.SS6))
    self.ss8Text.text = tostring(luckyWheelModel:GetCouponNum(couponMap.SS8))
end

function CouponInfoBarView:onDestroy()
    EventSystem.RemoveEvent("LuckyWheelModel_SetTreasure", self, self.EventUpdateCouponInfo)
end

return CouponInfoBarView

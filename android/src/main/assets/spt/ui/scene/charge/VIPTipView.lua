
local VIPTipView = class(unity.base)

function VIPTipView:ctor()
    self.confirmBtn = self.___ex.confirmBtn
    self.cancleBtn = self.___ex.cancleBtn
    self.vipLevelTxt = self.___ex.vipLevelTxt
    self.vipLevelShadowTxt = self.___ex.vipLevelShadowTxt
    self.animator = self.___ex.animator
    self.maskBtn = self.___ex.maskBtn
end

function VIPTipView:InitView(viplevel, chargeView)
    self.viplevel = viplevel
    self.chargeView = chargeView
    self.confirmBtn:regOnButtonClick(function ()
        if self.chargeView ~= nil then
            chargeView:GotoVIPContentByVIPLevel(viplevel or 0)
        else
            res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl", "vip", self.viplevel or 0)
        end
        self:MoveOut()
    end)
    self.cancleBtn:regOnButtonClick(function ()
        self:MoveOut()
    end)
    self.vipLevelTxt.text = lang.trans("vip_tip_1", self.viplevel)
    self.vipLevelShadowTxt.text = lang.trans("vip_tip_1", self.viplevel)

    self.maskBtn:regOnButtonClick(function ()
        if self.isPlay then
            return
        else
            self:MoveOut()
        end
    end)
end

function VIPTipView:MoveIn()
    self.animator:Play("VIPTipAnimation")
    self.isPlay = true
end

function VIPTipView:ResetIsPlay()
    self.isPlay = false
end

function VIPTipView:MoveOut()
    self.animator:Play("VIPTipCloseAnimation")
end

function VIPTipView:Close()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
end

return VIPTipView

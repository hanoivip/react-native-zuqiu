local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local BuyInfoBoardCtrl = require("ui.controllers.home.BuyInfoBoardCtrl")
local OtherMenuView = class(unity.base)

function OtherMenuView:ctor()
    self.close = self.___ex.close
    self.rules = self.___ex.rules
    self.businessMark = self.___ex.businessMark
    self.moneyLaw = self.___ex.moneyLaw
    self.buyInfo = self.___ex.buyInfo
    self.contactUs = self.___ex.contactUs
end

function OtherMenuView:start()
    self.close:regOnButtonClick(function()
        self:Close()
    end)
    self.rules:regOnButtonClick(function ()
        luaevt.trig("SDK_OpenWebView", require("ui.common.UrlConfig").Rules, res.GetMobcastUserAgentAppendStr())
    end)
    self.businessMark:regOnButtonClick(function ()
        luaevt.trig("SDK_OpenWebView", require("ui.common.UrlConfig").Bussiness, res.GetMobcastUserAgentAppendStr())
    end)
    self.moneyLaw:regOnButtonClick(function ()
        luaevt.trig("SDK_OpenWebView", require("ui.common.UrlConfig").MoneyLaw, res.GetMobcastUserAgentAppendStr())
    end)
    self.buyInfo:regOnButtonClick(function()
        BuyInfoBoardCtrl.new()
    end)
    self.contactUs:regOnButtonClick(function()
        require("ui.controllers.contactMOB.contactMOBCtrl").new()
    end)
    DialogAnimation.Appear(self.transform, nil)
end

function OtherMenuView:Close(callback)
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

return OtherMenuView


local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local BuyInfoBoardView = class(unity.base)

function BuyInfoBoardView:ctor()
    self.freeDiamond = self.___ex.freeDiamond
    self.payDiamond = self.___ex.payDiamond
    self.confirmBtn = self.___ex.confirmBtn
    self.closeBtn = self.___ex.closeBtn

    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)

    self.confirmBtn:regOnButtonClick(function()
        self:Close()
    end)
end

function BuyInfoBoardView:Init(freeDiamond, payDiamond)
    self.freeDiamond.text = tostring(freeDiamond)
    self.payDiamond.text = tostring(payDiamond)

    DialogAnimation.Appear(self.transform, nil)
end

function BuyInfoBoardView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

return BuyInfoBoardView

local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local RedPacketDescView = class(unity.base)

function RedPacketDescView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.inputField = self.___ex.inputField
    self.confirmBtn = self.___ex.confirmBtn

    DialogAnimation.Appear(self.transform, nil)
end

function RedPacketDescView:start()
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
    self.confirmBtn:regOnButtonClick(function ()
        if self.OnClickConfirmBtn then
            self.OnClickConfirmBtn(self.inputField.text)
        end
    end)
end

function RedPacketDescView:InitView(model)

end

function RedPacketDescView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function ()
            self.closeDialog()
        end)
    end
end



return RedPacketDescView
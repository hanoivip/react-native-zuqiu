local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local LuckyWheelDescView = class(unity.base)

function LuckyWheelDescView:ctor()
    self.btnClose = self.___ex.btnClose
    self.btnConfirm = self.___ex.btnConfirm
end

function LuckyWheelDescView:start()
    local closeFunc = function()
        self:Close()
    end
    self.btnClose:regOnButtonClick(closeFunc)
    self.btnConfirm:regOnButtonClick(closeFunc)
    
    DialogAnimation.Appear(self.transform, nil)
end

function LuckyWheelDescView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

return LuckyWheelDescView

local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local SupporterTipBoxView = class(unity.base, "SupporterTipBoxView")

function SupporterTipBoxView:ctor()
--------Start_Auto_Generate--------
    self.tipTxt = self.___ex.tipTxt
    self.closeBtn = self.___ex.closeBtn
--------End_Auto_Generate----------
end

function SupporterTipBoxView:start()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
end

function SupporterTipBoxView:InitView(tips)
    if not tips or #tips == 0 then return end
    local msg = ""
    for i, v in pairs(tips) do
        msg = msg .. "        " .. tostring(i) .. "." .. tostring(v) .. "\n"
    end
    self.tipTxt.text = msg
end

function SupporterTipBoxView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
            self.closeDialog()
        end)
    end
end

function SupporterTipBoxView:EnterScene()
end

function SupporterTipBoxView:ExitScene()
end

return SupporterTipBoxView

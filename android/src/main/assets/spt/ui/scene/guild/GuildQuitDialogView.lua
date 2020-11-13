local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local Vector2 = UnityEngine.Vector2
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local GuildQuitDialogView = class(unity.base)

function GuildQuitDialogView:ctor()
    self.title = self.___ex.title
    self.content = self.___ex.content
    self.btnCancel = self.___ex.btnCancel
    self.btnComfirm = self.___ex.btnComfirm
    self.close = self.___ex.close
end


function GuildQuitDialogView:start()
    DialogAnimation.Appear(self.transform)

    self.btnCancel:regOnButtonClick(function()
        self:Close()
    end)

    self.close:regOnButtonClick(function()
        self:Close()
    end)

    self.btnComfirm:regOnButtonClick(function()
        if type(self.onBtnComfirmClick) == "function" then
            self.onBtnComfirmClick()
        end
    end)


end

function GuildQuitDialogView:InitView(model)
    self.title.text = model:GetTitle()
    self.content.text = model:GetContent()
end

function GuildQuitDialogView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)
end

return GuildQuitDialogView
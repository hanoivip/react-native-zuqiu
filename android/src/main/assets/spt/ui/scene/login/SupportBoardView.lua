local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local SupportBoardView = class(unity.base)

function SupportBoardView:ctor()
    self.accountId = self.___ex.accountId
    self.dataTransferBtn = self.___ex.dataTransferBtn
    self.dataBindBtn = self.___ex.dataBindBtn
    self.contactUsBtn = self.___ex.contactUsBtn
    self.closeBtn = self.___ex.closeBtn

    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)

    self.dataTransferBtn:regOnButtonClick(function()
        -- luaevt.trig("SDK_MobcastLogin")
    end)

    self.dataBindBtn:regOnButtonClick(function()
        -- luaevt.trig("SDK_MobcastRegister")
    end)

    self.contactUsBtn:regOnButtonClick(function()
        require("ui.controllers.contactMOB.contactMOBCtrl").new()
    end)
end

function SupportBoardView:Init(aid)
    self.accountId.text = tostring(aid)
    DialogAnimation.Appear(self.transform, nil)
end

function SupportBoardView:Close(callback)
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

return SupportBoardView

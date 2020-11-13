local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local TransportInviteHistoryView = class(unity.base)

function TransportInviteHistoryView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.scrollView = self.___ex.scrollView

    DialogAnimation.Appear(self.transform)
end

function TransportInviteHistoryView:start()
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
end

function TransportInviteHistoryView:InitView(data)
    self.data = data or {}
    self.scrollView:InitView(self.data.requestGuards or {})
end

function TransportInviteHistoryView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function ()
            self.closeDialog()
        end)
    end
end

function TransportInviteHistoryView:onDestroy()

end

return TransportInviteHistoryView
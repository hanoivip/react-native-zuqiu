local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local PeakHistoryMainView = class(unity.base)

function PeakHistoryMainView:ctor()
    self.scrollView = self.___ex.scrollView
end

function PeakHistoryMainView:start()
     DialogAnimation.Appear(self.transform, nil)
end

function PeakHistoryMainView:InitView()
   
end

function PeakHistoryMainView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function ()
            self.closeDialog()
        end)
    end
end

return PeakHistoryMainView
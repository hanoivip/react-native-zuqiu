local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local WorldBossGrabResultView = class(unity.base)

function WorldBossGrabResultView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.handChallenge = self.___ex.handChallenge
    self.desc = self.___ex.desc
    self.baseCount = self.___ex.baseCount
    self.numK = self.___ex.numK
    self.resultCount = self.___ex.resultCount
end

function WorldBossGrabResultView:start()
    self.handChallenge:regOnButtonClick(function ()
        self:Close()
    end)
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
    DialogAnimation.Appear(self.transform, nil)
end

function WorldBossGrabResultView:InitView(data)
    self.desc.text = lang.trans("worldBossAcitvity_grab_desc", data.rank, data.numK)
    self.baseCount.text = tostring(data.baseCount)
    self.numK.text = tostring(data.numK)
    self.resultCount.text = tostring(data.resultCount)
end

function WorldBossGrabResultView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function ()
            self.closeDialog()
        end)
    end
end

return WorldBossGrabResultView
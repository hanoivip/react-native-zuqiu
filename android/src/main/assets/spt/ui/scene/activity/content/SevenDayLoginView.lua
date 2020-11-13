local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local RewardDataCtrl = require('ui.controllers.common.RewardDataCtrl')
local SevenDayLoginView = class(unity.base)

function SevenDayLoginView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.scrollView = self.___ex.scrollView
    self.desc = self.___ex.desc
    self.mTime = self.___ex.mTime
    self.mTitle = self.___ex.mTitle
end

function SevenDayLoginView:start()
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
    DialogAnimation.Appear(self.transform, nil)
end

function SevenDayLoginView:InitView(sevenDayLoginModel)
    self.desc.text = sevenDayLoginModel:GetDesc()
    self.mTime.text = lang.trans("sevenDayLogin_timeArea", sevenDayLoginModel:GetTimeArea())
    local mNameStr = sevenDayLoginModel:GetName()
    if mNameStr then
        self.mTitle["1"].text = mNameStr
        self.mTitle["2"].text = mNameStr
    end
end

function SevenDayLoginView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function ()
            self.closeDialog()
        end)
    end
    if self.onClose then
        self.onClose()
    end
end

function SevenDayLoginView:CloseImmediate()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
end


return SevenDayLoginView
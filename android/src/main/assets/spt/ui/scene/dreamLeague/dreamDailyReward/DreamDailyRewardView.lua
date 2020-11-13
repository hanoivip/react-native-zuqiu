local UnityEngine = clr.UnityEngine
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local DreamDailyRewardView = class(unity.base, "DreamDailyRewardView")

function DreamDailyRewardView:ctor()
    self.scrollView = self.___ex.scrollView
    self.closeBtn = self.___ex.closeBtn
    self.canvasGroup = self.___ex.canvasGroup
end

function DreamDailyRewardView:start()
    DialogAnimation.Appear(self.transform, self.canvasGroup)

    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
end

function DreamDailyRewardView:InitView(dreamDailyRewardModel)
    self.model = dreamDailyRewardModel
    self.scrollView:InitView(self.model:GetScrollData())
end

function DreamDailyRewardView:Close()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

return DreamDailyRewardView
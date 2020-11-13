local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local LadderDailyRewardDetailView = class(unity.base)

function LadderDailyRewardDetailView:ctor()
    self.btnClose = self.___ex.btnClose
    self.scrollView = self.___ex.scrollView
    self.canvasGroup = self.___ex.canvasGroup
end

function LadderDailyRewardDetailView:start()
    self:BindButtonHandler()
    self:PlayInAnimator()
end

function LadderDailyRewardDetailView:InitView(ladderModel)
end

function LadderDailyRewardDetailView:BindButtonHandler()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
end

function LadderDailyRewardDetailView:PlayInAnimator()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function LadderDailyRewardDetailView:PlayOutAnimator()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function() self:CloseView() end)
end

function LadderDailyRewardDetailView:CloseView()
    if type(self.closeDialog) == 'function' then
        self.closeDialog()
    end
end

function LadderDailyRewardDetailView:Close()
    self:PlayOutAnimator()
end

return LadderDailyRewardDetailView
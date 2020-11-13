local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local GachaRuleView = class(unity.base)

function GachaRuleView:ctor()
    self.btnClose = self.___ex.btnClose
    self.canvasGroup = self.___ex.canvasGroup
end

function GachaRuleView:start()
    self:BindButtonHandler()
    self:PlayInAnimator()
end

function GachaRuleView:BindButtonHandler()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
end

function GachaRuleView:PlayInAnimator()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function GachaRuleView:PlayOutAnimator()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function() self:CloseView() end)
end

function GachaRuleView:CloseView()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
end

function GachaRuleView:Close()
    self:PlayOutAnimator()
end

return GachaRuleView
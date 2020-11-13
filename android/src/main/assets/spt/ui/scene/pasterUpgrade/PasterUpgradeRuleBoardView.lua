local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local PasterUpgradeRuleBoardView = class(unity.base)

function PasterUpgradeRuleBoardView:ctor()
    self.btnClose = self.___ex.btnClose
    self.canvasGroup = self.___ex.canvasGroup
end

function PasterUpgradeRuleBoardView:start()
    self:BindButtonHandler()
    self:PlayInAnimator()
end

function PasterUpgradeRuleBoardView:BindButtonHandler()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
end

function PasterUpgradeRuleBoardView:PlayInAnimator()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function PasterUpgradeRuleBoardView:PlayOutAnimator()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function() self:CloseView() end)
end

function PasterUpgradeRuleBoardView:CloseView()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
end

function PasterUpgradeRuleBoardView:Close()
    self:PlayOutAnimator()
end

return PasterUpgradeRuleBoardView
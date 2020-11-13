local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local ArenaRuleBoardView = class(unity.base)

function ArenaRuleBoardView:ctor()
    self.btnClose = self.___ex.btnClose
    self.canvasGroup = self.___ex.canvasGroup
end

function ArenaRuleBoardView:start()
    self:BindButtonHandler()
    self:PlayInAnimator()
end

function ArenaRuleBoardView:BindButtonHandler()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
end

function ArenaRuleBoardView:PlayInAnimator()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function ArenaRuleBoardView:PlayOutAnimator()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function() self:CloseView() end)
end

function ArenaRuleBoardView:CloseView()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
end

function ArenaRuleBoardView:Close()
    self:PlayOutAnimator()
end

return ArenaRuleBoardView
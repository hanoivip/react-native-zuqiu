local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local LadderRuleView = class(unity.base)

function LadderRuleView:ctor()
    self.btnClose = self.___ex.btnClose
    self.canvasGroup = self.___ex.canvasGroup
    self.contentTxt = self.___ex.contentTxt
    self.titleTxt = self.___ex.titleTxt
end

function LadderRuleView:start()
    self:BindButtonHandler()
    self:PlayInAnimator()
end

function LadderRuleView:BindButtonHandler()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
end

function LadderRuleView:InitView(title, content)
    self.contentTxt.text = content
    self.titleTxt.text = title
end

function LadderRuleView:PlayInAnimator()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function LadderRuleView:PlayOutAnimator()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function() self:CloseView() end)
end

function LadderRuleView:CloseView()
    if type(self.closeDialog) == 'function' then
        self.closeDialog()
    end
end

function LadderRuleView:Close()
    self:PlayOutAnimator()
end

return LadderRuleView
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local TimeLimitExploreRuleView = class(unity.base)

function TimeLimitExploreRuleView:ctor()
    self.btnClose = self.___ex.btnClose
    self.canvasGroup = self.___ex.canvasGroup
    self.ruleContent = self.___ex.ruleContent
end

function TimeLimitExploreRuleView:start()
    self:BindButtonHandler()
    self:PlayInAnimator()
end

function TimeLimitExploreRuleView:InitText(rule)
    self.ruleContent.text = ""
    local tempText = self.ruleContent.text

    for i, v in ipairs(rule) do
        self.ruleContent.text = v
        tempText = tempText .. self.ruleContent.text
    end
    self.ruleContent.text = tempText
end

function TimeLimitExploreRuleView:BindButtonHandler()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
end

function TimeLimitExploreRuleView:PlayInAnimator()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function TimeLimitExploreRuleView:PlayOutAnimator()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function() self:CloseView() end)
end

function TimeLimitExploreRuleView:CloseView()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
end

function TimeLimitExploreRuleView:Close()
    self:PlayOutAnimator()
end

return TimeLimitExploreRuleView
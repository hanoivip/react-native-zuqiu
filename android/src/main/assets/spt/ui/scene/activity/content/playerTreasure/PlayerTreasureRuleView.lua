local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local PlayerTreasureRuleView = class(unity.base)

function PlayerTreasureRuleView:ctor()
    self.btnClose = self.___ex.btnClose
    self.canvasGroup = self.___ex.canvasGroup
    self.ruleContent = self.___ex.ruleContent
end

function PlayerTreasureRuleView:start()
    self:BindButtonHandler()
    self:PlayInAnimator()
end

function PlayerTreasureRuleView:InitText(msg)
    self.ruleContent.text = msg
    local tempText = self.ruleContent.text
end

function PlayerTreasureRuleView:BindButtonHandler()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
end

function PlayerTreasureRuleView:PlayInAnimator()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function PlayerTreasureRuleView:PlayOutAnimator()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function() self:CloseView() end)
end

function PlayerTreasureRuleView:CloseView()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
end

function PlayerTreasureRuleView:Close()
    self:PlayOutAnimator()
end

return PlayerTreasureRuleView
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local WorldBossRuleView = class(unity.base)

function WorldBossRuleView:ctor()
    self.btnClose = self.___ex.btnClose
    self.canvasGroup = self.___ex.canvasGroup
    self.title = self.___ex.title
    self.content = self.___ex.content
end

function WorldBossRuleView:start()
    self:BindButtonHandler()
    self:PlayInAnimator()
end

function WorldBossRuleView:BindButtonHandler()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
end

function WorldBossRuleView:InitView(title, content)
    self.title.text = title
    self.content.text = content
end

function WorldBossRuleView:PlayInAnimator()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function WorldBossRuleView:PlayOutAnimator()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function() self:CloseView() end)
end

function WorldBossRuleView:CloseView()
    if type(self.closeDialog) == 'function' then
        self.closeDialog()
    end
end

function WorldBossRuleView:Close()
    self:PlayOutAnimator()
end

return WorldBossRuleView
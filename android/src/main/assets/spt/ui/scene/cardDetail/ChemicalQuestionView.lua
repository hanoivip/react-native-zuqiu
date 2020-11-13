local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local ChemicalQuestionView = class(unity.base)

function ChemicalQuestionView:ctor()
    self.btnClose = self.___ex.btnClose
    self.canvasGroup = self.___ex.canvasGroup
end

function ChemicalQuestionView:start()
    self:BindButtonHandler()
    self:PlayInAnimator()
end

function ChemicalQuestionView:BindButtonHandler()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
end

function ChemicalQuestionView:PlayInAnimator()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function ChemicalQuestionView:PlayOutAnimator()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function() self:CloseView() end)
end

function ChemicalQuestionView:CloseView()
    if type(self.closeDialog) == 'function' then
        self.closeDialog()
    end
end

function ChemicalQuestionView:Close()
    self:PlayOutAnimator()
end

return ChemicalQuestionView
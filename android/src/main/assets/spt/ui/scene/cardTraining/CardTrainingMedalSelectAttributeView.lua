local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local CardTrainingMedalSelectAttributeView = class(unity.base)

function CardTrainingMedalSelectAttributeView:ctor()
    self.baseTxt = self.___ex.baseTxt
    self.extraTxt = self.___ex.extraTxt
    self.skillTxt = self.___ex.skillTxt
    self.closeBtn = self.___ex.closeBtn

    DialogAnimation.Appear(self.transform, nil)
end

function CardTrainingMedalSelectAttributeView:start()
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
end

function CardTrainingMedalSelectAttributeView:InitView()

end

function CardTrainingMedalSelectAttributeView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function ()
            self.closeDialog()
        end)
    end
end

return CardTrainingMedalSelectAttributeView
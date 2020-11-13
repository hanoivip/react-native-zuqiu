local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local HeroHallRuleView = class(unity.base, "HeroHallRuleView")

function HeroHallRuleView:ctor()
    self.txtTitle = self.___ex.txtTitle
    self.txtIntro = self.___ex.txtIntro
    self.btnClose = self.___ex.btnClose
    self.canvasGroup = self.___ex.canvasGroup
end

function HeroHallRuleView:start()
    self:RegBtnEvent()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function HeroHallRuleView:InitView(heroHallRuleModel)
    self.model = heroHallRuleModel

    self.txtTitle.text = self.model:GetTitle()
    self.txtIntro.text = self.model:GetIntro()
end

function HeroHallRuleView:RegBtnEvent()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
end

function HeroHallRuleView:Close()
    local callback = function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end

    DialogAnimation.Disappear(self.transform, nil, callback)
end

return HeroHallRuleView
local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local HeroHallImproveView = class(unity.base, "HeroHallImproveView")

function HeroHallImproveView:ctor()
    self.txtTitle = self.___ex.txtTitle
    self.btnClose = self.___ex.btnClose
    self.canvasGroup = self.___ex.canvasGroup
    self.scrollView = self.___ex.scrollView
end

function HeroHallImproveView:start()
    self:RegBtnEvent()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function HeroHallImproveView:InitView(heroHallImproveModel)
    self.model = heroHallImproveModel
    local scrollData = self.model:GetScrollData()
    self.scrollView:InitView(scrollData)
end

function HeroHallImproveView:RegBtnEvent()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
end

function HeroHallImproveView:Close()
    local callback = function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end

    DialogAnimation.Disappear(self.transform, nil, callback)
end

return HeroHallImproveView
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local FancyGachaPoolBoardView = class(unity.base)

function FancyGachaPoolBoardView:ctor()
--------Start_Auto_Generate--------
    self.cardsAreaSpt = self.___ex.cardsAreaSpt
    self.closeBtn = self.___ex.closeBtn
--------End_Auto_Generate----------
end

function FancyGachaPoolBoardView:start()
    DialogAnimation.Appear(self.transform, nil)
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
end

function FancyGachaPoolBoardView:InitView(cardsMapModel, fancyCardResourceCache)
    self.model = cardsMapModel
    self.cardsAreaSpt:InitView(self.model, fancyCardResourceCache)
end

function FancyGachaPoolBoardView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

return FancyGachaPoolBoardView

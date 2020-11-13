local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local CardTrainingPlayerListView = class(unity.base)

function CardTrainingPlayerListView:ctor()
    self.confirmBtn = self.___ex.confirmBtn
    self.closeBtn = self.___ex.closeBtn
    self.scrollView = self.___ex.scrollView

    DialogAnimation.Appear(self.transform, nil)
end

function CardTrainingPlayerListView:start()
    self.confirmBtn:regOnButtonClick(function ()
        if self.confirmBtnClick then
            self.confirmBtnClick()
        end
    end)

    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
end

function CardTrainingPlayerListView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function ()
            self.closeDialog()
        end)
    end
end

function CardTrainingPlayerListView:EventSelectedCard(pcid, isSelected)
    if self.selectCardCallBack then
        self.selectCardCallBack(pcid, isSelected)
    end
end

function CardTrainingPlayerListView:OnEnterScene()
    EventSystem.AddEvent("PlayerListModel_ToggleSelectCard", self, self.EventSelectedCard)
end

function CardTrainingPlayerListView:OnExitScene()
    EventSystem.RemoveEvent("PlayerListModel_ToggleSelectCard", self, self.EventSelectedCard)
end



return CardTrainingPlayerListView
local MoraleRecieveSignView = class(unity.base)

function MoraleRecieveSignView:ctor()
    self.btnMorale = self.___ex.btnMorale
    self.btnMorale:regOnButtonClick(function()
        self:OnBtnMorale()
    end)
end

function MoraleRecieveSignView:InitView(greenswardBuildModel)
    self.greenswardBuildModel = greenswardBuildModel
end

function MoraleRecieveSignView:OnBtnMorale()
    res.PushDialog("ui.controllers.greensward.GreenswardMoraleRecieveDialogCtrl", self.greenswardBuildModel)
end

return MoraleRecieveSignView
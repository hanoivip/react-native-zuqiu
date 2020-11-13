local GreenswardInfoBarCtrl = class()

local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local DialogManager = require("ui.control.manager.DialogManager")

function GreenswardInfoBarCtrl:ctor(infoBarView, greenswardBuildModel)
    self.playerInfoModel = nil
    self.infoBarView = infoBarView
    self:Init(greenswardBuildModel)
end

function GreenswardInfoBarCtrl:Init(greenswardBuildModel)
    self.greenswardBuildModel = greenswardBuildModel
    self.playerInfoModel = PlayerInfoModel.new()
    self:InitView(greenswardBuildModel)
end

function GreenswardInfoBarCtrl:InitView(greenswardBuildModel)
    self.infoBarView.clickPower = function() self:OnBtnPower() end
    self.infoBarView.clickDiamond = function() self:OnBtnDiamond() end
    self.infoBarView.clickBack = function() self:OnBtnBack() end
    self.infoBarView.clickMorale = function() self:OnBtnMorale() end
    self.infoBarView:EventPlayerInfo(self.playerInfoModel)
	self.infoBarView:EventGreenswardInfo(greenswardBuildModel)
end

function GreenswardInfoBarCtrl:RegOnBtnBack(func)
    if type(func) == "function" then
        self.infoBarView.clickBack = func
    end
end

function GreenswardInfoBarCtrl:Refresh()
    self:InitView(self.playerInfoModel)
end

function GreenswardInfoBarCtrl:OnBtnPower()

end

function GreenswardInfoBarCtrl:OnBtnDiamond()
    res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl")
end       

function GreenswardInfoBarCtrl:OnBtnMorale()
    res.PushDialog("ui.controllers.greensward.GreenswardMoraleDialogCtrl", self.greenswardBuildModel)
end

function GreenswardInfoBarCtrl:OnBtnBack()
    res.PopSceneImmediate()
end

return GreenswardInfoBarCtrl


local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local PeakInfoBarCtrl = class()

function PeakInfoBarCtrl:ctor(view)
    self.view = view
    self:Init()
end

function PeakInfoBarCtrl:Init()
    self.playerInfoModel = PlayerInfoModel.new()
    self:InitView()
end

function PeakInfoBarCtrl:InitView()
    self.view.clickDiamond = function() self:OnBtnDiamond() end
    self.view:InitView(self.playerInfoModel)
end

function PeakInfoBarCtrl:RegOnBtnBack(func)
    if type(func) == "function" then
        self.view.clickBack = func
    end
end

function PeakInfoBarCtrl:OnBtnDiamond()
    res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl")
end

return PeakInfoBarCtrl
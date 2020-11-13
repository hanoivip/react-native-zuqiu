local AssistCoachGachaInfoBarCtrl = class()
local PlayerInfoModel = require("ui.models.PlayerInfoModel")

function AssistCoachGachaInfoBarCtrl:ctor(infoBarView, assistCoachGachaModel)
    self.playerInfoModel = nil
    self.infoBarView = infoBarView
    self.assistCoachGachaModel = assistCoachGachaModel
    self:Init()
end

function AssistCoachGachaInfoBarCtrl:Init()
    self.playerInfoModel = PlayerInfoModel.new()
    self:InitView()
end

function AssistCoachGachaInfoBarCtrl:InitView()
    self.infoBarView.clickAce = function() self:OnBtnAce() end
    self.infoBarView.clickDiamond = function() self:OnBtnDiamond() end
    self.infoBarView.clickBack = function() self:OnBtnBack() end
    self.infoBarView:InitView(self.playerInfoModel, self.assistCoachGachaModel)
end

function AssistCoachGachaInfoBarCtrl:RegOnBtnBack(func)
    if type(func) == "function" then
        self.infoBarView.clickBack = func
    end
end

function AssistCoachGachaInfoBarCtrl:Refresh()
    self:InitView(self.playerInfoModel)
end

function AssistCoachGachaInfoBarCtrl:OnBtnAce()
    --TODO buy ace
end

function AssistCoachGachaInfoBarCtrl:OnBtnDiamond()
    res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl")
end

function AssistCoachGachaInfoBarCtrl:OnBtnBack()
    res.PopSceneImmediate()
end

return AssistCoachGachaInfoBarCtrl


local AssistCoachInfoBarCtrl = class()

local PlayerInfoModel = require("ui.models.PlayerInfoModel")

function AssistCoachInfoBarCtrl:ctor(infoBarView)
    self.playerInfoModel = nil
    self.infoBarView = infoBarView
    self:Init()
end

function AssistCoachInfoBarCtrl:Init()
    self.playerInfoModel = PlayerInfoModel.new()
    self:InitView()
end

function AssistCoachInfoBarCtrl:InitView()
    self.infoBarView.clickAce = function() self:OnBtnAce() end
    self.infoBarView.clickDiamond = function() self:OnBtnDiamond() end
    self.infoBarView.clickMoney = function() self:OnBtnMoney() end
    self.infoBarView.clickBack = function() self:OnBtnBack() end
    self.infoBarView:EventPlayerInfo(self.playerInfoModel)
end

function AssistCoachInfoBarCtrl:RegOnBtnBack(func)
    if type(func) == "function" then
        self.infoBarView.clickBack = func
    end
end

function AssistCoachInfoBarCtrl:Refresh()
    self:InitView(self.playerInfoModel)
end

function AssistCoachInfoBarCtrl:OnBtnAce()
end

function AssistCoachInfoBarCtrl:OnBtnDiamond()
    res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl")
end

function AssistCoachInfoBarCtrl:OnBtnMoney()
    res.PushScene("ui.controllers.store.StoreCtrl", require("ui.models.store.StoreModel").MenuTags.ITEM) 
end

function AssistCoachInfoBarCtrl:OnBtnBack()
    res.PopSceneImmediate()
end

return AssistCoachInfoBarCtrl


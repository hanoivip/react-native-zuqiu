local CompeteInfoBarCtrl = class()

local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local DialogManager = require("ui.control.manager.DialogManager")

function CompeteInfoBarCtrl:ctor(infoBarView)
    self.playerInfoModel = nil
    self.infoBarView = infoBarView
    self:Init()
end

function CompeteInfoBarCtrl:Init()
    self.playerInfoModel = PlayerInfoModel.new()
    self:InitView()
end

function CompeteInfoBarCtrl:InitView()
    self.infoBarView.clickCompete = function() self:OnBtnCompete() end
    self.infoBarView.clickDiamond = function() self:OnBtnDiamond() end
    self.infoBarView.clickBack = function() self:OnBtnBack() end
    self.infoBarView.clickMoney = function() self:OnBtnMoney() end
    self.infoBarView:EventPlayerInfo(self.playerInfoModel)
end

function CompeteInfoBarCtrl:RegOnBtnBack(func)
    if type(func) == "function" then
        self.infoBarView.clickBack = func
    end
end

function CompeteInfoBarCtrl:Refresh()
    self:InitView(self.playerInfoModel)
end

function CompeteInfoBarCtrl:OnBtnCompete()

end

function CompeteInfoBarCtrl:OnBtnDiamond()
    res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl")
end       

function CompeteInfoBarCtrl:OnBtnMoney()
    res.PushScene("ui.controllers.store.StoreCtrl", require("ui.models.store.StoreModel").MenuTags.ITEM) 
end

function CompeteInfoBarCtrl:OnBtnBack()
    res.PopSceneImmediate()
end

return CompeteInfoBarCtrl


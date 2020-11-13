local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local TransportInfoBarCtrl = class()

function TransportInfoBarCtrl:ctor(view)
    self.view = view
    self:Init()
end

function TransportInfoBarCtrl:Init()
    self.playerInfoModel = PlayerInfoModel.new()
    self:InitView()
end

function TransportInfoBarCtrl:InitView()
    self.view.clickDiamond = function() self:OnBtnDiamond() end
    self.view.clickMoney = function() self:OnBtnMoney() end
    self.view:InitView(self.playerInfoModel)
end

function TransportInfoBarCtrl:RegOnBtnBack(func)
    if type(func) == "function" then
        self.view.clickBack = func
    end
end

function TransportInfoBarCtrl:OnBtnMoney()
    res.PushScene("ui.controllers.store.StoreCtrl", require("ui.models.store.StoreModel").MenuTags.ITEM) 

end

function TransportInfoBarCtrl:OnBtnDiamond()
    res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl")
end

return TransportInfoBarCtrl
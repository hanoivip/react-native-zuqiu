local HeroHallInfoBarCtrl = class()

local PlayerInfoModel = require("ui.models.PlayerInfoModel")

function HeroHallInfoBarCtrl:ctor(infoBarView)
    self.playerInfoModel = nil
    self.infoBarView = infoBarView
    self:Init()
end

function HeroHallInfoBarCtrl:Init()
    self.playerInfoModel = PlayerInfoModel.new()
    self:InitView()
end

function HeroHallInfoBarCtrl:InitView()
    self.infoBarView.clickBack = function() self:OnBtnBack() end
    self.infoBarView.clickMoney = function() self:OnBtnMoney() end
    self.infoBarView.clickDiamond = function() self:OnBtnDiamond() end
    self.infoBarView.clickSmd = function() self:OnBtnSmd() end
    self.infoBarView.clickSmb = function() self:OnBtnSmb() end

    self.infoBarView:EventPlayerInfo(self.playerInfoModel)
end

function HeroHallInfoBarCtrl:RegOnBtnBack(func)
    if type(func) == "function" then
        self.infoBarView.clickBack = func
    end
end

function HeroHallInfoBarCtrl:Refresh()
    self:InitView(self.playerInfoModel)
end

function HeroHallInfoBarCtrl:OnBtnMoney()
    res.PushScene("ui.controllers.store.StoreCtrl", require("ui.models.store.StoreModel").MenuTags.ITEM) 
end

function HeroHallInfoBarCtrl:OnBtnDiamond()
    res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl")
end

function HeroHallInfoBarCtrl:OnBtnSmd()
end

function HeroHallInfoBarCtrl:OnBtnSmb()
end

function HeroHallInfoBarCtrl:OnBtnBack()
    res.PopSceneImmediate()
end

return HeroHallInfoBarCtrl


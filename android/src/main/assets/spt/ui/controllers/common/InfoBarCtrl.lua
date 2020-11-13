local InfoBarCtrl = class()

local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local UserStrengthCtrl = require("ui.controllers.user.UserStrengthCtrl")
local DialogManager = require("ui.control.manager.DialogManager")

function InfoBarCtrl:ctor(infoBarView, parentCtrl, isShowLucky, isShowActivity, isShowBlackDiamond)
    self.playerInfoModel = nil
    self.infoBarView = infoBarView
    self.parentCtrl = parentCtrl
    self.isShowLucky = isShowLucky
    self.infoBarView.isShowActivity = isShowActivity
    self.isShowBlackDiamond = isShowBlackDiamond
    self:Init()
end

function InfoBarCtrl:Init()
    self.playerInfoModel = PlayerInfoModel.new()
    self:InitView()
end

function InfoBarCtrl:InitView(playerInfoModel)
    if playerInfoModel then
        self.playerInfoModel = playerInfoModel
    end
    self.infoBarView.clickStrength = function(isShowActivity) self:OnBtnStrength(isShowActivity) end
    self.infoBarView.clickDiamond = function() self:OnBtnDiamond() end
    self.infoBarView.clickBack = function() self:OnBtnBack() end
    self.infoBarView.clickTeam = function() self:OnBtnTeam() end
    self.infoBarView.clickLucky = function () self:OnBtnLucky() end
    self.infoBarView.clickMoney = function() self:OnBtnMoney() end
    self.infoBarView.clickBlackDiamond = function() self:OnBtnBlackDiamond() end
    self.infoBarView:ShowLuckyArea(self.isShowLucky)
    self.infoBarView:EventPlayerInfo(self.playerInfoModel)
    -- 是否显示豪门币（占据体力的位置）
    self.infoBarView:ShowBlackDiamond(self.isShowBlackDiamond)

end

function InfoBarCtrl:RegOnBtnBack(func)
    if type(func) == "function" then
        self.infoBarView.clickBack = func
    end
end

function InfoBarCtrl:Refresh()
    self:InitView(self.playerInfoModel)
end

function InfoBarCtrl:OnBtnStrength(isShowActivity)
    UserStrengthCtrl.new(isShowActivity)
end

function InfoBarCtrl:OnBtnTeam()
    local pid = self.playerInfoModel:GetID()
    local sid = self.playerInfoModel:GetSID()
    PlayerDetailCtrl.ShowPlayerDetailView(function() return req.friendsDetail(pid, sid) end, pid, sid)
end

function InfoBarCtrl:OnBtnLucky()
    DialogManager.ShowAlertPop(lang.trans("lucky"), lang.trans("store_lucky"), nil)
end

function InfoBarCtrl:OnBtnDiamond()
    res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl")
end       

function InfoBarCtrl:OnBtnMoney()
    if self.parentCtrl.__cname == "StoreCtrl" then 
        self.parentCtrl:SwitchMenu(require("ui.models.store.StoreModel").MenuTags.ITEM) 
    else
        res.PushScene("ui.controllers.store.StoreCtrl", require("ui.models.store.StoreModel").MenuTags.ITEM) 
    end
end

function InfoBarCtrl:OnBtnBlackDiamond()
    res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl", nil, nil, true)
end

function InfoBarCtrl:OnBtnBack()
    res.PopSceneImmediate()
end

return InfoBarCtrl


local HomeInfoBarCtrl = class()

local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local HomeCourtModel = require("ui.models.myscene.MySceneModel")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local UserStrengthCtrl = require("ui.controllers.user.UserStrengthCtrl")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")

function HomeInfoBarCtrl:ctor(view, viewParent, parentCtrl)
    self.parentCtrl = parentCtrl
    self.playerInfoModel = PlayerInfoModel.new()
    if view then 
        self.playerInfoBarView = view
    else
        local viewObject = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Home/InfoBar.prefab")
        viewObject.transform:SetParent(viewParent.transform, false)
        self.playerInfoBarView = viewObject:GetComponent(clr.CapsUnityLuaBehav)
    end

    self.playerInfoBarView.clickDiamond = function() self:OnBtnDiamond() end
    self.playerInfoBarView.clickMoney = function() self:OnBtnMoney() end
    self.playerInfoBarView.clickTeam = function() self:OnBtnTeam() end
    self.playerInfoBarView.clickStrength = function() self:OnBtnStrength() end
    self.playerInfoBarView.changeLogo = function() self:BuildTeam() end
end

function HomeInfoBarCtrl:InitView(playerInfoModel)
    if playerInfoModel then
        self.playerInfoModel = playerInfoModel
    end

    self.playerInfoBarView:InitView(self.playerInfoModel)
    self:BuildTeam()
end

function HomeInfoBarCtrl:BuildTeam()
    local teamData = self.playerInfoModel:GetTeamLogo()
    TeamLogoCtrl.BuildTeamLogo(self.playerInfoBarView.logo, teamData)
end

function HomeInfoBarCtrl:Refresh()
    self:InitView(self.playerInfoModel)
end

function HomeInfoBarCtrl:OnBtnTeam()
    local pid = self.playerInfoModel:GetID()
    local sid = self.playerInfoModel:GetSID()
    local homeCourtModel = HomeCourtModel.new()
    PlayerDetailCtrl.ShowPlayerDetailView(function() return req.homeDetail(pid, sid, nil, homeCourtModel:GetHome(), homeCourtModel:GetWeather(), homeCourtModel:GetGrass()) end, pid, sid, nil, nil, nil, nil, nil, true)
end

function HomeInfoBarCtrl:OnBtnStrength()
    UserStrengthCtrl.new()
end

function HomeInfoBarCtrl:OnBtnDiamond()
    res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl")
end  

function HomeInfoBarCtrl:OnBtnMoney()
  res.PushScene("ui.controllers.store.StoreCtrl", require("ui.models.store.StoreModel").MenuTags.ITEM)   
end

return HomeInfoBarCtrl

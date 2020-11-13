local AssetFinder = require("ui.common.AssetFinder")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local Timer = require("ui.common.Timer")
local ColorConversionHelper = require("ui.common.ColorConversionHelper")
local Button = clr.UnityEngine.UI.Button

local TransportInvitationItemView = class(unity.base)

function TransportInvitationItemView:ctor()
    self.inviteBtn = self.___ex.inviteBtn
    self.detailBtn = self.___ex.detailBtn
    self.logoImg = self.___ex.logoImg
    self.nameTxt = self.___ex.nameTxt
    self.serverTxt = self.___ex.serverTxt
    self.remainTimeTxt = self.___ex.remainTimeTxt
    self.powerTxt = self.___ex.powerTxt
    self.buttonTxt = self.___ex.buttonTxt
    self.buttonComponent = self.___ex.buttonComponent
    self.gradientTxt = self.___ex.gradientTxt
end

function TransportInvitationItemView:start()
    self.detailBtn:regOnButtonClick(function ()
        if self.onDetailBtnClick then
            self.onDetailBtnClick()
        end
    end)
    self.inviteBtn:regOnButtonClick(function ()
        if self.onInviteBtnClick then
            self.onInviteBtnClick()
        end
    end)
end

function TransportInvitationItemView:InitView(data)
    TeamLogoCtrl.BuildTeamLogo(self.logoImg, data.logo)
    self.nameTxt.text = data.name
    self.powerTxt.text = tostring(data.power)
    self.remainTimeTxt.text = lang.trans("transfort_remain_protect_time", data.gd_times)
    self.serverTxt.text = data.serverName or ""

    self.inviteBtn:onPointEventHandle(not data.applyGuardStatus and data.gd_times ~= 0)
    self.buttonComponent.interactable = not data.applyGuardStatus and data.gd_times ~= 0
    self.gradientTxt.enabled = not data.applyGuardStatus and data.gd_times ~= 0

    self.buttonTxt.text = lang.trans("transfort_invite_protect")
    if data.applyGuardStatus then
        self.buttonTxt.text = lang.trans("transport_have_invitation")
    end
    if data.gd_times == 0 then
        self.buttonTxt.text = lang.trans("transport_no_protection_time")
    end

    local r, g, b 
    if not data.applyGuardStatus then
        r, g, b = 145, 125, 86
    else
        r, g, b = 125, 125, 125
    end
    local color = ColorConversionHelper.ConversionColor(r, g, b)
    self.buttonTxt.color = color
end

function TransportInvitationItemView:onDestroy()

end

return TransportInvitationItemView
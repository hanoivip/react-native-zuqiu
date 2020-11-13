local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local FriendsInviteRecordItemView = class(unity.base)

function FriendsInviteRecordItemView:ctor()
    self.btnDetail = self.___ex.btnDetail
    self.logo = self.___ex.logo
    self.playerLvlTxt = self.___ex.playerLvlTxt
    self.playerPowerPointTxt = self.___ex.playerPowerPointTxt
    self.playerNameTxt = self.___ex.playerNameTxt
end

function FriendsInviteRecordItemView:start()
    self.btnDetail:regOnButtonClick(function()
        if type(self.onBtnDetailClick) == "function" then
            local pid = self.friendsInviteRecordItemModel:GetPid()
            self.onBtnDetailClick(pid, self.friendsInviteRecordItemModel)
        end
    end)
end

function FriendsInviteRecordItemView:InitView(friendsInviteRecordItemModel, friendsInviteModel)
    self.friendsInviteRecordItemModel = friendsInviteRecordItemModel
    self.friendsInviteModel = friendsInviteModel

    TeamLogoCtrl.BuildTeamLogo(self.logo, self.friendsInviteRecordItemModel:GetLogoData())
    self.playerNameTxt.text = self.friendsInviteRecordItemModel:GetPlayerName()
    self.playerLvlTxt.text = "Lv" .. tostring(self.friendsInviteRecordItemModel:GetPlayerLvl())
    self.playerPowerPointTxt.text = tostring(self.friendsInviteRecordItemModel:GetPlayerPowerPoint())
end

function FriendsInviteRecordItemView:onDestroy()
end

return FriendsInviteRecordItemView
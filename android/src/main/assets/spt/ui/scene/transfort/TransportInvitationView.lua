local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local TransporInvitationType = require("ui.models.transfort.TransporInvitationType")
local TransportInvitationView = class(unity.base)

function TransportInvitationView:ctor()
    self.menuGroup = self.___ex.menuGroup
    self.inviteAllBtn = self.___ex.inviteAllBtn
    self.inviteBestBtn = self.___ex.inviteBestBtn
    self.closeBtn = self.___ex.closeBtn
    self.scrollView = self.___ex.scrollView
    self.inviteAllButton = self.___ex.inviteAllButton
    self.inviteBestButton = self.___ex.inviteBestButton

    DialogAnimation.Appear(self.transform)
end

function TransportInvitationView:start()
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
    self.inviteAllBtn:regOnButtonClick(function ()
        if self.onInviteAllBtnClick then
            self.onInviteAllBtnClick()
        end
    end)
    self.inviteBestBtn:regOnButtonClick(function ()
        if self.onInviteBestBtnClick then
            self.onInviteBestBtnClick()
        end
    end)
end

function TransportInvitationView:InitView(model)
    self.model = model
end

function TransportInvitationView:InitBtnState()
    local isAllInvited = self.model:IsAllInvited()
    self.inviteAllBtn:onPointEventHandle(not isAllInvited)
    self.inviteAllButton.interactable = not isAllInvited
    local isAllHigherInvited = self.model:IsAllHigherPlayerList()
    self.inviteBestBtn:onPointEventHandle(not isAllHigherInvited)
    self.inviteBestButton.interactable = not isAllHigherInvited
end

function TransportInvitationView:InitFriendsView()
    self.menuGroup:selectMenuItem(TransporInvitationType.FRIENDS)
    self.scrollView:InitView(self.model:GetFriendsData())
    self:InitBtnState()
end

function TransportInvitationView:InitGuildView()
    self.menuGroup:selectMenuItem(TransporInvitationType.GUILDMEMBERS)
    self.scrollView:InitView(self.model:GetGuildData())
    self:InitBtnState()
end

function TransportInvitationView:RegOnMenuGroup(tag, func)
    if type(tag) == "string" and type(func) == "function" then
        self.menuGroup:BindMenuItem(tag, func)
    end
end

function TransportInvitationView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function ()
            self.closeDialog()
        end)
    end
end

function TransportInvitationView:onDestroy()

end

return TransportInvitationView
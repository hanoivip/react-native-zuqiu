local FriendsReceiveStrengthItemView = class(unity.base)

function FriendsReceiveStrengthItemView:ctor()
    self.btnReceiveStrength = self.___ex.btnReceiveStrength
    self.nameTxt = self.___ex.name
    self.teamLogo = self.___ex.teamLogo
end

function FriendsReceiveStrengthItemView:start()
    self.btnReceiveStrength:regOnButtonClick(function()
        if self.onReceiveStrength then
            self.onReceiveStrength()
        end
    end)
end

function FriendsReceiveStrengthItemView:InitView(data)
    self.nameTxt.text = data.name
    self:InitTeamLogo()
end

function FriendsReceiveStrengthItemView:InitTeamLogo()
    if self.onInitTeamLogo then
        self.onInitTeamLogo()
    end
end

function FriendsReceiveStrengthItemView:GetTeamLogoGameObject()
    return self.teamLogo
end

return FriendsReceiveStrengthItemView
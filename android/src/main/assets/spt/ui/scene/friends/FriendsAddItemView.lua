local TimeFormater = require("ui.controllers.friends.TimeFormater")

local FriendsAddItemView = class(unity.base)

function FriendsAddItemView:ctor()
    self.btnViewDetail = self.___ex.btnViewDetail
    self.btnAddFriend = self.___ex.btnAddFriend
    self.nameTxt = self.___ex.name
    self.level = self.___ex.level
    self.teamLogo = self.___ex.teamLogo
end

function FriendsAddItemView:start()
    self.btnViewDetail:regOnButtonClick(function()
        if self.onViewDetail then
            self.onViewDetail()
        end
    end)
    self.btnAddFriend:regOnButtonClick(function()
        if self.onAddFriend then
            self.onAddFriend()
        end
    end)
end

function FriendsAddItemView:InitView(data)
    self.nameTxt.text = data.name
    self.level.text = lang.trans("friends_manager_item_level", data.lvl)
    self:InitTeamLogo()
end

function FriendsAddItemView:InitTeamLogo()
    if self.onInitTeamLogo then
        self.onInitTeamLogo()
    end
end

function FriendsAddItemView:GetTeamLogoGameObject()
    return self.teamLogo
end

return FriendsAddItemView
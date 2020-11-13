local TimeFormater = require("ui.controllers.friends.TimeFormater")

local FriendsApplyItemView = class(unity.base)

function FriendsApplyItemView:ctor()
    self.btnAgree = self.___ex.btnAgree
    self.btnRefuse = self.___ex.btnRefuse
    self.nameTxt = self.___ex.name
    self.level = self.___ex.level
    self.teamLogo = self.___ex.teamLogo
    self.loginTime = self.___ex.loginTime
end

function FriendsApplyItemView:start()
    self.btnAgree:regOnButtonClick(function()
        if self.onAgree then
            self.onAgree()
        end
    end)
    self.btnRefuse:regOnButtonClick(function()
        if self.onRefuse then
            self.onRefuse()
        end
    end)
end

function FriendsApplyItemView:InitView(data)
    self.nameTxt.text = data.name
    self.level.text = lang.trans("friends_manager_item_level", data.lvl)
    self.loginTime.text = TimeFormater.formatLoginTime(data.l_t)
    self:InitTeamLogo()
end

function FriendsApplyItemView:InitTeamLogo()
    if self.onInitTeamLogo then
        self.onInitTeamLogo()
    end
end

function FriendsApplyItemView:GetTeamLogoGameObject()
    return self.teamLogo
end

return FriendsApplyItemView
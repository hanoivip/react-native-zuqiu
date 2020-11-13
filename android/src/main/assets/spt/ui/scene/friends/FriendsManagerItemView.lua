local TimeFormater = require("ui.controllers.friends.TimeFormater")

local FriendsManagerItemView = class(unity.base)

function FriendsManagerItemView:ctor()
    self.btnGiftPower = self.___ex.btnGiftPower
    self.btnViewDetail = self.___ex.btnViewDetail
    self.nameTxt = self.___ex.name
    self.level = self.___ex.level
    self.power = self.___ex.power
    self.teamLogo = self.___ex.teamLogo
    self.guildName = self.___ex.guildName
    self.loginTime = self.___ex.loginTime
    self.giftPowerButton = self.___ex.giftPowerButton
end

function FriendsManagerItemView:start()
    self.btnGiftPower:regOnButtonClick(function()
        if self.onGiftPower then
            self.onGiftPower()
        end
    end)
    self.btnViewDetail:regOnButtonClick(function()
        if self.onViewDetail then
            self.onViewDetail()
        end
    end)

    EventSystem.AddEvent("DeleteFriend", self, self.DeleteFriendByPid)
end

function FriendsManagerItemView:InitView(data)
    self.data = data
    self.nameTxt.text = data.name
    self.level.text = lang.trans("friends_manager_item_level", data.lvl)
    self.power.text = tostring(data.power)
    -- 公会以后再加
    self.guildName.text = ""
    self.loginTime.text = TimeFormater.formatLoginTime(data.l_t)
    self:InitTeamLogo()
    self:SetGiftPowerBtnState(data.donate == 0)
end

function FriendsManagerItemView:InitTeamLogo()
    if self.onInitTeamLogo then
        self.onInitTeamLogo()
    end
end

function FriendsManagerItemView:GetTeamLogoGameObject()
    return self.teamLogo
end

function FriendsManagerItemView:DeleteFriendByPid(pid, sid)
    if self.deleteFriendCallback then
        self.deleteFriendCallback(pid, sid)
    end
end

function FriendsManagerItemView:SetGiftPowerBtnState(isEnable)
    self.giftPowerButton.interactable = isEnable
    self.btnGiftPower:onPointEventHandle(isEnable)
end

function FriendsManagerItemView:onDestroy()
    EventSystem.RemoveEvent("DeleteFriend", self, self.DeleteFriendByPid)
end

return FriendsManagerItemView
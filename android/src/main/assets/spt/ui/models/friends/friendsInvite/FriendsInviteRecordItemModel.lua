local RewardStatus = require("ui.models.friends.RewardStatus")
local Model = require("ui.models.Model")

local FriendsInviteRecordItemModel = class(Model, "FriendsInviteRecordItemModel")

function FriendsInviteRecordItemModel:ctor(data)
    assert(type(data) == "table", "data error!!!")
    self.itemData = data
    FriendsInviteRecordItemModel.super.ctor(self, data)
end

function FriendsInviteRecordItemModel:Init()
end

function FriendsInviteRecordItemModel:GetPid()
    return self.itemData.pid
end

function FriendsInviteRecordItemModel:GetSid()
    return self.itemData.sid
end

function FriendsInviteRecordItemModel:GetLogoData()
    return self.itemData.logo
end

function FriendsInviteRecordItemModel:GetPlayerName()
    return self.itemData.name or ""
end

function FriendsInviteRecordItemModel:GetPlayerLvl()
    return self.itemData.lvl or 0
end

function FriendsInviteRecordItemModel:GetPlayerPowerPoint()
    return self.itemData.power or 0
end

return FriendsInviteRecordItemModel
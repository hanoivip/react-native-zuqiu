local Model = require("ui.models.Model")
local FriendsReceiveStrengthModel = require("ui.models.friends.FriendsReceiveStrengthModel")
local FriendsMatchRecordModel = require("ui.models.friends.FriendsMatchRecordModel")
local FriendsMessagesMenuType = require("ui.models.friends.FriendsMessagesMenuType")

local FriendsMessagesModel = class(Model)

function FriendsMessagesModel:ctor()
    FriendsMessagesModel.super.ctor(self)
    self:Init()
end

function FriendsMessagesModel:Init()
    self.friendsReceiveStrengthModel = FriendsReceiveStrengthModel.new()
    self.friendsMatchRecordModel = FriendsMatchRecordModel.new()
    self.currentMenu = FriendsMessagesMenuType.RECEIVE_STRENGTH
end

function FriendsMessagesModel:GetFriendsReceiveStrengthModel()
    return self.friendsReceiveStrengthModel
end

function FriendsMessagesModel:GetFriendsMatchRecordModel()
    return self.friendsMatchRecordModel
end

function FriendsMessagesModel:GetCurrentMenu()
    return self.currentMenu
end

function FriendsMessagesModel:SetCurrentMenu(curMenu)
    self.currentMenu = curMenu
end

return FriendsMessagesModel
local Model = require("ui.models.Model")
local EventSystem = require("EventSystem")

local FriendsReceiveStrengthModel = class(Model)

function FriendsReceiveStrengthModel:ctor()
    FriendsReceiveStrengthModel.super.ctor(self)
end

function FriendsReceiveStrengthModel:InitWithProtocol(data)
    if data then
        self.receiveLimit = data.receiveLimit
        if data.mails and data.friends then
            self.cacheData = {}
            self.cacheData.friendsList = {}
            for i = 1, #data.mails do
                for k, v in pairs(data.friends) do
                    if k == data.mails[i].pid then
                        local friendData = clone(v)
                        friendData.pid = k
                        friendData.strengthId = data.mails[i].id
                        friendData.countDown = data.mails[i].c_t
                        table.insert(self.cacheData.friendsList, friendData)
                        break
                    end
                end
            end
            table.sort(self.cacheData.friendsList, function(a, b) return a.countDown < b.countDown end)
        end
    end
end

function FriendsReceiveStrengthModel:GetReceiveLimit()
    return self.receiveLimit
end

function FriendsReceiveStrengthModel:GetFriendsList()
    return self.cacheData.friendsList
end

function FriendsReceiveStrengthModel:UpdateFriendsList(removeFriends)
    for i = 1, #removeFriends do
        for k = #self.cacheData.friendsList, 1, -1 do
            if self.cacheData.friendsList[k].strengthId == removeFriends[i] then
                table.remove(self.cacheData.friendsList, k)
                break
            end
        end
    end
    cache.setFriendSpInfo(#self.cacheData.friendsList)
    EventSystem.SendEvent("FriendsReceiveStrengthModel_UpdateFriendsList")
end

return FriendsReceiveStrengthModel
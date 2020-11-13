local Model = require("ui.models.Model")
local EventSystem = require("EventSystem")

local FriendsManagerModel = class(Model)

function FriendsManagerModel:ctor()
    FriendsManagerModel.super.ctor(self)
end

function FriendsManagerModel:InitWithProtocol(data)
    if data then
        self.cacheData = {}
        self.cacheData.friendsList = {}
        if data.friends then
            for k, v in pairs(data.friends) do
                local friendData = clone(v)
                friendData.pid = k
                table.insert(self.cacheData.friendsList, friendData)
            end
            table.sort(self.cacheData.friendsList, function(a, b) return a.l_t < b.l_t end)
        end
        self.cacheData.friendsNumber = #(self.cacheData.friendsList)
        if data.donateLimit then
            self.cacheData.strengthTimes = data.donateLimit
        end
    end
end

function FriendsManagerModel:RefreshDataWithPids(pids)
    if type(pids) == "table" then
        for k, pid in pairs(pids) do
            for i, friendData in ipairs(self.cacheData.friendsList) do
                if pid == friendData.pid then
                    friendData.donate = 1
                end
            end
        end
    else
        for i, friendData in ipairs(self.cacheData.friendsList) do
            if pids == friendData.pid then
                friendData.donate = 1
            end
        end
    end
end

function FriendsManagerModel:GetSendAllButtonState()
    for i, friendData in ipairs(self.cacheData.friendsList) do
        if friendData.donate == 0 and friendData.l_t < 604800 then
            return true
        end
    end
    return false
end

function FriendsManagerModel:GetFriendsList()

    return self.cacheData.friendsList
end

function FriendsManagerModel:GetFriendsNumber()
    return self.cacheData.friendsNumber
end

function FriendsManagerModel:GetStrengthTimes()
    return self.cacheData.strengthTimes or 0
end

function FriendsManagerModel:UpdateFriendsList(removeFriendPid)
    local removeIndex = nil
    for i = #self.cacheData.friendsList, 1, -1 do
        if self.cacheData.friendsList[i].pid == removeFriendPid then
            removeIndex = i
            table.remove(self.cacheData.friendsList, i)
            break
        end
    end
    self.cacheData.friendsNumber = #(self.cacheData.friendsList)
    EventSystem.SendEvent("FriendsManagerModel_UpdateFriendsList", removeIndex)
end

function FriendsManagerModel:UpdateStrengthTimes(times)
    self.cacheData.strengthTimes = times
    EventSystem.SendEvent("FriendsManagerModel_UpdateStrengthTimes", self.cacheData.strengthTimes)
end

return FriendsManagerModel
local Model = require("ui.models.Model")
local EventSystem = require("EventSystem")

local FriendsMatchRecordModel = class(Model)

function FriendsMatchRecordModel:ctor()
    FriendsMatchRecordModel.super.ctor(self)
end

function FriendsMatchRecordModel:InitWithProtocol(data)
    if data then
        self.cacheData = {}
        self.cacheData.matchRecordsList = {}
        for k, v in pairs(data) do
            local matchRcord = clone(v)
            matchRcord.id = k
            table.insert(self.cacheData.matchRecordsList, matchRcord)
        end
        table.sort(self.cacheData.matchRecordsList, function(a, b) return a.c_t > b.c_t end)
    end
end

function FriendsMatchRecordModel:GetMatchRecordsList()
    return self.cacheData.matchRecordsList
end

function FriendsMatchRecordModel:UpdateMatchRecordsList(removeRecords)
    for i = 1, #removeRecords do
        for k = #self.cacheData.matchRecordsList, 1, -1 do
            if tostring(self.cacheData.matchRecordsList[k].id) == tostring(removeRecords[i]) then
                table.remove(self.cacheData.matchRecordsList, k)
                break
            end
        end
    end
    cache.setFriendMatchInfo(#self.cacheData.matchRecordsList)
    EventSystem.SendEvent("FriendsMatchRecordModel_UpdateMatchRecordsList")
end

return FriendsMatchRecordModel
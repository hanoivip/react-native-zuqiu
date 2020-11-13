local Model = require("ui.models.Model")
local EventSystem = require("EventSystem")

local FriendsAddModel = class(Model)

function FriendsAddModel:ctor()
    FriendsAddModel.super.ctor(self)
end

function FriendsAddModel:InitWithProtocol(data)
    if data then
        if data.list then
            self.pidList = {}
            self.cacheData = {}
            self.cacheData.searchList = {}
            for k, v in pairs(data.list) do
                local searchData = clone(v)
                searchData.pid = k
                table.insert(self.pidList, {sid = tostring(v.sid), pid = k})
                table.insert(self.cacheData.searchList, searchData)
            end
            table.sort(self.cacheData.searchList, function(a, b) return a.l_t < b.l_t end)
            self.friendPidList = self.pidList
        end
    end
end

function FriendsAddModel:GetSearchList()
    return self.cacheData.searchList
end

function FriendsAddModel:GetPidList()
    return self.friendPidList
end

function FriendsAddModel:UpdateSearchList(searchList)
    self.cacheData.searchList = {}
    self.friendPidList = {}
    for k, v in pairs(searchList) do
        local searchData = v
        searchData.pid = k
        table.insert(self.friendPidList, {sid = tostring(v.sid), pid = k})
        table.insert(self.cacheData.searchList, searchData)
    end
    table.sort(self.cacheData.searchList, function(a, b) return a.l_t < b.l_t end)
    EventSystem.SendEvent("FriendsAddModel_UpdateSearchList")
end

return FriendsAddModel
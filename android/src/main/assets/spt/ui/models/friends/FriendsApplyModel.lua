local Model = require("ui.models.Model")
local EventSystem = require("EventSystem")

local FriendsApplyModel = class(Model)

function FriendsApplyModel:ctor()
    FriendsApplyModel.super.ctor(self)
end

function FriendsApplyModel:InitWithProtocol(data)
    if data then
        self.cacheData = {}
        self.cacheData.applicantsList = {}
        for k, v in pairs(data) do
            local applicantData = clone(v)
            applicantData.pid = k
            table.insert(self.cacheData.applicantsList, applicantData)
        end
        table.sort(self.cacheData.applicantsList, function(a, b) return a.c_t < b.c_t end)
    end
end

function FriendsApplyModel:GetApplicantsList()
    return self.cacheData.applicantsList
end

function FriendsApplyModel:UpdateApplicantsList(removeApplicantPid)
    for i = #self.cacheData.applicantsList, 1, -1 do
        if self.cacheData.applicantsList[i].pid == removeApplicantPid then
            table.remove(self.cacheData.applicantsList, i)
            break
        end
    end
    cache.setFriendReqInfo(#(self.cacheData.applicantsList))
    EventSystem.SendEvent("FriendsApplyModel_UpdateApplicantsList")
end

return FriendsApplyModel
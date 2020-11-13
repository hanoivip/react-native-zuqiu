local Model = require("ui.models.Model")

local GuildRequestModel = class(Model, "GuildRequestModel")

function GuildRequestModel:ctor()
    self.requestlist = {}
end

function GuildRequestModel:InitWithProtocol(data)
    self.requestlist = data
end

function GuildRequestModel:GetRequestList()
    return self.requestlist
end

function GuildRequestModel:RemoveRequestItem(pid)
    for i = 1, #self.requestlist do
        if self.requestlist[i]._id == pid then
            table.remove(self.requestlist, i)
            break
        end
    end
end

return GuildRequestModel
local Model = require("ui.models.Model")
local GuildInvitationModel = class(Model, "GuildInvitationModel")

function GuildInvitationModel:ctor()
end

function GuildInvitationModel:InitWithProtrol(data)
    self.data = data
end

function GuildInvitationModel:GetItemListData()
    return self.data
end

return GuildInvitationModel

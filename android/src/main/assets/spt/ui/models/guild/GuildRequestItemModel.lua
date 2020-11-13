local Model = require("ui.models.Model")

local GuildRequestItemModel = class(Model, "GuildRequestItemModel")

function GuildRequestItemModel:ctor(data)
    self.data = data
end

function GuildRequestItemModel:GetName()
    return self.data.name
end

function GuildRequestItemModel:GetLevel()
    return self.data.lvl
end

function GuildRequestItemModel:GetPid()
    return self.data._id
end

function GuildRequestItemModel:GetTeamLogo()
    return self.data.logo
end

function GuildRequestItemModel:GetLastTime()
    return self.data.reqLastTime
end 

function GuildRequestItemModel:GetSid()
    return self.data.sid
end 

return GuildRequestItemModel
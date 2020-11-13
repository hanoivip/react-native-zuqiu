local Model = require("ui.models.Model")

local GuildWarGuardDetailItemModel = class(Model, "GuildWarGuardDetailItemModel")

function GuildWarGuardDetailItemModel:ctor(data)
    self.data = data
end

function GuildWarGuardDetailItemModel:GetPid()
    return self.data._id
end

function GuildWarGuardDetailItemModel:GetPower()
    return self.data.power
end

function GuildWarGuardDetailItemModel:GetName()
    return self.data.name
end

function GuildWarGuardDetailItemModel:GetLevel()
    return self.data.lvl
end

function GuildWarGuardDetailItemModel:GetPos()
    return self.data.pos
end

function GuildWarGuardDetailItemModel:GetTeamLogo()
    return self.data.logo
end

function GuildWarGuardDetailItemModel:GetSid()
    return self.data.sid
end

return GuildWarGuardDetailItemModel
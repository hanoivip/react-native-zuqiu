local Model = require("ui.models.Model")

local GuildJoinItemModel = class(Model, "GuildJoinItemModel")

function GuildJoinItemModel:ctor(data)
    self.data = data
end

function GuildJoinItemModel:GetZone()
    return self.data.serverName
end

function GuildJoinItemModel:GetPower()
    return tostring(self.data.power)
end

function GuildJoinItemModel:GetGid()
    return self.data.gid
end

function GuildJoinItemModel:GetName()
    return self.data.name
end

function GuildJoinItemModel:GetEid()
    return self.data.eid
end

function GuildJoinItemModel:GetGuildIcon()
    return "GuildLogo" .. self.data.eid
end

function GuildJoinItemModel:GetMsg()
    return self.data.msg
end

function GuildJoinItemModel:GetMemberNum()
    return self.data.memberNum
end

function GuildJoinItemModel:GetContribute()
    return self.data.cumulativeTotalLastThreeDay
end

function GuildJoinItemModel:GetMinPlayerLvl()
    return self.data.minPlayerLvl
end

function GuildJoinItemModel:GetisAutoRequest()
    return tonumber(self.data.requestAcceptType) == 1
end

return GuildJoinItemModel
local Model = require("ui.models.Model")
local MEMBERTYPE = require("ui.controllers.guild.MEMBERTYPE")


local GuildMemberItemModel = class(Model, "GuildMemberItemModel")


local SETAUTHORITYTYPE = {
    UP = 1,
    DOWN = 2,
    OUT = 3
}

function GuildMemberItemModel:ctor(data)
    self.data = data
end

function GuildMemberItemModel:GetPid()
    return self.data._id
end

function GuildMemberItemModel:GetAuthority()
    return self.data.authority
end

function GuildMemberItemModel:GetTotalContribute()
    return self.data.cumulativeTotal
end

function GuildMemberItemModel:GetThreeContribute()
    return self.data.cumulativeTotalLastThreeDay
end

function GuildMemberItemModel:GetLastTime()
    return self.data.l_t
end

function GuildMemberItemModel:GetTeamLogo()
    return self.data.logo
end

function GuildMemberItemModel:GetLevel()
    return self.data.lvl
end

function GuildMemberItemModel:GetName()
    return self.data.name
end

function GuildMemberItemModel:GetMemberTypeStr()
    return MEMBERTYPE[self:GetAuthority()]
end

function GuildMemberItemModel.GetAuthorityEnum()
    return SETAUTHORITYTYPE
end

return GuildMemberItemModel
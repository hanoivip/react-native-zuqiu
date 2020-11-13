local Model = require("ui.models.Model")

local GuildMemberContributeRankingItemModel = class(Model, "GuildMemberContributeRankingItemModel")

function GuildMemberContributeRankingItemModel:ctor(data)
    GuildMemberContributeRankingItemModel.super.ctor(self)
    self.data = data
end

function GuildMemberContributeRankingItemModel:GetName()
    return self.data.name or ""
end

function GuildMemberContributeRankingItemModel:GetContributeValue()
    return self.data.score or ""
end

function GuildMemberContributeRankingItemModel:GetPid()
    return self.data.pid
end

function GuildMemberContributeRankingItemModel:GetSid()
    return self.data.sid
end

function GuildMemberContributeRankingItemModel:GetRank()
    return self.data.keyValue
end

function GuildMemberContributeRankingItemModel:GetLogoData()
    return self.data.logo or {}
end

function GuildMemberContributeRankingItemModel:GetIsMySelf()
    return self.data.isSelf
end
return GuildMemberContributeRankingItemModel
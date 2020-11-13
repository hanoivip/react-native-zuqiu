local Model = require("ui.models.Model")

local GuildRankingItemModel = class(Model, "GuildRankingItemModel")

function GuildRankingItemModel:ctor(data)
    self.data = data
end

function GuildRankingItemModel:GetName()
    return self.data.name or ""
end

function GuildRankingItemModel:GetPointValue()
    return self.data.score or ""
end

function GuildRankingItemModel:GetEid()
    return self.data.eid or "1"
end

function GuildRankingItemModel:GetGid()
    return self.data.gid or self.data.pid
end

function GuildRankingItemModel:GetRank()
    return self.data.keyValue
end

function GuildRankingItemModel:GetIsMySelf()
    return self.data.isSelf
end

function GuildRankingItemModel:IsUpToPointStandard()
    local isUpToStandard = self:GetGid() ~= nil
    return isUpToStandard
end

return GuildRankingItemModel
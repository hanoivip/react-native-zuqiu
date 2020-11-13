local Model = require("ui.models.Model")

local GuildRankingItemModel = class(Model, "GuildRankingItemModel")

function GuildRankingItemModel:ctor(data)
    self.data = data
end

function GuildRankingItemModel:GetName()
    return self.data.name
end

function GuildRankingItemModel:GetThreeContribute()
    return self.data.cumulativeTotalLastThreeDay or 0
end

function GuildRankingItemModel:GetEid()
    return self.data.eid
end

function GuildRankingItemModel:GetGid()
    return self.data.gid
end

function GuildRankingItemModel:GetRank()
    return self.data.rank
end

function GuildRankingItemModel:GetIsMySelf()
    return self.data.isSelf
end
return GuildRankingItemModel
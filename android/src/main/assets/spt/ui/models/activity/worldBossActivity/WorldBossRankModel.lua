local Model = require("ui.models.Model")

local WorldBossRankModel = class(Model)

function WorldBossRankModel:ctor(isSelf)
    WorldBossRankModel.super.ctor(self)
    self.isSelf = isSelf
end

function WorldBossRankModel:InitWithProtocol(data)
    assert(data)
    self.data = data
end

function WorldBossRankModel:GetRankNum()
    return self.isSelf and (self.data.playerRank or 0) or (self.data.serverRank or 0)
end

function WorldBossRankModel:GetIsSelf()
    return self.isSelf
end

function WorldBossRankModel:GetRankList()
    return self.isSelf and self.data.playerSort or self.data.serverSort
end

return WorldBossRankModel
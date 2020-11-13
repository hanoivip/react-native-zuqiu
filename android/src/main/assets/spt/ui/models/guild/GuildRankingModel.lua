local Model = require("ui.models.Model")

local GuildRankingModel = class(Model, "GuildRankingModel")

function GuildRankingModel:ctor()
    self.contributeList = {}
    self.warList = {}
    self.moveUp = true
end

function GuildRankingModel:InitWithProtocol(data)
    self.baseInfo = data
end

function GuildRankingModel:InitPowerData(data)
    for i, v in ipairs(data.top) do
        v.rank = i
        v.isSelf = (v.rank == data.self.rank)
    end
    self.powerData = data
    self.powerTopData = data.top
    self.powerSelfData = data.self
end

function GuildRankingModel:InitLivesData(data)
    for i, v in ipairs(data) do
        v.isSelf = (v.rank == self:GetRank())
    end
    self.livesData = data
end

function GuildRankingModel:InitMistData(data)
    for i, v in ipairs(data.top) do
        v.rank = i
        v.isSelf = (v.rank == data.self.rank)
    end
    self.mistData = data
    self.mistTopData = data.top
    self.mistSelfData = data.self
end

function GuildRankingModel:GetLivesData()
    return self.livesData
end

function GuildRankingModel:GetPowerData()
    return self.powerData
end

function GuildRankingModel:GetPowerTopData()
    return self.powerTopData
end

function GuildRankingModel:GetPowerSelfData()
    return self.powerSelfData
end

function GuildRankingModel:GetMistData()
    return self.mistData
end

function GuildRankingModel:GetMistTopData()
    return self.mistTopData
end

function GuildRankingModel:GetMistSelfData()
    return self.mistSelfData
end

function GuildRankingModel:GetMoveUpState()
    return self.moveUp
end

function GuildRankingModel:SetMoveUpState()
    self.moveUp = not self.moveUp
end

function GuildRankingModel:GetThreeContribute()
    return self.baseInfo.cumulativeTotalLastThreeDay
end

function GuildRankingModel:GetEid()
    return self.baseInfo.eid
end

function GuildRankingModel:GetName()
    return self.baseInfo.name
end

function GuildRankingModel:GetRank()
    return self.baseInfo.rank
end

return GuildRankingModel
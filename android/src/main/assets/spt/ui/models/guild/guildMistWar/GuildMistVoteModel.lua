local GuildWar = require("data.GuildWar")
local GuildWarBaseSet = require("data.GuildWarBaseSet")
local GuildWarType = require("ui.models.guild.guildMistWar.GuildWarType")
local Model = require("ui.models.Model")

local GuildMistVoteModel = class(Model, "GuildMistVoteModel")

function GuildMistVoteModel:ctor()
    GuildMistVoteModel.super.ctor(self)
end

function GuildMistVoteModel:InitWithProtocol(data)
    assert(data)
    self.data = data
end

function GuildMistVoteModel:GetVotList()
    local vote = self.data.voteTable
    local voteList = {}
    for i, v in pairs(vote) do
        table.insert(voteList, v)
    end
    table.sort(voteList, function(a, b) return a.id < b.id end)
    return voteList
end

function GuildMistVoteModel:GetVoteDataByIndex(index)
    index = tonumber(index)
    local voteTable = self.data.voteTable
    for i, v in pairs(voteTable) do
        if v.id == index then
            return v
        end
    end
    return {}
end

function GuildMistVoteModel:GetTotalCount()
    local donateTime = GuildWarBaseSet.mist.donateTime
    return donateTime
end

function GuildMistVoteModel:GetRemainCount()
    local counter = self.data.counter
    local total = self:GetTotalCount()
    return total - counter
end

function GuildMistVoteModel:GetCumulativeDay()
    local cumulativeDay = self.data.cumulativeDay
    return cumulativeDay
end

function GuildMistVoteModel:GetMaxCumulative()
    local maxCumulative = self.data.maxCumulative
    return maxCumulative
end


function GuildMistVoteModel:RefreshData(data)
    self.data.counter = data.counter
    self.data.cumulativeDay = data.cumulativeDay
end

function GuildMistVoteModel:IsCumulativeDayFull()
    local cumulativeDay = self:GetCumulativeDay()
    local maxCumulative = self:GetMaxCumulative()
    return cumulativeDay >= maxCumulative
end

return GuildMistVoteModel

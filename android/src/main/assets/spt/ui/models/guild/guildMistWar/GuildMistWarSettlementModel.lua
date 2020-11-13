local Model = require("ui.models.Model")

local GuildMistWarSettlementModel = class(Model, "GuildMistWarSettlementModel")

function GuildMistWarSettlementModel:ctor()
    self.scheduleList = {}
    self.guildInfoMap = {}
end

function GuildMistWarSettlementModel:InitWithProtocol(data)
    self.data = data

    self.guildInfoMap = self.data.list
    
    local count = table.nums(self.data.schedule)

    for n = 1, count do
        local itemData = self.data.schedule[tostring(n)]
        itemData.index = n
        itemData.isItem = true
        itemData.isSpread = false
        itemData.guildInfoMap = self.guildInfoMap
        table.insert(self.scheduleList, itemData) 
    end

end

function GuildMistWarSettlementModel:GetPeriod()
    return self.data.period
end

function GuildMistWarSettlementModel:GetLevel()
    return self.data.reward.level
end

function GuildMistWarSettlementModel:GetRank()
    return self.data.reward.rank
end

function GuildMistWarSettlementModel:GetScheduleList()
    return self.scheduleList
end

function GuildMistWarSettlementModel:GetGuildInfoByGid(gid)
    return self.guildInfoMap[gid]
end

return GuildMistWarSettlementModel
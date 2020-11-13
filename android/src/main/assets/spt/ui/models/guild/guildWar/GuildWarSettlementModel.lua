local Model = require("ui.models.Model")

local GuildWarSettlementModel = class(Model, "GuildWarSettlementModel")

function GuildWarSettlementModel:ctor()
    self.scheduleList = {}
    self.guildInfoMap = {}
end

function GuildWarSettlementModel:InitWithProtrol(data)
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

function GuildWarSettlementModel:GetPeriod()
    return self.data.period
end

function GuildWarSettlementModel:GetLevel()
    return self.data.reward.level
end

function GuildWarSettlementModel:GetRank()
    return self.data.reward.rank
end

function GuildWarSettlementModel:GetScheduleList()
    return self.scheduleList
end

function GuildWarSettlementModel:GetGuildInfoByGid(gid)
    return self.guildInfoMap[gid]
end

return GuildWarSettlementModel
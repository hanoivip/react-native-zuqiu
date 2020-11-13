local Model = require("ui.models.Model")

local GuildWarMyDataModel = class(Model, "GuildWarMyDataModel")

function GuildWarMyDataModel:ctor()
    self.scheduleList = {}
    self.guildInfoMap = {}
    self.currentDate = 2
end

function GuildWarMyDataModel:GetCurrentDate()
    return self.currentDate
end

function GuildWarMyDataModel:SetCurrentDate(date)
    self.currentDate = date
end

function GuildWarMyDataModel:GetData()
    return self.data
end

function GuildWarMyDataModel:InitWithProtrol(data)
    self.data = data
    for m = 1, #data.list do
        table.insert(self.guildInfoMap, self.data.list[m].list)
        local list = {}
        local count = table.nums(self.data.list[m].schedule)
        for n = 1, count do
            local itemData = self.data.list[m].schedule[tostring(n)]
            itemData.index = n
            itemData.isItem = true
            itemData.isSpread = false
            itemData.guildInfoMap = self.guildInfoMap[m]
            table.insert(list, itemData) 
        end
        table.insert(self.scheduleList, list)
    end
    self.currentDate = #self.scheduleList
end

function GuildWarMyDataModel:GetGuildInfoByGid(index, gid)
    return self.guildInfoMap[index][gid]
end

function GuildWarMyDataModel:GetScheduleList(index)
    return self.scheduleList[index]
end

return GuildWarMyDataModel
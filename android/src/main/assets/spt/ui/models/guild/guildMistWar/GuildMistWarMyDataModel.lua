local Model = require("ui.models.Model")

local GuildMistWarMyDataModel = class(Model, "GuildMistWarMyDataModel")

function GuildMistWarMyDataModel:ctor()
    self.scheduleList = {}
    self.guildInfoMap = {}
    self.currentDate = 2
end

function GuildMistWarMyDataModel:GetCurrentDate()
    return self.currentDate
end

function GuildMistWarMyDataModel:SetCurrentDate(date)
    self.currentDate = date
end

function GuildMistWarMyDataModel:GetData()
    return self.data
end

function GuildMistWarMyDataModel:InitWithProtocol(data)
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

function GuildMistWarMyDataModel:GetGuildInfoByGid(index, gid)
    return self.guildInfoMap[index][gid]
end

function GuildMistWarMyDataModel:GetScheduleList(index)
    return self.scheduleList[index]
end

return GuildMistWarMyDataModel
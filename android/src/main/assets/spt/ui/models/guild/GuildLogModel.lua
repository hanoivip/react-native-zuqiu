local Model = require("ui.models.Model")

local GuildLogModel = class(Model, "GuildLogModel")

function GuildLogModel:ctor()
    self.allRecordList = {}
end

function GuildLogModel:InitWithProtocol(data)
    self.allRecordList = data
    self.dailyRecordList = {}
    self.warRecordList = {}
    self.signRecordList = {}
    self.donateRecordList = {}
    for i = 1, #self.allRecordList do
        local record = self.allRecordList[i]
        if record.logType == "daily" then
            table.insert(self.dailyRecordList, record)
        elseif record.logType == "sign" then
            table.insert(self.signRecordList, record)
        elseif record.logType == "donation" then
            table.insert(self.donateRecordList, record)
        else
            table.insert(self.warRecordList, record)            
        end
    end
end

function GuildLogModel:GetAllRecordList()
    return self.allRecordList
end

function GuildLogModel:GetDailyRecordList()
    return self.dailyRecordList
end

function GuildLogModel:GetWarRecordList()
    return self.warRecordList
end

function GuildLogModel:GetSignRecordList()
    return self.signRecordList
end

function GuildLogModel:GetDonateRecordList()
    return self.donateRecordList
end

return GuildLogModel
local Model = require("ui.models.Model")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")

local GuildMistWarRoundSettlementModel = class(Model, "GuildMistWarRoundSettlementModel")

function GuildMistWarRoundSettlementModel:ctor()
    self.atkData = {}
    self.defData = {}
    self.guildData = PlayerInfoModel.new():GetGuild()
end

function GuildMistWarRoundSettlementModel:InitWithProtocol(data)
    self.data = data

    for k, v in pairs(self.data.schedule) do
        self.scheduleList = v.list
        self.date = v.date
    end
    
    for k, v in pairs(self.scheduleList) do
        local info = v
        if info.atkGid == self.guildData.gid then
            self.atkData = info
        else
            self.defData = info
        end
    end
end

function GuildMistWarRoundSettlementModel:GetAtkData()
    return self.atkData
end

function GuildMistWarRoundSettlementModel:GetDefData()
    return self.defData
end

function GuildMistWarRoundSettlementModel:GetDate()
    return self.date
end

function GuildMistWarRoundSettlementModel:GetPeriod()
    return self.data.period
end

function GuildMistWarRoundSettlementModel:GetRound()
    return self.data.round
end

function GuildMistWarRoundSettlementModel:GetGuildInfo(gid)
    return self.data.list[gid]
end

return GuildMistWarRoundSettlementModel
local Model = require("ui.models.Model")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")

local GuildWarRoundSettlementModel = class(Model, "GuildWarRoundSettlementModel")

function GuildWarRoundSettlementModel:ctor()
    self.atkData = {}
    self.defData = {}
    self.guildData = PlayerInfoModel.new():GetGuild()
end

function GuildWarRoundSettlementModel:InitWithProtrol(data)
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

function GuildWarRoundSettlementModel:GetAtkData()
    return self.atkData
end

function GuildWarRoundSettlementModel:GetDefData()
    return self.defData
end

function GuildWarRoundSettlementModel:GetDate()
    return self.date
end

function GuildWarRoundSettlementModel:GetPeriod()
    return self.data.period
end

function GuildWarRoundSettlementModel:GetRound()
    return self.data.round
end

function GuildWarRoundSettlementModel:GetGuildInfo(gid)
    return self.data.list[gid]
end

return GuildWarRoundSettlementModel
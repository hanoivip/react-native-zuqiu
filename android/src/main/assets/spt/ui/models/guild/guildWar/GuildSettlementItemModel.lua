local Model = require("ui.models.Model")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")

local GuildSettlementItemModel = class(Model, "GuildSettlementItemModel")

function GuildSettlementItemModel:ctor(data)
    self.data = data
    self.atkData = {}
    self.defData = {}
    self.guildData = PlayerInfoModel.new():GetGuild()

    for k, v in pairs(self.data.list) do
        local info = v
        if info.atkGid == self.guildData.gid then
            self.atkData = info
        else
            self.defData = info
        end
    end
end

function GuildSettlementItemModel:GetAtkData()
    return self.atkData
end

function GuildSettlementItemModel:GetDefData()
    return self.defData
end

function GuildSettlementItemModel:GetData()
    return self.data
end

function GuildSettlementItemModel:GetGuildInfo(gid)
    return self.data.guildInfoMap[gid]
end

function GuildSettlementItemModel:GetIndex()
    return self.data.index
end

function GuildSettlementItemModel:GetIsItem()
    return self.data.isItem or false
end

function GuildSettlementItemModel:GetIsSpread()
    return self.data.isSpread
end

function GuildSettlementItemModel:SetIsSpread(isSpread)
    self.data.isSpread = isSpread
end

return GuildSettlementItemModel
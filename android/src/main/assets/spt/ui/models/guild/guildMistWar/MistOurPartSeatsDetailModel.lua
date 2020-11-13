local GuildWarBaseSet = require("data.GuildWarBaseSet")
local GuildWarType = require("ui.models.guild.guildMistWar.GuildWarType")
local Model = require("ui.models.Model")

local MistOurPartSeatsDetailModel = class(Model, "GuildMistWarGuardDetailModel")

function MistOurPartSeatsDetailModel:ctor()

end

function MistOurPartSeatsDetailModel:InitWithProtocol(seatsDetailData)
    self.seatsDetailData = seatsDetailData
end

function MistOurPartSeatsDetailModel:GetSeatsDetailData()
    return self.seatsDetailData
end

function MistOurPartSeatsDetailModel:GetPid()
    local seatsDetailData = self:GetSeatsDetailData()
    local pid = seatsDetailData.detail.pid
    return pid
end

function MistOurPartSeatsDetailModel:GetSid()
    local seatsDetailData = self:GetSeatsDetailData()
    local sid = seatsDetailData.detail.sid
    return sid
end

function MistOurPartSeatsDetailModel:GetGuardDataByIndex(index)
    local guildData = clone(self.mistMapModel:GetGuardDataByIndex(index))
    return guildData
end

function MistOurPartSeatsDetailModel:SetMistMapModel(mistMapModel)
    self.mistMapModel = mistMapModel
end

function MistOurPartSeatsDetailModel:GetMistMapModel()
    return self.mistMapModel
end

function MistOurPartSeatsDetailModel:RefreshAttackGuardData(data)
    local mistMapModel = self:GetMistMapModel()
    local guildMistWarMainModel = mistMapModel:GetGuildMistWarMainModel()
    guildMistWarMainModel:UpdateAttackGuardData(data)
end

function MistOurPartSeatsDetailModel:GetDamage()
    local seatsDetailData = self:GetSeatsDetailData()
    local record = seatsDetailData.record
    local damage = 0
    for i, v in ipairs(record) do
        damage = damage + v.atkDamage
    end
    return damage
end

function MistOurPartSeatsDetailModel:GetTotalCount()
    local attackAmount = GuildWarBaseSet[GuildWarType.Mist].attackAmount
    return attackAmount
end

function MistOurPartSeatsDetailModel:GetRemainCount()
    local attackAmount = self:GetTotalCount()
    local warCnt = self.seatsDetailData.warCnt or 0
    return attackAmount - warCnt
end

return MistOurPartSeatsDetailModel

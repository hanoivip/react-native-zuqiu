local GuildWar = require("data.GuildWar")
local Model = require("ui.models.Model")

local GuildPowerItemModel = class(Model, "GuildPowerItemModel")

function GuildPowerItemModel:ctor(data)
    self.data = data
end

function GuildPowerItemModel:GetName()
    return self.data.name
end

function GuildPowerItemModel:GetEid()
    return self.data.eid
end

function GuildPowerItemModel:GetGid()
    return self.data._id
end

function GuildPowerItemModel:IsCommon()
    local isCommon = tobool(self.data.bestWar)
    return isCommon
end

function GuildPowerItemModel:GetLevel()
    local bestData = self.data.bestWar or self.data.bestMistWar
    local level = tostring(bestData.level)
    local minLevel = GuildWar[level].minLevel
    return tostring(minLevel)
end

function GuildPowerItemModel:GetBestRank()
    local bestData = self.data.bestWar or self.data.bestMistWar
    return tostring(bestData.rank)
end

function GuildPowerItemModel:GetRank()
    return tonumber(self.data.rank)
end

function GuildPowerItemModel:GetWinTime()
    local bestData = self.data.bestWar or self.data.bestMistWar
    return tostring(bestData.sucCnt or bestData.totalScore)
end

function GuildPowerItemModel:GetCaptureTime()
    local bestData = self.data.bestWar or self.data.bestMistWar
    return tostring(bestData.capCnt or bestData.ackScore)
end

function GuildPowerItemModel:GetResizeTime()
    local bestData = self.data.bestWar or self.data.bestMistWar

    return tostring(bestData.seiCnt or bestData.defScore)
end

function GuildPowerItemModel:GetIsMySelf()
    return self.data.isSelf
end

return GuildPowerItemModel
local Model = require("ui.models.Model")
local GuildWar = require("data.GuildWar")
local AssetFinder = require("ui.common.AssetFinder")
local GuildDetailModel = class(Model, "GuildDetailModel")


function GuildDetailModel:ctor()
end

function GuildDetailModel:InitWithProtrol(data)
    self.data = data
end

function GuildDetailModel:GetGuildLogo()
    return AssetFinder.GetGuildIcon("GuildLogo" .. self.data.eid)
end

function GuildDetailModel:GetGuildName()
    return self.data.name
end

function GuildDetailModel:GetAdminLogo()
    return self.data.alogo
end

function GuildDetailModel:GetAdminName()
    return self.data.aName
end

function GuildDetailModel:GetContribute()
    return tostring(self.data.cumulativeTotalLastThreeDay)
end

function GuildDetailModel:GetWarBest()
    if self.data.guildWarRank == nil or tonumber(self.data.guildWarRank) == -1 then
        return lang.trans("train_no_rank")
    end
    return tostring(self.data.guildWarRank)
end

function GuildDetailModel:GetContributeRank()
    return tostring(self.data.guildRank)
end

function GuildDetailModel:GetWarRank()
    if self.data.guildWarRank == nil or tonumber(self.data.guildWarRank) == -1 then
        return lang.trans("train_rankOut")
    end
    local mistGuildWarRank
    if self.data.mistGuildWarRank == nil or tonumber(self.data.mistGuildWarRank) == -1 then
        mistGuildWarRank = "--"
    else
        mistGuildWarRank = tostring(self.data.mistGuildWarRank)
    end
    return lang.trans("mist_rank_best_power", tostring(self.data.guildWarRank), mistGuildWarRank)
end

function GuildDetailModel:GetMemberNum()
    return tostring(self.data.memberNum)
end

function GuildDetailModel:GetReqType()
    local str = ""
    if self.data.requestAcceptType == 1 then
        str = lang.transstr("guild_reqAuto2")
    else
        str = lang.transstr("guild_reqAuto1")
    end
    return str
end 

function GuildDetailModel:GetReqLevel()
    return lang.transstr("guild_minLevel", self.data.minPlayerLvl)
end

function GuildDetailModel:GetNotice()
    return self.data.msg
end

function GuildDetailModel:GetID()
    return self.data.gid
end

function GuildDetailModel:GetPower()
    return self.data.power
end

-- 是否能自动加入
function GuildDetailModel:GetisAutoRequest()
    return tonumber(self.data.requestAcceptType) == 1
end

function GuildDetailModel:GetBestWarInfo()
    if not self.data.bestWar or not next(self.data.bestWar) then
        return lang.trans("guild_power_no_join_1")
    end

    local level = self.data.bestWar.level
    local rank = self.data.bestWar.rank
    return lang.trans("guild_power_top_1", level, rank)
end

function GuildDetailModel:GetBestMistWarInfo()
    if not self.data.bestWar or not next(self.data.bestWar) then
        return lang.trans("guild_power_no_join_1")
    end
    if not self.data.bestMistWar or not next(self.data.bestMistWar) then
        return lang.trans("guild_power_no_join_1")
    end
    local mistRank = self.data.bestMistWar.rank
    local minLevel = 0
    if mistRank then
        local mistLevel = self.data.bestMistWar.level
        minLevel = GuildWar[tostring(mistLevel)].minLevel
    else
        mistRank = 0
    end
    return lang.trans("guild_power_top_1", minLevel, mistRank)
end

function GuildDetailModel:GetPower()
    return self.data.power
end

return GuildDetailModel
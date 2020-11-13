local Model = require("ui.models.Model")

local GuildDataShowModel = class(Model)

GuildDataShowModel.MenuTags = {
    GUILDWAR = "guildWar",
    MYWAR = "myWar",
    GUILDWARRANK = "guildWarRank"
}

function GuildDataShowModel:ctor()
    GuildDataShowModel.super.ctor(self)
end

function GuildDataShowModel:InitWithProtocol(data)
    assert(data)
    self.cacheData = data
end

function GuildDataShowModel:GetRankData()
    return self.cacheData.rank
end

function GuildDataShowModel:GetGuildNameById(id)
    return self.cacheData.list[id].name
end

function GuildDataShowModel:GetLastWeekActivistsById(id)
    return self.cacheData.list[id].cumulativeTotalLastWeek
end

function GuildDataShowModel:GetGuildIconNameById(id)
    return self.cacheData.list[id].eid
end

function GuildDataShowModel:GetScheduleDataConsolidated()
    local scheduleConsolidated = {}
    local schedule = clone(self.cacheData.schedule)
    for k, v in pairs(schedule) do
        v.round = k
        for k1, v1 in pairs(v.list) do
            v1.atkName = self:GetGuildNameById(v1.atkGid)
            v1.defName = self:GetGuildNameById(v1.defGid)
        end
        table.insert(scheduleConsolidated, v)
    end
    table.sort(scheduleConsolidated, function (a, b)
        return a.round < b.round
    end)
    return scheduleConsolidated
end

function GuildDataShowModel:GetScheduleData()
    return self.cacheData.schedule
end

function GuildDataShowModel:GetMyWarScheduleDataByGid(gid)
    local schedule = clone(self:GetScheduleData())
    local myWar = {}
    for k, v in pairs(schedule) do
        local round = {}
        for k1, v1 in pairs(v.list) do
            if v1.atkGid == gid then
                round.round = tostring(k)
                round.atk = v1
                round.atk.buff = {}
                round.atk.buff.atkBuff = v1.atkBuff
                round.atk.buff.defBuff = v1.defBuff
                round.atk.attackName = self:GetGuildNameById(v1.atkGid)
                round.atk.defenseName = self:GetGuildNameById(v1.defGid)
            end
            if v1.defGid == gid then
                round.def = v1
                round.def.buff = {}
                round.def.buff.atkBuff = v1.atkBuff
                round.def.buff.defBuff = v1.defBuff
                round.def.attackName = self:GetGuildNameById(v1.atkGid)
                round.def.defenseName = self:GetGuildNameById(v1.defGid)
            end
        end
        table.insert(myWar, round)
        table.sort(myWar, function (a, b)
            local ar = tonumber(a.round)
            local br = tonumber(b.round)
            return ar < br
        end)
    end

    return myWar
end

function GuildDataShowModel:GetPeriod()
    return self.cacheData.period
end

-- 当前轮次加1为正在进行的轮次
function GuildDataShowModel:GetRound()
    return self.cacheData.round
end



return GuildDataShowModel
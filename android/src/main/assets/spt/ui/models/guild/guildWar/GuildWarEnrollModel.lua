local Model = require("ui.models.Model")

local GuildWarEnrollModel = class(Model, "GuildWarEnrollModel")

function GuildWarEnrollModel:ctor(guardModel)
    self.level = 1
    self.minLevel = 1
    self.maxLevel = 9
    self.guardModel = guardModel
    self.signLevel = 0
end

function GuildWarEnrollModel:InitWithProtrol(data)
    self.data = data
    if data.signInfo.level > 0 then
        self.signLevel = clone(data.signInfo.level)
    end
    self.level = data.signInfo.openMaxLevel
    self.guardModel:InitWithProtrol(data.guard.guards, "enroll")
end

function GuildWarEnrollModel:GetLastFirstInfo(level)
    local num = 0
    for k, v in pairs(self.data.guard.first) do
        if tonumber(k) == level then
            num = tonumber(v)
            break
        end
    end
    return num
end

function GuildWarEnrollModel:GetSettlementInfo()
    return self.data.settlementInfo
end

function GuildWarEnrollModel:GetSelfAuthority()
    return self.data.guildInfo.authority
end

function GuildWarEnrollModel:GetGid()
    return self.data.guildInfo.gid
end

function GuildWarEnrollModel:SetCumulativeTotal(data)
    self.data.guildInfo.cumulative = data
end

function GuildWarEnrollModel:GetCumulativeTotal()
    return self.data.guildInfo.cumulative
end

function GuildWarEnrollModel:SetMyBuffState(buffList)
    
end

function GuildWarEnrollModel:GetMyBuffState()
    return {}
end

function GuildWarEnrollModel:GetPeriod()
    return self.data.period
end

function GuildWarEnrollModel:GetRound()
    return 0
end

function GuildWarEnrollModel:GetState()
    return self.data.state
end

function GuildWarEnrollModel:SetState(state)
    self.data.state = state
end

function GuildWarEnrollModel:GetOpenMaxLevel()
    return self.data.signInfo.openMaxLevel
end

function GuildWarEnrollModel:GetLeftTime()
    return self.data.remainTime
end

function GuildWarEnrollModel:SetLeftTime(time)
    self.data.remainTime = time
end

function GuildWarEnrollModel:GetGuardList()
    return self.guardModel:GetGuardList()
end

function GuildWarEnrollModel:GetGuardPosition(index)
    return self.guardModel:GetGuardPosition(index)
end

function GuildWarEnrollModel:SetGuardPosition(index, data)
    self.guardModel:SetGuardPosition(index, data)
end

function GuildWarEnrollModel:SetGuardList(table)
    self.guardModel:SetGuardList(table, "enroll")
end

function GuildWarEnrollModel:AddCurrLevel()
    if self.level < self.maxLevel then
        self.level = self.level + 1
    end
end

function GuildWarEnrollModel:MinusCurrLevel()
    if self.level > self.minLevel then
        self.level = self.level - 1
    end
end

function GuildWarEnrollModel:GetCurrLevel()
    return self.level
end

function GuildWarEnrollModel:SetSignLevel(level)
    self.signLevel = level
end

function GuildWarEnrollModel:GetSignLevel()
    return self.signLevel
end

function GuildWarEnrollModel:GetMinLevel()
    return self.minLevel
end

function GuildWarEnrollModel:GetMaxLevel()
    return self.maxLevel
end

function GuildWarEnrollModel:GetLevel()
    return self.data.level
end

function GuildWarEnrollModel:GetIsFirst()
    return self.data.isFirst
end

return GuildWarEnrollModel
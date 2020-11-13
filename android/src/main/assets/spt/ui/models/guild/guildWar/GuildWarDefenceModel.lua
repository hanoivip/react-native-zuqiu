local GUILDWAR_STATE = require("ui.controllers.guild.guildWar.GUILDWAR_STATE")
local GuildWarBuff = require("data.GuildWarBuff")
local Model = require("ui.models.Model")

local GuildWarDefenceModel = class(Model, "GuildWarDefenceModel")

function GuildWarDefenceModel:ctor(guardModel)
    self.guardModel = guardModel
    self.isCanChangeScene = false
end

function GuildWarDefenceModel:InitWithProtrol(guildData, data)
    self.guildData = guildData
    self.data = data
    self.guardModel:InitWithProtrol(data.guards, "defence")
end

function GuildWarDefenceModel:GetSelfAuthority()
    return self.guildData.authority
end

function GuildWarDefenceModel:GetGid()
    return self.guildData.gid
end

function GuildWarDefenceModel:SetCumulativeTotal(data)
    self.guildData.cumulative = data
end

function GuildWarDefenceModel:GetCumulativeTotal()
    return self.guildData.cumulative
end

function GuildWarDefenceModel:SetMyBuffState(buffList)
    self.data.warInfo.def.buff = buffList
end

function GuildWarDefenceModel:GetMyBuffState()
    return self.data.warInfo.def.buff
end

function GuildWarDefenceModel:GetMyBuffTxt()
    local buff = self.data.warInfo.def.buff
    if buff and buff.defBuff then
        return lang.trans("guild_war_defense", GuildWarBuff[buff.defBuff].effect)
    else
        return nil
    end
end

function GuildWarDefenceModel:GetEnemyBuffState()
    return self.data.warInfo.atk.buff
end

function GuildWarDefenceModel:GetEnemyBuffTxt()
    local buff = self.data.warInfo.atk.buff
    if buff and buff.atkBuff then
        return lang.trans("guild_war_attack", GuildWarBuff[buff.atkBuff].effect)
    else
        return nil
    end
end

function GuildWarDefenceModel:GetState()
    return GUILDWAR_STATE.FIGHTING
end

function GuildWarDefenceModel:GetGuildInfo()
    return self.data.warInfo.atk.guild
end

function GuildWarDefenceModel:GetAttackGuildGid()
    return self.data.warInfo.atk.guild.atkGid
end

function GuildWarDefenceModel:GetPeriod()
    return self.data.warInfo.detail.period
end

function GuildWarDefenceModel:GetLevel()
    return self.data.warInfo.detail.level
end

function GuildWarDefenceModel:GetRound()
    return self.data.warInfo.detail.round
end

function GuildWarDefenceModel:GetLeftTime()
    return self.data.warInfo.detail.remainTime
end

function GuildWarDefenceModel:GetCaptureCount()
    return self.data.warInfo.detail.captureCnt
end

function GuildWarDefenceModel:GetSeizeCount()
    return self.data.warInfo.detail.seizeCnt
end

function GuildWarDefenceModel:GetGuardList()
    return self.guardModel:GetGuardList()
end

function GuildWarDefenceModel:GetGuardPosition(index)
    return self.guardModel:GetGuardPosition(index)
end

function GuildWarDefenceModel:SetGuardPosition(index, data)
    self.guardModel:SetGuardPosition(index, data)
end

function GuildWarDefenceModel:SetGuardList(table)
    self.guardModel:SetGuardList(table, "defence")
end

function GuildWarDefenceModel:SetGuardPositionSeizeCnt(index, cnt)
    self.guardModel:SetGuardPositionSeizeCnt(index, cnt)
end

return GuildWarDefenceModel
local Model = require("ui.models.Model")
local GuildWarBuff = require("data.GuildWarBuff")
local GUILDWAR_STATE = require("ui.controllers.guild.guildWar.GUILDWAR_STATE")

local GuildWarAttackModel = class(Model, "GuildWarAttackModel")

function GuildWarAttackModel:ctor(guardModel)
    self.guardModel = guardModel
    self.isCanChangeScene = false
end

function GuildWarAttackModel:InitWithProtrol(guildData, data)
    self.guildData = guildData
    self.data = data
    self.guardModel:InitWithProtrol(data.guards, "attack")
end

function GuildWarAttackModel:GetSelfAuthority()
    return self.guildData.authority
end

function GuildWarAttackModel:GetGid()
    return self.guildData.gid
end

function GuildWarAttackModel:SetCumulativeTotal(data)
    self.guildData.cumulative = data
end

function GuildWarAttackModel:GetCumulativeTotal()
    return self.guildData.cumulative
end

function GuildWarAttackModel:GetSettlementInfo()
    return self.guildData.settlementInfo
end

-- table
function GuildWarAttackModel:SetMyBuffState(buffList)
    self.data.warInfo.atk.buff = buffList
end

function GuildWarAttackModel:GetMyBuffState()
    return self.data.warInfo.atk.buff
end

function GuildWarAttackModel:GetMyBuffTxt()
    local buff = self.data.warInfo.atk.buff
    if buff and buff.atkBuff then
        return lang.trans("guild_war_attack", GuildWarBuff[buff.atkBuff].effect)
    else
        return nil
    end
end

function GuildWarAttackModel:GetEnemyBuffState()
    return self.data.warInfo.def.buff
end

function GuildWarAttackModel:GetEnemyBuffTxt()
    local buff = self.data.warInfo.def.buff
    if buff and buff.defBuff then
        return lang.trans("guild_war_defense", GuildWarBuff[buff.defBuff].effect)
    else
        return nil
    end
end

function GuildWarAttackModel:GetSelfIsSeized()
    return self.data.warInfo.detail.isSeized
end

function GuildWarAttackModel:GetState()
    return GUILDWAR_STATE.FIGHTING
end

function GuildWarAttackModel:GetCountLimit()
    return self.data.countLimit
end

function GuildWarAttackModel:GetWarCnt()
    return self.data.warCnt
end

function GuildWarAttackModel:SetWarCnt(cnt)
    self.data.warCnt = cnt
end

function GuildWarAttackModel:GetGuildInfo()
    return self.data.warInfo.def.guild
end

function GuildWarAttackModel:GetDefenseGuildGid()
    return self.data.warInfo.def.guild.defGid
end

function GuildWarAttackModel:GetPeriod()
    return self.data.warInfo.detail.period
end

function GuildWarAttackModel:GetLevel()
    return self.data.warInfo.detail.level
end

function GuildWarAttackModel:GetRound()
    return self.data.warInfo.detail.round
end

function GuildWarAttackModel:GetLeftTime()
    return self.data.warInfo.detail.remainTime
end

function GuildWarAttackModel:GetCaptureCount()
    return self.data.warInfo.detail.captureCnt
end

function GuildWarAttackModel:GetSeizeCount()
    return self.data.warInfo.detail.seizeCnt
end

function GuildWarAttackModel:GetGuardList()
    return self.guardModel:GetGuardList()
end

function GuildWarAttackModel:GetGuardPosition(index)
    return self.guardModel:GetGuardPosition(index)
end

function GuildWarAttackModel:SetGuardPosition(index, data)
    self.guardModel:SetGuardPosition(index, data)
end

function GuildWarAttackModel:SetGuardList(table)
    self.guardModel:SetGuardList(table, "attack")
end

function GuildWarAttackModel:SetGuardPositionSeizeCnt(index, cnt)
    self.guardModel:SetGuardPositionSeizeCnt(index, cnt)
end

return GuildWarAttackModel
local UnityEngine = clr.UnityEngine
local Time = UnityEngine.Time
local GuildWar = require("data.GuildWar")
local GuildWarBuff = require("data.GuildWarBuff")
local GuildWarBaseSet = require("data.GuildWarBaseSet")
local GuildWarType = require("ui.models.guild.guildMistWar.GuildWarType")
local MistMapModel = require("ui.models.guild.guildMistWar.MistMapModel")
local GUILDWAR_STATE = require("ui.controllers.guild.guildWar.GUILDWAR_STATE")
local GuildWarFightType = require("ui.models.guild.guildMistWar.GuildWarFightType")
local GuildWarRegisterState = require("ui.models.guild.guildMistWar.GuildWarRegisterState")

local Model = require("ui.models.Model")

local GuildMistWarMainModel = class(Model, "GuildMistWarMainModel")

function GuildMistWarMainModel:ctor()
    GuildMistWarMainModel.super.ctor(self)
    self.mistMapModel = MistMapModel.new()
    self.mistMapModel:SetGuildMistWarMainModel(self)
end

function GuildMistWarMainModel:Init()

end

function GuildMistWarMainModel:InitWithProtocol(data)
    self.guildInfo = data
    self.fightType = GuildWarFightType.Register
    if data.state == GUILDWAR_STATE.PREPARE then
        self.mistMapModel:InitEditorWithProtocol(data)
    else
        self.mistMapModel:InitWithProtocol(data)
    end
    self:SetRegisterInfo(data.signInfo)
    self.startTime = Time.unscaledTime
end

-- 进攻信息
function GuildMistWarMainModel:InitAttackWithProtocol(attackInfo)
    self.attackInfo = attackInfo
    self.fightType = GuildWarFightType.Attack
    self.attackStartTime = Time.unscaledTime
    self.mistMapModel:InitAttackWithProtocol(attackInfo)
end

-- 防守信息
function GuildMistWarMainModel:InitDefenderWithProtocol(defenderInfo)
    self.defenderInfo = defenderInfo
    self.fightType = GuildWarFightType.Defend
    self.defendStartTime = Time.unscaledTime
    self.mistMapModel:InitDefenderWithProtocol(defenderInfo)
end

-- 报名信息
function GuildMistWarMainModel:SetRegisterInfo(registerInfo)
    self.registerInfo = registerInfo
end

-- 报名信息的时候最大普通公会战开启等级
function GuildMistWarMainModel:GetOpenMaxLevel()
    return self.registerInfo.openMaxLevel or 8
end

-- 在那个页面上 GuildWarFightType
function GuildMistWarMainModel:GetGuildWarFightType()
    return self.fightType or GuildWarFightType.Register
end

-- 获取报名状态
function GuildMistWarMainModel:GetMistRegisterState()
    local level = self:GetRegisterLevel()
    local levelStr = tostring(level)
    local openLevel = self.data.openLevel
    local addition = self:GetAddition()
    local isLock = openLevel < addition
    if isLock then
        return GuildWarRegisterState.Lock
    end
    if level > 0 then
        local currWarType = GuildWar[levelStr].type
        if currWarType == warType then
            return GuildWarRegisterState.Registered
        else
            return GuildWarRegisterState.NoneRegister
        end
    else
        return GuildWarRegisterState.CanRegister
    end
end

-- 解锁条件
function GuildMistWarMainModel:GetAddition()
    local addition = GuildWarBaseSet[GuildWarType.Mist].addition or 0
    return addition
end

-- 公会战层级ID
function GuildMistWarMainModel:GetRegisterLevel()
    local level = self.registerInfo.level
    return level
end

-- 迷雾战场公会战报名内部层级
function GuildMistWarMainModel:GetRegisterMinLevel()
    local level = self:GetRegisterLevel()
    if level < 0 then
        level = self:GetLevel()
    end
    local levelStr = tostring(level)
    local minLevel = GuildWar[levelStr].minLevel
    return minLevel
end

-- 迷雾战场公会战战斗内部层级
function GuildMistWarMainModel:GetFightMinLevel()
    local level = self:GetLevel()
    local levelStr = tostring(level)
    local minLevel = GuildWar[levelStr].minLevel
    return minLevel
end

-- 公会战的状态 对应 GUILDWAR_STATE
function GuildMistWarMainModel:GetWarState()
    local guildInfo = self:GetGuildInfo()
    local state = guildInfo.state
    return state
end

-- 公会战的期数
function GuildMistWarMainModel:GetPeriod()
    local guildInfo = self:GetGuildInfo()
    local period = guildInfo.period
    return period
end

-- 贡献值
function GuildMistWarMainModel:SetCumulativeTotal(cumulative)
    local guildInfo = self:GetGuildInfo()
    guildInfo.cumulative = cumulative
end

-- 公会战当前层级 / 可报名层级
function GuildMistWarMainModel:GetLevel()
    local guildInfo = self:GetGuildInfo()
    local level = guildInfo.level
    return level or 10
end

-- 公会战的剩余时间
function GuildMistWarMainModel:GetRemainTime()
    local guildInfo = self:GetGuildInfo()
    local remainTime = guildInfo.remainTime
    local duringTime = Time.unscaledTime - self.startTime
    return remainTime - duringTime
end

-- 公会战开始后当前页面是进攻还是防守
function GuildMistWarMainModel:GetFightState()

end

-- 公会战开始后当前页面是进攻还是防守
function GuildMistWarMainModel:SetFightState(fightState)

end

-- 公会战进攻信息
function GuildMistWarMainModel:SetAttackData(attackData)
    self.attackData = attackData
end

-- 公会战进攻信息
function GuildMistWarMainModel:SetDefenderData(defenderData)
    self.defenderData = defenderData
end

-- 地图玩家的信息
function GuildMistWarMainModel:SetGuardList(guards)
    for k, v in pairs(guards) do
        v.index = k
    end
    local guildInfo = self:GetGuildInfo()
    guildInfo.guards = guards
    EventSystem.SendEvent("GuildWarGuardModel_RefreshGuardPosition", guards)
end

-- 地图玩家的信息
function GuildMistWarMainModel:GetGuardList()
    local guildInfo = self:GetGuildInfo()
    return guildInfo.guard.guards
end

function GuildMistWarMainModel:GetMistMapModel()
    return self.mistMapModel
end

-- 我的公会基础信息
function GuildMistWarMainModel:SetGuildInfo(guildInfo)
    self.guildInfo = guildInfo
end

function GuildMistWarMainModel:GetGuildInfo()
    return self.guildInfo
end

-- 我的权限
function GuildMistWarMainModel:GetAuthority()
    local guildInfo = self:GetGuildInfo()
    local authority = guildInfo.authority
    return authority
end

-- 防守席位数量 最大的格子数
function GuildMistWarMainModel:GetDefendAmount()
    local defendAmount = GuildWarBaseSet[GuildWarType.Mist].defendAmount or 0
    return defendAmount
end

-- 防守席位的最大生命值
function GuildMistWarMainModel:GetDefendLife()
    local defendLife = GuildWarBaseSet[GuildWarType.Mist].defendLife or 0
    return defendLife
end

-- 更新进攻席位信息
function GuildMistWarMainModel:UpdateAttackGuardData(data)
    local attackInfo = self:GetAttackInfo()
    local guards = attackInfo.guards
    for key, v in pairs(data) do
        if key == "settlement" then
            for pos, posData in pairs(v) do
                guards[pos] = posData
            end
        else
            attackInfo[key] = v
        end
    end
    local mistMapModel = self:GetMistMapModel()
    mistMapModel:UpdateAttackGuardData(data)
    EventSystem.SendEvent("GuildMistWarMainModel_UpdateGuardData", self)
end

-- buff
function GuildMistWarMainModel:SetBuff(buff)
    local attackInfo = self:GetAttackInfo()
    local defenderInfo = self:GetDefenderInfo()
    if attackInfo and attackInfo.warInfo.atk and attackInfo.warInfo.atk.buff then
        attackInfo.warInfo.atk.buff = buff
    end
    if defenderInfo and defenderInfo.warInfo.def and defenderInfo.warInfo.def.buff then
        defenderInfo.warInfo.def.buff = buff
    end
end

function GuildMistWarMainModel:GetGid()
    local guildInfo = self:GetGuildInfo()
    return guildInfo.gid
end

-- 公会战第几轮
function GuildMistWarMainModel:GetRound()
    local attackInfo = self:GetAttackInfo()
    local round = 1
    if not attackInfo then
        local guildInfo = self:GetGuildInfo()
        round = guildInfo.round
    else
        round = attackInfo.warInfo.detail.round
    end
    return round
end

function GuildMistWarMainModel:GetMaxRound()
    local attackInfo = self:GetGuildInfo()
    return attackInfo.maxRounds
end

-- 是否是第一次公会战
function GuildMistWarMainModel:IsFirst()
    local guildInfo = self:GetGuildInfo()
    return guildInfo.isFirst
end

-- 前一轮的战绩
function GuildMistWarMainModel:GetSettlementInfo()
    local guildInfo = self:GetGuildInfo()
    return guildInfo.settlementInfo
end

-- 总积分
function GuildMistWarMainModel:GetTotalScore()
    local guildInfo = self:GetGuildInfo()
    return guildInfo.mistScore or 0
end

-- 总积分进攻
function GuildMistWarMainModel:GetAttackTotalScore()
    local guildInfo = self:GetAttackInfo()
    local atkScore = guildInfo.atkScore or 0
    return atkScore
end

-- 总积防守
function GuildMistWarMainModel:GetDefTotalScore()
    local guildInfo = self:GetDefenderInfo()
    local defScore = guildInfo.defScore or 0
    return defScore
end

------------------------------------
---  进攻
------------------------------------

-- 对手所有信息
function GuildMistWarMainModel:GetAttackInfo()
    return self.attackInfo
end

-- 对手公会信息
function GuildMistWarMainModel:GetAttackGuildInfo()
    local attackInfo = self:GetAttackInfo()
    return attackInfo.warInfo.def.guild
end

-- 对手剩余时间
function GuildMistWarMainModel:GetAttackRemainTime()
    local attackInfo = self:GetAttackInfo()
    local remainTime = attackInfo.warInfo.detail.remainTime
    local nowTime = Time.unscaledTime
    local t = remainTime - nowTime + self.attackStartTime
    return t
end

-- 对手第几轮
function GuildMistWarMainModel:GetAttackRound()
    local attackInfo = self:GetAttackInfo()
    return attackInfo.warInfo.detail.round
end

-- 对手第几期
function GuildMistWarMainModel:GetAttackPeriod()
    local attackInfo = self:GetAttackInfo()
    return attackInfo.warInfo.detail.period
end

-- 对手第几层
function GuildMistWarMainModel:GetAttackLevel()
    local attackInfo = self:GetAttackInfo()
    return attackInfo.warInfo.detail.level
end

-- 对手BUFF
function GuildMistWarMainModel:GetAttackBuffStr()
    local attackInfo = self:GetAttackInfo()
    if attackInfo then
        local buff = attackInfo.warInfo.atk and attackInfo.warInfo.atk.buff
        if next(buff) and buff.atkBuff then
            return lang.trans("guild_war_attack", GuildWarBuff[buff.atkBuff].effect)
        else
            return nil
        end
    end
end

-- 当前公会战中占领了几个席位
function GuildMistWarMainModel:GetAttackOccupyCount()
    local attackInfo = self:GetAttackInfo()
    local guards = attackInfo.guards
    local occupyCount = 0
    for i, v in pairs(guards) do
        if v.isCaptured then
            occupyCount = occupyCount + 1
        end
    end
    return occupyCount
end

-- 我自己当前已经进攻的次数
function GuildMistWarMainModel:GetAttackWarCnt()
    local attackInfo = self:GetAttackInfo()
    return attackInfo.warCnt
end

-- 我自己的最大进攻次数
function GuildMistWarMainModel:GetAttackCountLimit()
    local attackInfo = self:GetAttackInfo()
    return attackInfo.countLimit
end

------------------------------------
---  进攻结束
------------------------------------

------------------------------------
---  防守开始
------------------------------------

-- 防守所有信息
function GuildMistWarMainModel:GetDefenderInfo()
    return self.defenderInfo
end

-- 防守公会信息
function GuildMistWarMainModel:GetDefenderGuildInfo()
    local defenderInfo = self:GetDefenderInfo()
    return defenderInfo.warInfo.atk.guild
end

-- 防守剩余时间
function GuildMistWarMainModel:GetDefenderRemainTime()
    local defenderInfo = self:GetDefenderInfo()
    local remainTime = defenderInfo.warInfo.detail.remainTime
    local nowTime = Time.unscaledTime
    local t = remainTime - nowTime + self.attackStartTime
    return t
end

-- 防守第几轮
function GuildMistWarMainModel:GetDefenderRound()
    local defenderInfo = self:GetDefenderInfo()
    return defenderInfo.warInfo.detail.round
end

-- 防守第几期
function GuildMistWarMainModel:GetDefenderPeriod()
    local defenderInfo = self:GetDefenderInfo()
    return defenderInfo.warInfo.detail.period
end

-- 防守第几层
function GuildMistWarMainModel:GetDefenderLevel()
    local defenderInfo = self:GetDefenderInfo()
    return defenderInfo.warInfo.detail.level
end

-- 防守BUFF
function GuildMistWarMainModel:GetDefenderBuffStr()
    local defenderInfo = self:GetDefenderInfo()
    if defenderInfo then
        local buff = defenderInfo.warInfo.def and defenderInfo.warInfo.def.buff
        if next(buff) and buff.defBuff then
            return lang.trans("guild_war_defense", GuildWarBuff[buff.defBuff].effect)
        else
            return nil
        end
    end
end

-- 当前公会战中被占领了几个席位
function GuildMistWarMainModel:GetDefenderOccupyCount()
    local defenderInfo = self:GetDefenderInfo()
    local guards = defenderInfo.guards
    local occupyCount = 0
    for i, v in pairs(guards) do
        if v.isCaptured then
            occupyCount = occupyCount + 1
        end
    end
    return occupyCount
end

------------------------------------
---  防守结束
------------------------------------

return GuildMistWarMainModel

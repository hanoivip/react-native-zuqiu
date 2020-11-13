local Model = require("ui.models.Model")
local GuildWarBuff = require("data.GuildWarBuff")
local GuildWarType = require("ui.models.guild.guildMistWar.GuildWarType")

local GuildBuffStoreModel = class(Model)

function GuildBuffStoreModel:ctor(attackOrDefenseModel, buffData)
    GuildBuffStoreModel.super.ctor(self)
    assert(attackOrDefenseModel)

    self.attackOrDefenseModel = attackOrDefenseModel
    self.staticData = {}
    self.buff = {}
    self.buffData = buffData
    self:ResetStaticData()
end

-- 数组排列，供scroll使用
function GuildBuffStoreModel:ResetStaticData()
    for k, v in pairs(GuildWarBuff) do
        if v.guildwarType == GuildWarType.Common then
            table.insert(self.staticData, v)
            v.key = k
        end
    end
    table.sort(self.staticData, function (a, b)
        return tonumber(a.order) < tonumber(b.order)
    end)
end

function GuildBuffStoreModel:GetBuffDatas()
    return self.staticData
end

-- 设置贡献点
function GuildBuffStoreModel:SetCumulativeTotal(value)
    self.attackOrDefenseModel:SetCumulativeTotal(value)
end

-- 获得贡献点
function GuildBuffStoreModel:GetCumulativeTotal()
    return self.attackOrDefenseModel:GetCumulativeTotal()
end

-- 获得
function GuildBuffStoreModel:GetMyBuffState()
    return self.attackOrDefenseModel:GetMyBuffState()
end

-- table
function GuildBuffStoreModel:SetBuff(isattackBuff, buffName)
    local buffTable = {}
    if isattackBuff then
        buffTable.atkBuff = buffName
        buffTable.defBuff = self:GetMyBuffState().defBuff
    else
        buffTable.atkBuff = self:GetMyBuffState().atkBuff
        buffTable.defBuff =buffName
    end
    self.attackOrDefenseModel:SetMyBuffState(buffTable)
end

function GuildBuffStoreModel:GetPeriod()
    return self.attackOrDefenseModel:GetPeriod()
end

function GuildBuffStoreModel:GetRound()
    return self.attackOrDefenseModel:GetRound()
end

function GuildBuffStoreModel:GetLevel()
    return self.buffData.level or self.attackOrDefenseModel:GetLevel()
end

-- 获得官职
function GuildBuffStoreModel:GetSelfAuthority()
    return self.attackOrDefenseModel:GetSelfAuthority()
end

-- 设置轮次的已购buff
function GuildBuffStoreModel:SetBuffByRound(round, buff)
    self.buff.round = buff
end

function GuildBuffStoreModel:GetBuffByRound(round)
    return self.buff.round
end

function GuildBuffStoreModel:SetBuffInfo(buffInfo)
    self.buffInfo = buffInfo
end

function GuildBuffStoreModel:ResetBuffInfoOrder(buffTable)
    local atkKey = (buffTable and buffTable.atkBuff) or self.buffInfo.atkBuff
    local defKey = (buffTable and buffTable.defBuff) or self.buffInfo.defBuff
    local buffData = self:GetBuffDatas()
    for i,v in ipairs(buffData) do
        if v.key == atkKey then
            self.buffInfo.atkOrder = v.order
        end
        if v.key == defKey then
            self.buffInfo.defOrder = v.order
        end
    end
    return self.buffInfo
end

return GuildBuffStoreModel
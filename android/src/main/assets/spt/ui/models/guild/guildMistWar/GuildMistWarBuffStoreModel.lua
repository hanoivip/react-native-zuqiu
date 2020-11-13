local Model = require("ui.models.Model")
local GuildWarBuff = require("data.GuildWarBuff")
local GuildMistShop = require("data.GuildMistShop")
local CommonConstants = require("ui.common.CommonConstants")

local GuildMistWarBuffStoreModel = class(Model)

function GuildMistWarBuffStoreModel:ctor(round)
    GuildMistWarBuffStoreModel.super.ctor(self)
    self.showRound = round -- 进入时显示那一轮的buff  nil为当前工会战的轮次
    self.staticData = {}
    self.buff = {}
    self:ResetStaticData()
end

function GuildMistWarBuffStoreModel:InitWithProtocol(storeData)
    self.storeData = storeData
end

function GuildMistWarBuffStoreModel:SetGuildMistWarMainModel(guildMistWarMainModel)
    self.guildMistWarMainModel = guildMistWarMainModel
end

function GuildMistWarBuffStoreModel:GetGuildMistWarMainModel()
    return self.guildMistWarMainModel
end

function GuildMistWarBuffStoreModel:GetAllBuff()
    local buff = self.storeData.list.buff
    return buff
end

function GuildMistWarBuffStoreModel:SetAllBuff(buff)
    self.storeData.list.buff = buff
    local round = self:GetCurrentRound()
    round = tostring(round)
    local roundBuff = buff[round] or {}
    EventSystem.SendEvent("GuildMistWarMainModel_UpdateBuff", roundBuff)
end

function GuildMistWarBuffStoreModel:GetMaxOrderByType(buffType, round)
    if buffType == "atk" then
        return self:GetMaxAtkOrder(round)
    else
        return self:GetMaxDefOrder(round)
    end
end

-- 当前进行的轮次
function GuildMistWarBuffStoreModel:GetNowRound()
    return self.storeData.list.round
end

function GuildMistWarBuffStoreModel:GetMaxRound()
    local guildMistWarMainModel = self:GetGuildMistWarMainModel()
    local maxRound = guildMistWarMainModel:GetMaxRound()
    return maxRound or CommonConstants.GuildMistWarMaxRound
end

-- 最大的进攻buff  买过等级高的buff  等级低的默认为已买过
function GuildMistWarBuffStoreModel:GetMaxAtkOrder(round)
    local buff = self:GetAllBuff()
    round = tostring(round)
    local atkBuffKey = buff[round].atkBuff
    local order = -1
    if atkBuffKey then
        order = GuildWarBuff[atkBuffKey].order
    end
    return order
end

-- 最大的防御buff  买过等级高的buff  等级低的默认为已买过
function GuildMistWarBuffStoreModel:GetMaxDefOrder(round)
    local buff = self:GetAllBuff()
    round = tostring(round)
    local defBuffKey = buff[round].defBuff
    local order = -1
    if defBuffKey then
        order = GuildWarBuff[defBuffKey].order
    end
    return order
end

function GuildMistWarBuffStoreModel:SetSelectRound(round)
    self.selectRound = round
end

function GuildMistWarBuffStoreModel:GetSelectRound()
    if not self.selectRound then
        self.selectRound = self:GetCurrentRound()
    end
    return self.selectRound
end

function GuildMistWarBuffStoreModel:GetCurrentRound()
    if not self.showRound then
        local guildMistWarMainModel = self:GetGuildMistWarMainModel()
        return guildMistWarMainModel:GetAttackRound()
    else
        return tonumber(self.showRound)
    end
end

-- 权限
function GuildMistWarBuffStoreModel:GetSelfAuthority()
    local guildMistWarMainModel = self:GetGuildMistWarMainModel()
    local authority = guildMistWarMainModel:GetAuthority()
    authority = tonumber(authority)
    return authority
end

-- 数组排列，供scroll使用
function GuildMistWarBuffStoreModel:ResetStaticData()
    for k, v in pairs(GuildWarBuff) do
        if v.guildwarType == "mist" then
            if not self.attackStatic then
                self.attackStatic = {}
            end
            if not self.defendStatic then
                self.defendStatic = {}
            end
            v.id = k
            if v.type == "atk" then
                table.insert(self.attackStatic, v)
            end
            if v.type == "def" then
                table.insert(self.defendStatic, v)
            end
        end
    end
    table.sort(self.attackStatic, function (a, b)
        return tonumber(a.order) < tonumber(b.order)
    end)
    table.sort(self.defendStatic, function (a, b)
        return tonumber(a.order) < tonumber(b.order)
    end)
end

function GuildMistWarBuffStoreModel:GetAttackStatic()
    return self.attackStatic
end

function GuildMistWarBuffStoreModel:GetDefendStatic()
    return self.defendStatic
end

function GuildMistWarBuffStoreModel:GetAttackBuffData()
    local buffData = {}
    buffData.static = self.attackStatic
    return buffData
end

function GuildMistWarBuffStoreModel:GetDefendBuffData()
    local buffData = {}
    buffData.static = self.defendStatic
    return buffData
end

-- 设置贡献点
function GuildMistWarBuffStoreModel:SetCumulativeTotal(value)
    self.storeData.list.cumulativeDay = value
    local guildMistWarMainModel = self:GetGuildMistWarMainModel()
    guildMistWarMainModel:SetCumulativeTotal(value)
end

-- 获得贡献点
function GuildMistWarBuffStoreModel:GetCumulativeTotal()
    local cumulativeDay = self.storeData.list.cumulativeDay
    return cumulativeDay
end

-- 当前层级
function GuildMistWarBuffStoreModel:GetMinLevel()
    local guildMistWarMainModel = self:GetGuildMistWarMainModel()
    local minLevel = guildMistWarMainModel:GetFightMinLevel()
    minLevel = tostring(minLevel)
    return minLevel or "1"
end

-- 获得Buff
function GuildMistWarBuffStoreModel:GetMyBuffState()
    local guildMistWarMainModel = self:GetGuildMistWarMainModel()
    return guildMistWarMainModel:GetMyBuffState()
end

-- table
function GuildMistWarBuffStoreModel:SetAtkBuff(round, atkBuff)
    local buff = self:GetAllBuff()
    round = tostring(round)
    buff[round].atkBuff = atkBuff
    self:SetAllBuff(buff)
end

function GuildMistWarBuffStoreModel:SetDefBuff(round, defBuff)
    local buff = self:GetAllBuff()
    round = tostring(round)
    buff[round].defBuff = defBuff
    self:SetAllBuff(buff)
end

function GuildMistWarBuffStoreModel:GetPeriod()
    local guildMistWarMainModel = self:GetGuildMistWarMainModel()
    return guildMistWarMainModel:GetPeriod()
end

function GuildMistWarBuffStoreModel:GetRound()
    local guildMistWarMainModel = self:GetGuildMistWarMainModel()
    return guildMistWarMainModel:GetRound()
end

function GuildMistWarBuffStoreModel:GetLevel()
    local guildMistWarMainModel = self:GetGuildMistWarMainModel()
    return guildMistWarMainModel:GetLevel()
end

-- 设置轮次的已购buff
function GuildMistWarBuffStoreModel:SetBuffByRound(round, buff)
    self.buff.round = buff
end

function GuildMistWarBuffStoreModel:GetBuffByRound(round)
    return self.buff.round
end

function GuildMistWarBuffStoreModel:SetBuffInfo(buffInfo)
    self.buffInfo = buffInfo
end

function GuildMistWarBuffStoreModel:ResetBuffInfoOrder(buffTable)
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

----------------------------------
--- Item Store
-------------------------------------

-- 物品商店 静态数据
function GuildMistWarBuffStoreModel:GetItemStoreStaticList()
    local itemStoreList = {}
    local tGuildMistShop = clone(GuildMistShop)
    for i, v in pairs(tGuildMistShop) do
        v.id = i
        table.insert(itemStoreList, v)
    end
    table.sort(itemStoreList, function(a, b) return a.order < b.order end)
    return itemStoreList
end

-- 物品商店 服务器数据
function GuildMistWarBuffStoreModel:GetItemStoreServerList()
    return self.storeData.list.map or {}
end

-- 物品商店 当前物品对应的地图id还剩余多少使用次数
function GuildMistWarBuffStoreModel:SetItemStoreServerList(maps)
    self.storeData.list.map = maps
end

-- 物品商店 当前物品对应的地图id还剩余多少使用次数
function GuildMistWarBuffStoreModel:GetItemStoreMapRemainCount(mapid)
    local iList = self:GetItemStoreServerList()
    return iList[mapid] or 0
end

return GuildMistWarBuffStoreModel

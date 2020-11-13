local GuildMistWarMap = require("data.GuildMistWarMap")
local GUILDWAR_STATE = require("ui.controllers.guild.guildWar.GUILDWAR_STATE")
local GuildWarFightType = require("ui.models.guild.guildMistWar.GuildWarFightType")
local GuildMistWarMapItemState = require("ui.models.guild.guildMistWar.GuildMistWarMapItemState")
local Model = require("ui.models.Model")

local MistMapModel = class(Model, "MistMapModel")

function MistMapModel:ctor(mapData)
    MistMapModel.super.ctor(self)
    self.connectedMap = {}
    self:SetMapData(mapData)
end

function MistMapModel:Init()

end

function MistMapModel:InitWithProtocol(guildInfo)
    self.guildInfo = guildInfo
    if guildInfo.mistMapId then
        local idStr = tostring(guildInfo.mistMapId)
        self.mapData = GuildMistWarMap[idStr]
        self:InitMapPosition()
        self:SetIsDefender(true)
    end
    self.round = guildInfo.round
    self.fightType = GuildWarFightType.Register
    self:SetGuardList(guildInfo.guards)
end

function MistMapModel:SetGuildMistWarMainModel(guildMistWarMainModel)
    self.guildMistWarMainModel = guildMistWarMainModel
end

function MistMapModel:GetGuildMistWarMainModel()
    return self.guildMistWarMainModel
end

-- 低于此轮次不能查看和编辑
function MistMapModel:GetCanEditorMinRound()
    local state = self:GetWarState() or GUILDWAR_STATE.FIGHTING
    if state == GUILDWAR_STATE.FIGHTING then
        return self.canEditorMinRound or 1
    else
        return 0
    end
end

function MistMapModel:SetCanEditorMinRound(canEditorMinRound)
    if canEditorMinRound then
        self.canEditorMinRound = canEditorMinRound
    end
end

function MistMapModel:GetMaxRound()
    local guildInfo = self:GetGuildInfo()
    return guildInfo.maxRounds
end

-- 进攻信息
function MistMapModel:InitEditorWithProtocol(editorInfo)
    self.guildInfo = editorInfo
    if editorInfo.mistMapId then
        local idStr = tostring(editorInfo.mistMapId)
        self.mapData = GuildMistWarMap[idStr]
        self:InitMapPosition()
    end

    self.round = editorInfo.round
    self:SetIsDefender(true)
    self.fightType = GuildWarFightType.Register
    self:SetGuardList(editorInfo.guards)
end

-- 进攻信息
function MistMapModel:InitAttackWithProtocol(attackInfo)
    self.attackInfo = attackInfo
    if attackInfo.mistMapId then
        local idStr = tostring(attackInfo.mistMapId)
        self.mapData = GuildMistWarMap[idStr]
        self:InitMapPosition()
    end

    self.round = attackInfo.round
    self:SetIsDefender(false)
    self.fightType = GuildWarFightType.Attack
    self:SetGuardList(attackInfo.guards)
end

-- 防守信息
function MistMapModel:InitDefenderWithProtocol(defenderInfo)
    self.defenderInfo = defenderInfo
    if defenderInfo.mistMapId then
        local idStr = tostring(defenderInfo.mistMapId)
        self.mapData = GuildMistWarMap[idStr]
        self:InitMapPosition()
    end

    self.round = defenderInfo.round
    self:SetIsDefender(true)
    self.fightType = GuildWarFightType.Defend
    self:SetGuardList(defenderInfo.guards)
end

function MistMapModel:UpdateAttackGuardData(data)
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
    self:InitAttackWithProtocol(attackInfo)
    EventSystem.SendEvent("MistMapModel_UpdateGuardData", self)
end

function MistMapModel:GetGuildInfo()
    return self.guildInfo
end

function MistMapModel:GetRound()
    return self.round or 1
end

function MistMapModel:GetAttackInfo()
    return self.attackInfo
end

function MistMapModel:GetGuildWarFightType()
    return self.fightType
end

-- 防守席位的最大生命值
function MistMapModel:GetDefendLife()
    local guildMistWarMainModel = self:GetGuildMistWarMainModel()
    local defendLife = guildMistWarMainModel:GetDefendLife()
    return defendLife
end

-- 权限
function MistMapModel:GetAuthority()
    local guildMistWarMainModel = self:GetGuildMistWarMainModel()
    local authority = guildMistWarMainModel:GetAuthority()
    return authority
end

-- 公会战的状态 对应 GUILDWAR_STATE
function MistMapModel:GetWarState()
    local guildInfo = self:GetGuildInfo()
    local state = guildInfo.state
    if not state then
        local guildMistWarMainModel = self:GetGuildMistWarMainModel()
        state = guildMistWarMainModel:GetWarState()
    end
    return state
end

function MistMapModel:AddGuardListIndex(guards)
    -- (数据中没有格子位置  添加一下)
    local guildInfo = self:GetGuildInfo()
    if guards and next(guards) then
        for k, v in pairs(guards) do
            v.index = k
        end
    else
        -- 未分组前  没有阵容信息  用默认的地图信息
        guards = {}
        for i, v in pairs(self.mapData.mapPosList) do
            local t = {}
            local index = tostring(i)
            t.index = index
            t.level = v.level
            guards[index] = t
        end
    end
    guildInfo.guards = guards
    return guards
end

-- 设置防守列表
function MistMapModel:SetGuardList(guards)
    guards = self:AddGuardListIndex(guards)
    self.guards = guards
    self:CacheMapData()
    EventSystem.SendEvent("GuildMistWar_RefreshGuardPosition", guards)
end

-- 防守列表
function MistMapModel:GetGuardList()
    return self.guards
end

-- 获取某个位置上的单个防守成员
function MistMapModel:GetGuardDataByIndex(index)
    index = tostring(index)
    local guardList = self:GetGuardList()
    local guardData = guardList[index] or {index = index}
    return guardData
end

-- 获取配表中的格子信息
function MistMapModel:GetStaticMapDataByIndex(index)
    index = tostring(index)
    local mapPosList = self:GetMapPosList()
    local staticMapData = mapPosList[index] or {}
    return staticMapData
end

-- 根据格子id获取格子的状态  GuildMistWarMapItemState
function MistMapModel:GetMapItemStateByIndex(mapItemIndex)
    mapItemIndex = tostring(mapItemIndex)
    local allPosState = self:GetAllPosState()
    local posState = allPosState[mapItemIndex]
    if not posState then
        return GuildMistWarMapItemState.Hide
    end
    if not posState.isOpen then
        return GuildMistWarMapItemState.Mist
    end
    local guardList = self:GetGuardList()
    local itemGuardData = guardList[mapItemIndex]
    if not itemGuardData then
        return GuildMistWarMapItemState.Empty
    end
    if itemGuardData.isCaptured then
        return GuildMistWarMapItemState.Captured
    elseif itemGuardData.name then
        return GuildMistWarMapItemState.Occupy
    end
    return GuildMistWarMapItemState.Empty
end

-- 根据格子id获取格子的显示和隐藏
function MistMapModel:GetPosStateByIndex(index)
    index = tostring(index)
    local allPosState = self:GetAllPosState()
    return allPosState[index]
end

-- 当前地图信息
function MistMapModel:SetMapData(mapData)
    if mapData then
        self.mapData = mapData
        self:InitMapKingPosition()
    end
end

-- 当前地图信息
function MistMapModel:GetMapData()
    return self.mapData
end

-- 当前地图的格子信息
function MistMapModel:GetMapItemData(mapItemIndex)
    mapItemIndex = tostring(mapItemIndex)
    local mapItemData = self.mapData.mapPosList[mapItemIndex]
    return mapItemData
end

-- 记录一下连接的两个点
function MistMapModel:ConnectIndex(startIndex, endIndex)
    if not self.connectedMap[startIndex] then
        self.connectedMap[startIndex] = {}
    end
    self.connectedMap[startIndex][endIndex] = true
end

-- 这两个点是否已经连接过了（防止重复连接）
function MistMapModel:IsConnected(startIndex, endIndex)
    local startConnected = self.connectedMap[startIndex] and self.connectedMap[startIndex][endIndex]
    local endConnected = self.connectedMap[endIndex] and self.connectedMap[endIndex][startIndex]
    return startConnected or endConnected
end

-- 获取地图的连接信息
function MistMapModel:GetMapPosList()
    return self.mapData.mapPosList
end

-- 获取地图的连接信息
function MistMapModel:GetMapPosListWithoutEmpty()
    return self.mapData.mapPosList
end

-- 重置储存的连接点
function MistMapModel:ResetConnect()
    self.connectedMap = {}
end

-- 转换不能移动的格子的table格式为Key Value
function MistMapModel:InitMapPosition()
    local mapKingPosition = self.mapData.mapKingPosition
    local default = self.mapData.default
    local kingArr = {}
    local defaultArr = {}
    for i, v in pairs(mapKingPosition) do
        local pStr = tostring(v)
        kingArr[pStr] = pStr
    end
    for i, v in pairs(default) do
        local pStr = tostring(v)
        defaultArr[pStr] = pStr
    end
    self.kingPos = kingArr
    self.defaultPos = defaultArr
end

-- 是否是不能移动的格子
function MistMapModel:IsKingPos(posIndex)
    posIndex = tostring(posIndex)
    local king = self.kingPos[posIndex]
    return tobool(king)
end

-- 是否是默认开启的格子
function MistMapModel:IsDefaultPos(posIndex)
    posIndex = tostring(posIndex)
    return self.defaultPos[posIndex]
end

-- 根据格子id获取格子是否是空格子
function MistMapModel:IsEmptyPos(index)
    index = tostring(index)
    local emptyMapPosList = self.mapData.emptyMapPosList
    return emptyMapPosList[index]
end

-- 根据格子id获取格子是否是关闭状态 配表没有的格子
function MistMapModel:IsClosedPos(index)
    index = tostring(index)
    local mapPosList = self:GetMapPosList()
    local emptyMapPosList = self.mapData.emptyMapPosList
    local empty = emptyMapPosList[index]
    local posData = mapPosList[index]
    return (not posData) and (not empty)
end

-- 所有连线的 显示状态
--[[
{
    10_4 = {
        isShow = false,
        pos1 = "10",
        pos2 = "10",
    },
},
]]--
function MistMapModel:GetAllLineState()
    return self.lineList or {}
end

-- 所有位置点的 显示状态
--[[
20 = {
    isOpen = true,
},
]]--
function MistMapModel:GetAllPosState()
    return self.posStateList or {}
end

-- 预先计算地图的 点 和 连线
function MistMapModel:CacheMapData()
    local mapPosList = self:GetMapPosList()
    local guardList = self:GetGuardList()
    --- 检查每一个点是否开启 （隐藏 显示的状态）
    --- 若未开启 标记当前点未开启 不再往下查询
    --- 若开启 标记当前点 当前点的空连接点 和 非空连接点 都标记为开启 （default 是默认开启的点）
    --- 全部执行完之后 遍历空连接点 没有被标记为开启的  就肯定是未开启的点
    --- 若点不是默认 不是连接点 不是空连接点 那这个点是不和任何点连接  在地图上是不能部署 默认全部隐藏
    local posStateList = {}
    for k, v in pairs(mapPosList) do
        local startIndex = tostring(k)
        local isDefault = self:IsDefaultPos(startIndex)
        local isCaptured = guardList[startIndex].isCaptured
        if not posStateList[startIndex] then
            posStateList[startIndex] = {}
        end
        if isCaptured then
            local needOpenPos, needEmptyPos = self:CalculateNearPos(startIndex)
            posStateList[startIndex].isOpen = true
            for i, v in pairs(needOpenPos) do
                local index = tostring(v)
                if not posStateList[index] then
                    posStateList[index] = {}
                end
                posStateList[index].isOpen = true
            end
            for i, v in pairs(needEmptyPos) do
                local index = tostring(v)
                if not posStateList[index] then
                    posStateList[index] = {}
                end
                posStateList[index].isOpen = true
            end
        elseif isDefault then
            posStateList[startIndex].isOpen = true
        else
            if next(posStateList[startIndex]) == nil then
                posStateList[startIndex].isOpen = false
            end
        end
    end
    local emptyMapPosList = self.mapData.emptyMapPosList
    for i, v in pairs(emptyMapPosList) do
        local index = tostring(i)
        if not posStateList[index] then
            posStateList[index] = {}
            posStateList[index].isOpen = false
        end
    end

    --- 预先计算地图的 连线信息
    --- （连线的个数  连线是否显示）
    self:ResetConnect()
    local lineList = {}
    for k, v in pairs(mapPosList) do
        local startIndex = tostring(k)
        for i, posIndex in ipairs(v.posInfo) do
            local isConnected = self:IsConnected(startIndex, posIndex)
            if not isConnected then
                local isOpenStart = posStateList[startIndex].isOpen
                local isOpenPos = posStateList[posIndex].isOpen
                local isStartDefault = self:IsDefaultPos(startIndex)
                local isPosDefault = self:IsDefaultPos(posIndex)
                local lineKey = self:GetLineNameKey(startIndex, posIndex)
                local isDefault = isPosDefault or isStartDefault
                local lineData = {}
                lineData.pos1 = startIndex
                lineData.pos2 = posIndex
                -- 默认点相连的点都始终显示连线
                -- 非默认点相连的点 两个点都开启才显示连线
                lineData.isShow = tobool(isOpenStart and isOpenPos)
                lineList[lineKey] = lineData
                self:ConnectIndex(startIndex, posIndex)
            end
        end
    end
    self.posStateList = posStateList
    self.lineList = lineList
    return posStateList, lineList
end

local emptyMapPosList = {}
local function CheckEmpty(emptyPos, needEmptyPos)
    if not emptyMapPosList[emptyPos] then
        return
    elseif needEmptyPos[emptyPos] then
        return
    else
        needEmptyPos[emptyPos] = emptyPos
        for k, v in pairs(emptyMapPosList[emptyPos]) do
            CheckEmpty(v)
        end
    end
end

-- 某个点开启之后 这个点相邻的可开的点 （有席位点  和空席位点）
-- 是否是不能移动的格子
function MistMapModel:CalculateNearPos(posIndex)
    posIndex = tostring(posIndex)
    local mapPosList = self.mapData.mapPosList
    emptyMapPosList = self.mapData.emptyMapPosList
    local needOpenPos = {}  -- 将要开启的 有席位的点
    local needEmptyPos = {}  -- 将要开启的 空席位的点

    local posInfo = mapPosList[posIndex].posInfo
    local empty = mapPosList[posIndex].empty or {}
    for k, v in pairs(posInfo) do
        needOpenPos[v] = v
    end
    for k, v in pairs(empty) do
        CheckEmpty(v, needEmptyPos)
    end
    return needOpenPos, needEmptyPos
end

function MistMapModel:GetLineNameKey(startIndex, endIndex)
    startIndex = tonumber(startIndex)
    endIndex = tonumber(endIndex)
    local lineKey
    if startIndex > endIndex then
        lineKey = startIndex .. "_" .. endIndex
    else
        lineKey = endIndex .. "_" .. startIndex
    end
    return lineKey
end

-- 显示模式  防守模式 / 进攻模式
function MistMapModel:GetIsDefender()
    return self.isDefender
end

--
function MistMapModel:SetIsDefender(isDefender)
    self.isDefender = isDefender
end

-- 编辑地图前 clone 一份当前地图用于编辑
function MistMapModel:CloneMap()
    local guardList = self:GetGuardList()
    self.editorGuardList = clone(guardList)
end

-- 给服务器发送的编辑过信息的地图
function MistMapModel:GetPosInfo()
    local temp = {}
    for i, v in pairs(self.editorGuardList) do
        if i ~= "" then
            local t = {}
            t.oldPos = v.index
            temp[i] = t
        end
    end
    return temp
end

-- 地图信息是否改变过
function MistMapModel:IsMapChanged()
    if self.editorGuardList then
        for i, v in pairs(self.editorGuardList) do
            local index = tostring(v.index)
            local key = tostring(i)
            if index ~= key then
                return true
            end
        end
    end
    return false
end

--[[
地图编辑
地图信息基本格式
{
    "位置1key" = {
        index = "位置1id"
    },
    "位置2key" = {
        index = "位置2id"
    },
    "位置3key" = {
        index = "位置3id"
    },
}

未编辑的地图 位置1key == 位置1id  位置2key == 位置2id 位置3key == 位置3id....

1.编辑前复制一份地图信息
2.当拖拽交换两个地图地图位置的时候  交换对应index 位置id的所有数据
    例如
    第一次交换 位置1id --> 位置3id 交换后
    {
    "位置1key" = {
        index = "位置3id"
    },
    "位置2key" = {
        index = "位置2id"
    },
    "位置3key" = {
        index = "位置1id"
    },

    第二次交换 位置2id --> 位置3id 交换后
    {
    "位置1key" = {
        index = "位置2id"
    },
    "位置2key" = {
        index = "位置3id"
    },
    "位置3key" = {
        index = "位置1id"
    },
    位置key是固定不变的  变化的只有index
3.将index转换为oldPos 发送给服务器
]]--

-- 交换两个点的信息
function MistMapModel:ExchangePosInfo(posIndex1, posIndex2)
    posIndex1 = tostring(posIndex1)
    posIndex2 = tostring(posIndex2)
    local tempIndex1, tempData1, tempIndex2, tempData2
    for i, v in pairs(self.editorGuardList) do
        if v.index == posIndex1 then
            tempIndex1 = tostring(i)
            tempData1 = clone(v)
        end
        if v.index == posIndex2 then
            tempIndex2 = tostring(i)
            tempData2 = clone(v)
        end
    end
    self.editorGuardList[tempIndex1] = tempData2
    self.editorGuardList[tempIndex2] = tempData1
end

return MistMapModel

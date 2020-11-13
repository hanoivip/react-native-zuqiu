local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2
local Quaternion = UnityEngine.Quaternion
local RectTransformUtility = UnityEngine.RectTransformUtility
local Text = UnityEngine.UI.Text
local GameObjectHelper = require("ui.common.GameObjectHelper")
local GuildMistWarMap = require("data.GuildMistWarMap")
local MistMapCheckView = class(unity.base, "MistMapCheckView")

function MistMapCheckView:ctor()
--------Start_Auto_Generate--------
    self.mapPosTrans = self.___ex.mapPosTrans
    self.mapLinesTrans = self.___ex.mapLinesTrans
    self.mapItemTrans = self.___ex.mapItemTrans
    self.dragLayerTrans = self.___ex.dragLayerTrans
    self.hideBtn = self.___ex.hideBtn
    self.openBtn = self.___ex.openBtn
    self.idTxt = self.___ex.idTxt
    self.contentTrans = self.___ex.contentTrans
--------End_Auto_Generate----------
    self.mapLineObj = self.___ex.mapLineObj
    self.mapItemObj = self.___ex.mapItemObj
    self.mapIDBtnObj = self.___ex.mapIDBtnObj
    self.mapItemList=  {}
end

function MistMapCheckView:start()
    self:SetMapDataByID(1)
    self:RegBtnEvent()
    self:InitView()
end

function MistMapCheckView:RegBtnEvent()
    self.hideBtn:regOnButtonClick(function()
        self:OnBtnHideClick()
    end)
    self.openBtn:regOnButtonClick(function()
        self:OnBtnOpenClick()
    end)
end

function MistMapCheckView:OnBtnHideClick()
    local mapOpenStates = self:GetDefaultOpenItemID()
    local mapPosList = self:GetMapPosList()
    for k, v in pairs(mapPosList) do
        local state = mapOpenStates[k] or false
        self.itemList[k]:SetOpenState(state)
    end
end

function MistMapCheckView:OnBtnOpenClick()
    local mapPosList = self:GetMapPosList()
    for k, v in pairs(mapPosList) do
        self.itemList[k]:SetOpenState(true)
    end
end

function MistMapCheckView:InitView()
    self:InitMapPos()
    self.connectedMap = {}
    self.itemList = {}
    self.kingPos = self:GetMapKingPosition()

    res.ClearChildren(self.mapLinesTrans)
    res.ClearChildren(self.mapItemTrans)
    res.ClearChildren(self.contentTrans)

    local lineStateList = self:GetAllLineState()

    -- 地图上的点
    for k, v in pairs(self.mapPos) do
        local startIndex = tostring(k)
        local mapItem = Object.Instantiate(self.mapItemObj).transform
        mapItem:SetParent(self.mapItemTrans, false)
        mapItem.localPosition = self.mapPos[startIndex].localPosition
        local mapItemScript = mapItem:GetComponent("CapsUnityLuaBehav")
        mapItemScript.clickCallback = function() self:OnBtnMapItemClick(startIndex) end
        mapItemScript:InitView(startIndex, self.mapData)
        self.mapItemList[startIndex] = mapItemScript
    end

    -- 地图的连线
    for k, v in pairs(lineStateList) do
        local startIndex = v.pos1
        local posIndex = v.pos2
        local line = Object.Instantiate(self.mapLineObj).transform
        line:SetParent(self.mapLinesTrans, false)
        local pos, rotation, sizeDelta = self:CalculateLine(startIndex, posIndex)
        line.localPosition = pos
        line.localRotation = rotation
        line.sizeDelta = sizeDelta
        self:CacheLines(startIndex, posIndex, line)
        GameObjectHelper.FastSetActive(line.gameObject, v.isShow)
    end

    local sortMapList = {}
    for k, v in pairs(GuildMistWarMap) do
        table.insert(sortMapList, v)
    end
    table.sort(sortMapList, function(a, b) return a.id < b.id end)
    for i, v in ipairs(sortMapList) do
        local idBtn = Object.Instantiate(self.mapIDBtnObj).transform
        idBtn:SetParent(self.contentTrans, false)
        local idBtnScript = idBtn:GetComponent("CapsUnityLuaBehav")
        idBtn:GetComponentInChildren(Text).text = tostring(v.id)
        idBtnScript:regOnButtonClick(function()
            self:OnBtnIDClick(v.id)
        end)
    end
end

function MistMapCheckView:OnBtnIDClick(id)
    local id = tostring(id)
    self:SetMapDataByID(id)
    self:InitView()
end

function MistMapCheckView:CacheLines(startIndex, endIndex, lineObj)
    local lineNameKey = self:GetLineNameKey(startIndex, endIndex)
    self.lineList[lineNameKey] = lineObj
end

function MistMapCheckView:InitMapPos()
    self.mapPos = {}
    local count = self.mapPosTrans.childCount
    for i = 1, count do
        local index = tostring(i)
        self.mapPos[index] = self.mapPosTrans:GetChild(i - 1).transform
        GameObjectHelper.FastSetActive(self.mapPos[index].gameObject, false)
    end
end

function MistMapCheckView:CalculateLine(startIndex, endIndex)
    local pos, rotation, sizeDelta
    local startTrans = self.mapPos[startIndex]
    local endTrans = self.mapPos[endIndex]
    local startPos = startTrans.localPosition
    local endPos = endTrans.localPosition
    local normalV = (endPos - startPos).normalized
    local length = Vector3.Distance(startPos, endPos)
    local degree = Vector3.Angle(normalV, Vector3.right)
    local cross = Vector3.Cross(normalV, Vector3.right)
    if cross.z > 0 then
        degree = degree * -1
    end
    pos = startPos
    sizeDelta = Vector2(length, 8)
    rotation = Quaternion.Euler(0, 0, degree)
    return pos, rotation, sizeDelta
end

function MistMapCheckView:OnBtnMapItemClick(mapItemIndex)
    dump("Click" .. mapItemIndex)

    mapItemIndex = tostring(mapItemIndex)
end

function MistMapCheckView:SetMapData(mapData)
    self.mapData = mapData
end

function MistMapCheckView:SetMapDataByID(mapID)
    mapID = tostring(mapID)
    self.mapData = GuildMistWarMap[mapID]
    self.idTxt.text = tostring(mapID)
end

function MistMapCheckView:GetMapData()
    return self.mapData
end

-- data
-- 记录一下连接的两个点
function MistMapCheckView:ConnectIndex(startIndex, endIndex)
    if not self.connectedMap[startIndex] then
        self.connectedMap[startIndex] = {}
    end
    self.connectedMap[startIndex][endIndex] = true
end

-- 这两个点是否已经连接过了（防止重复连接）
function MistMapCheckView:IsConnected(startIndex, endIndex)
    local startConnected = self.connectedMap[startIndex] and self.connectedMap[startIndex][endIndex]
    local endConnected = self.connectedMap[endIndex] and self.connectedMap[endIndex][startIndex]
    return startConnected or endConnected
end

-- 获取地图的连接信息
function MistMapCheckView:GetMapPosList()
    return self.mapData.mapPosList
end

-- 获取默认打开的格子
function MistMapCheckView:GetDefaultOpenItemID()
    local default = self.mapData.default
    local openList = {}
    for i, v in ipairs(default) do
        openList[v] = true
    end
    return openList
end

-- 获取不能移动的格子
function MistMapCheckView:GetMapKingPosition()
    local mapKingPosition = self.mapData.mapKingPosition
    local kingArr = {}
    for i, v in pairs(mapKingPosition) do
        local pStr = tostring(v)
        kingArr[pStr] = pStr
    end
    return kingArr
end

-- 是否是不能移动的格子
function MistMapCheckView:IsKingPos(posIndex)
    posIndex = tostring(posIndex)
    local king = self.kingPos[posIndex]
    return tobool(king)
end

-- 是否是默认开启的格子
function MistMapCheckView:IsDefaultPos(posIndex)
    posIndex = tostring(posIndex)
    return self.defaultPos[posIndex]
end

-- 根据格子id获取格子是否是空格子
function MistMapCheckView:IsEmptyPos(index)
    index = tostring(index)
    local emptyMapPosList = self.mapData.emptyMapPosList
    return emptyMapPosList[index]
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
function MistMapCheckView:GetAllLineState()
    return self.lineList or {}
end

-- 所有位置点的 显示状态
--[[
20 = {
    isOpen = true,
},
]]--
function MistMapCheckView:GetAllPosState()
    return self.posStateList or {}
end

-- 预先计算地图的 点 和 连线
function MistMapCheckView:CacheMapData()
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
                lineData.isShow = tobool(isDefault or (isOpenStart and isOpenPos))
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
function MistMapCheckView:CalculateNearPos(posIndex)
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

function MistMapCheckView:GetLineNameKey(startIndex, endIndex)
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

return MistMapCheckView

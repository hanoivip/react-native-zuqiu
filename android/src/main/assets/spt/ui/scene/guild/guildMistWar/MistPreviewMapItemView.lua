local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Text = clr.UnityEngine.UI.Text
local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2
local Quaternion = UnityEngine.Quaternion
local GameObjectHelper = require("ui.common.GameObjectHelper")

local MistPreviewMapItemView = class(unity.base)

function MistPreviewMapItemView:ctor()
--------Start_Auto_Generate--------
    self.mapNameTxt = self.___ex.mapNameTxt
    self.mapLinesTrans = self.___ex.mapLinesTrans
    self.mapItemTrans = self.___ex.mapItemTrans
    self.mapPosTrans = self.___ex.mapPosTrans
--------End_Auto_Generate----------
    self.mapLinePath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildMistWar/GuildMistWarPreviewMapLine.prefab"
    self.mapItemPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildMistWar/MistChooseMapImage.prefab"
    self.itemImgPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Image/GuildMistWar/MistMapStore_Build%d.png"
    self.itemKingImgPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Image/GuildMistWar/MistMapStore_BuildKing.png"
end

function MistPreviewMapItemView:start()
    self:RegOnBtn()
end

function MistPreviewMapItemView:RegOnBtn()

end

function MistPreviewMapItemView:InitView(mapData)
    self.mapData = mapData
    local staticData = mapData.staticData
    local id = staticData.id
    local mapPosList = staticData.mapPosList
    local mapKingPosition = staticData.mapKingPosition
    self:InitMapPos(staticData)
    local lineRes = res.LoadRes(self.mapLinePath)
    local mapItemRes = res.LoadRes(self.mapItemPath)
    res.ClearChildren(self.mapLinesTrans)
    res.ClearChildren(self.mapItemTrans)
    self.connectedMap = {}
    for k, v in pairs(mapPosList) do
        local startIndex = tostring(k)
        for i, posIndex in ipairs(v.posInfo) do
            local isConnected = self:IsConnected(startIndex, posIndex)
            if not isConnected then
                local line = Object.Instantiate(lineRes).transform
                line:SetParent(self.mapLinesTrans, false)
                local pos, rotation, sizeDelta = self:CalculateLine(startIndex, posIndex)
                line.localPosition = pos
                line.localRotation = rotation
                line.sizeDelta = sizeDelta
                self:ConnectIndex(startIndex, posIndex)
            end
        end
        local mapItem = Object.Instantiate(mapItemRes).transform
        mapItem:SetParent(self.mapItemTrans, false)
        mapItem.localPosition = self.mapPos[startIndex].localPosition
        local itemImg = mapItem:GetComponent("Image")
        itemImg.overrideSprite = res.LoadRes(string.format(self.itemImgPath, v.level))
        for i, kingPos in pairs(mapKingPosition) do
            if tonumber(k) == tonumber(kingPos) then
                itemImg.overrideSprite = res.LoadRes(self.itemKingImgPath)
                break
            end
        end
        itemImg:SetNativeSize()
    end
    self.mapNameTxt.text = staticData.name or "地图ID " .. id
end

function MistPreviewMapItemView:InitMapPos(staticData)
    self.mapPos = {}
    local mapPosList = staticData.mapPosList
    local emptyMapPosList = staticData.emptyMapPosList
    local count = self.mapPosTrans.childCount
    for i = 1, count do
        local index = tostring(i)
        self.mapPos[index] = self.mapPosTrans:GetChild(i - 1).transform
        -- 暂时屏蔽空位置的显示
        --local isBuilding = tobool(mapPosList[index])
        --local isClosed = (not isBuilding) and (not emptyMapPosList[index])
        --if isBuilding then
        --    GameObjectHelper.FastSetActive(self.mapPos[index].gameObject, false)
        --else
        --    GameObjectHelper.FastSetActive(self.mapPos[index].gameObject, not isClosed)
        --end
        GameObjectHelper.FastSetActive(self.mapPos[index].gameObject, false)
    end
end

function MistPreviewMapItemView:CalculateLine(startIndex, endIndex)
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
    sizeDelta = Vector2(length, 4)
    rotation = Quaternion.Euler(0, 0, degree)
    return pos, rotation, sizeDelta
end

-- 记录一下连接的两个点
function MistPreviewMapItemView:ConnectIndex(startIndex, endIndex)
    if not self.connectedMap[startIndex] then
        self.connectedMap[startIndex] = {}
    end
    self.connectedMap[startIndex][endIndex] = true
end

-- 这两个点是否已经连接过了（防止重复连接）
function MistPreviewMapItemView:IsConnected(startIndex, endIndex)
    local startConnected = self.connectedMap[startIndex] and self.connectedMap[startIndex][endIndex]
    local endConnected = self.connectedMap[endIndex] and self.connectedMap[endIndex][startIndex]
    return startConnected or endConnected
end

return MistPreviewMapItemView

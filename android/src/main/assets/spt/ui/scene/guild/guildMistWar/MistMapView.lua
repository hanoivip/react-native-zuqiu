local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2
local Quaternion = UnityEngine.Quaternion
local RectTransformUtility = UnityEngine.RectTransformUtility
local GuildAuthority = require("data.GuildAuthority")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local GUILDWAR_STATE = require("ui.controllers.guild.guildWar.GUILDWAR_STATE")
local GuildWarFightType = require("ui.models.guild.guildMistWar.GuildWarFightType")
local GuildMistWarMapItemState = require("ui.models.guild.guildMistWar.GuildMistWarMapItemState")
local MistMapView = class(unity.base, "MistMapView")

function MistMapView:ctor()
--------Start_Auto_Generate--------
    self.mapSpt = self.___ex.mapSpt
    self.mapPosTrans = self.___ex.mapPosTrans
    self.mapLinesTrans = self.___ex.mapLinesTrans
    self.mapItemTrans = self.___ex.mapItemTrans
    self.dragLayerTrans = self.___ex.dragLayerTrans
    self.editorMapGo = self.___ex.editorMapGo
    self.editorMapBtn = self.___ex.editorMapBtn
    self.nextRoundBtn = self.___ex.nextRoundBtn
    self.preRoundBtn = self.___ex.preRoundBtn
    self.buttonsGo = self.___ex.buttonsGo
    self.myDataBtn = self.___ex.myDataBtn
    self.instructionBtn = self.___ex.instructionBtn
    self.scheduleBtn = self.___ex.scheduleBtn
    self.saveMapBtn = self.___ex.saveMapBtn
    self.changeMapBtn = self.___ex.changeMapBtn
    self.cancelBtn = self.___ex.cancelBtn
--------End_Auto_Generate----------
    self.mapLinePath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildMistWar/GuildMistWarMapLine.prefab"
    self.mapItemPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildMistWar/GuildMistWarMapItem.prefab"
    self.mapItemList = {}
end

function MistMapView:start()
    self:RegBtnEvent()
end

function MistMapView:RegBtnEvent()
    self.editorMapBtn:regOnButtonClick(function()
        self:OnBtnEditorMapClick()
    end)
    self.saveMapBtn:regOnButtonClick(function()
        self:OnBtnSaveMapClick()
    end)
    self.changeMapBtn:regOnButtonClick(function()
        self:OnBtnChangeMapClick()
    end)
    self.nextRoundBtn:regOnButtonClick(function()
        self:OnBtnNextRoundClick()
    end)
    self.preRoundBtn:regOnButtonClick(function()
        self:OnBtnPreRoundClick()
    end)
    self.cancelBtn:regOnButtonClick(function()
        self:OnBtnCancelClick()
    end)
    self.myDataBtn:regOnButtonClick(function()
        self:OnBtnMyDataClick()
    end)
    self.instructionBtn:regOnButtonClick(function()
        self:OnBtnInstructionClick()
    end)
    self.scheduleBtn:regOnButtonClick(function()
        self:OnBtnScheduleClick()
    end)
end

function MistMapView:InitView(mistMapModel)
    self.mistMapModel = mistMapModel
    self.maxRound = self.mistMapModel:GetMaxRound()
    self:InitMapPos()
    local lineRes = res.LoadRes(self.mapLinePath)
    local mapItemRes = res.LoadRes(self.mapItemPath)
    local lineStateList = self.mistMapModel:GetAllLineState()
    local isDefender = self.mistMapModel:GetIsDefender()
    res.ClearChildren(self.mapLinesTrans)
    res.ClearChildren(self.mapItemTrans)
    self.lineList = {}
    -- 地图上的点
    for k, v in pairs(self.mapPos) do
        local startIndex = tostring(k)
        local mapItem = Object.Instantiate(mapItemRes).transform
        mapItem:SetParent(self.mapItemTrans, false)
        mapItem.localPosition = self.mapPos[startIndex].localPosition
        local mapItemScript = mapItem:GetComponent("CapsUnityLuaBehav")
        mapItemScript.clickCallback = function() self:OnBtnMapItemClick(startIndex) end
        mapItemScript.pressCallback = function() self:OnBtnMapItemPress(startIndex) end
        mapItemScript.upCallback = function() self:OnBtnMapItemUp(startIndex) end
        mapItemScript.dragStartCallback = function(eventData) self:OnBtnMapItemDragStart(startIndex, eventData) end
        mapItemScript.dragCallback = function(eventData) self:OnBtnMapItemDrag(startIndex, eventData) end
        mapItemScript.dragEndCallback = function(eventData) self:OnBtnMapItemDragEnd(startIndex, eventData) end
        mapItemScript:InitView(startIndex, self.mistMapModel)
        self.mapItemList[startIndex] = mapItemScript
    end

    -- 地图的连线
    for k, v in pairs(lineStateList) do
        local startIndex = v.pos1
        local posIndex = v.pos2
        local line = Object.Instantiate(lineRes).transform
        line:SetParent(self.mapLinesTrans, false)
        local pos, rotation, sizeDelta = self:CalculateLine(startIndex, posIndex)
        line.localPosition = pos
        line.localRotation = rotation
        line.sizeDelta = sizeDelta
        self:CacheLines(startIndex, posIndex, line)
        GameObjectHelper.FastSetActive(line.gameObject, v.isShow or isDefender)
    end

    local warState = self.mistMapModel:GetWarState()
    -- 战斗
    if warState == GUILDWAR_STATE.PREPARE then
        self:MistCanEditorRefresh()
    else
        self:MistFightRefresh()
    end

    -- 箭头显示
    local round = self.mistMapModel:GetRound()
    local canEditorMinRound = self.mistMapModel:GetCanEditorMinRound()
    if not self.maxRound then
        GameObjectHelper.FastSetActive(self.nextRoundBtn.gameObject, false)
        GameObjectHelper.FastSetActive(self.preRoundBtn.gameObject, false)
        return
    end
    if canEditorMinRound > 0 then
        GameObjectHelper.FastSetActive(self.nextRoundBtn.gameObject, round < self.maxRound)
        GameObjectHelper.FastSetActive(self.preRoundBtn.gameObject, round > canEditorMinRound + 1)
    else
        GameObjectHelper.FastSetActive(self.nextRoundBtn.gameObject, round < self.maxRound)
        GameObjectHelper.FastSetActive(self.preRoundBtn.gameObject, round > 1)
    end
end

function MistMapView:InitMapPos()
    self.mapPos = {}
    local count = self.mapPosTrans.childCount
    for i = 1, count do
        local index = tostring(i)
        self.mapPos[index] = self.mapPosTrans:GetChild(i - 1).transform
        GameObjectHelper.FastSetActive(self.mapPos[index].gameObject, false)
    end
end

function MistMapView:CalculateLine(startIndex, endIndex)
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

function MistMapView:CacheLines(startIndex, endIndex, lineObj)
    local lineNameKey = self.mistMapModel:GetLineNameKey(startIndex, endIndex)
    self.lineList[lineNameKey] = lineObj
end

function MistMapView:RefreshGuardPosition(guards)
    for k, v in pairs(self.mapItemList) do
        local index = tostring(k)
        v:InitView(index, self.mistMapModel)
    end
end

function MistMapView:RefreshMap(mistMapModel)
    for k, v in pairs(self.mapItemList) do
        local index = tostring(k)
        local itemState = mistMapModel:GetMapItemStateByIndex(index)
        v:SetState(itemState)
    end
    local allLineState = mistMapModel:GetAllLineState()
    for i, v in pairs(allLineState) do
        local state = v.isShow
        GameObjectHelper.FastSetActive(self.lineList[i].gameObject, state)
    end
end

function MistMapView:OnBtnMapItemClick(mapItemIndex)
    if self.isEditorActive then
        return
    end

    local isEmptyPos = self.mistMapModel:IsEmptyPos(mapItemIndex)
    if isEmptyPos then
        return
    end

    -- 分组未完成 禁止编辑阵容和查看
    local warState = self.mistMapModel:GetWarState()
    if warState == GUILDWAR_STATE.NOTSIGN or
       warState == GUILDWAR_STATE.SIGNED or
       warState == GUILDWAR_STATE.GROUPING or
       warState == GUILDWAR_STATE.PREFINISH then
        DialogManager.ShowToastByLang("mist_schedule_close")
        return
    end

    local itemState = self.mistMapModel:GetMapItemStateByIndex(mapItemIndex)
    local isDefender = self.mistMapModel:GetIsDefender()
    local isMist = GuildMistWarMapItemState.Mist == itemState
    if isMist and not isDefender then
        return
    end

    if not self.dragging then
        local fightType = self.mistMapModel:GetGuildWarFightType()
        if fightType == GuildWarFightType.Register then
            local guardData = self.mistMapModel:GetGuardDataByIndex(mapItemIndex)
            local ctrlPath = "ui.controllers.guild.guildMistWar.GuildMistWarGuardDetailCtrl"
            res.PushDialog(ctrlPath, guardData, self.mistMapModel)
        else
            local ctrlPath = "ui.controllers.guild.guildMistWar.MistOurPartSeatsDetailCtrl"
            res.PushDialog(ctrlPath, mapItemIndex, self.mistMapModel)
        end
    end
    self.dragging = false
end

function MistMapView:ResetButtons()
    GameObjectHelper.FastSetActive(self.editorMapGo.gameObject, true)
    GameObjectHelper.FastSetActive(self.saveMapBtn.gameObject, false)
    GameObjectHelper.FastSetActive(self.changeMapBtn.gameObject, false)
    GameObjectHelper.FastSetActive(self.cancelBtn.gameObject, false)
end

-----------------------
--- 地图拖拽编辑 start
-----------------------
function MistMapView:OnBtnMapItemPress(mapItemIndex)
    if not self.isEditorActive then
        return
    end
    local isKingPos = self.mistMapModel:IsKingPos(mapItemIndex)
    local isEmptyPos = self.mistMapModel:IsEmptyPos(mapItemIndex)
    if isKingPos or isEmptyPos then
        return
    end
    mapItemIndex = tostring(mapItemIndex)
    local spt = self.mapItemList[mapItemIndex]
    self:InstantiateDragTrans(mapItemIndex)
    spt:SetPress(true)
end

function MistMapView:OnBtnMapItemUp(mapItemIndex)
    if not self.isEditorActive then
        return
    end
    local isKingPos = self.mistMapModel:IsKingPos(mapItemIndex)
    local isEmptyPos = self.mistMapModel:IsEmptyPos(mapItemIndex)
    if isKingPos or isEmptyPos then
        return
    end
    mapItemIndex = tostring(mapItemIndex)
    local spt = self.mapItemList[mapItemIndex]
    spt:SetPress(false)
    self:ClearDragTrans()
    self:ClearChoose()
end

function MistMapView:OnBtnMapItemDragStart(mapItemIndex, eventData)
    self.dragging = true
    if not self.isEditorActive then
        return
    end
    local isKingPos = self.mistMapModel:IsKingPos(mapItemIndex)
    local isEmptyPos = self.mistMapModel:IsEmptyPos(mapItemIndex)
    if isKingPos or isEmptyPos then
        return
    end
    mapItemIndex = tostring(mapItemIndex)
    local spt = self.mapItemList[mapItemIndex]
    self.dragItemPos = spt.transform.localPosition
    self:InstantiateDragTrans(mapItemIndex)
    spt:SetPress(true)
end

function MistMapView:OnBtnMapItemDrag(mapItemIndex, eventData)
    if not self.isEditorActive then
        return
    end
    local isKingPos = self.mistMapModel:IsKingPos(mapItemIndex)
    local isEmptyPos = self.mistMapModel:IsEmptyPos(mapItemIndex)
    if isKingPos or isEmptyPos then
        return
    end
    mapItemIndex = tostring(mapItemIndex)
    local spt = self.mapItemList[mapItemIndex]
    local success, pos = RectTransformUtility.ScreenPointToLocalPointInRectangle(self.dragLayerTrans, eventData.position, eventData.pressEventCamera, Vector2.zero);
    local p = Vector3(pos.x, pos.y, 0)
    self.dragTrans.transform.localPosition = p

    for i, v in pairs(self.mapItemList) do
        v:SetChoose(false)
        isKingPos = self.mistMapModel:IsKingPos(i)
        isEmptyPos = self.mistMapModel:IsEmptyPos(i)
        if (not isKingPos) and (not isEmptyPos) then
            local inArea = RectTransformUtility.RectangleContainsScreenPoint(v.transform, eventData.position, eventData.pressEventCamera)
            if inArea then
                v:SetChoose(true)
            end
        end
    end
end

function MistMapView:OnBtnMapItemDragEnd(mapItemIndex, eventData)
    if not self.isEditorActive then
        return
    end
    local isKingPos = self.mistMapModel:IsKingPos(mapItemIndex)
    local isEmptyPos = self.mistMapModel:IsEmptyPos(mapItemIndex)
    if isKingPos or isEmptyPos then
        return
    end
    mapItemIndex = tostring(mapItemIndex)
    local spt = self.mapItemList[mapItemIndex]
    for i, v in pairs(self.mapItemList) do
        isKingPos = self.mistMapModel:IsKingPos(i)
        isEmptyPos = self.mistMapModel:IsEmptyPos(i)
        local isClosed = self.mistMapModel:IsClosedPos(i)
        local inArea = RectTransformUtility.RectangleContainsScreenPoint(v.transform, eventData.position, eventData.pressEventCamera)
        if inArea and (not isKingPos) and (not isEmptyPos) and (not isClosed) then
            spt.transform.localPosition = v.transform.localPosition
            v.transform.localPosition = self.dragItemPos
            dump(mapItemIndex .. "  pos changed  " .. i)
            self.mistMapModel:ExchangePosInfo(mapItemIndex, i)
            self:ClearDragTrans()
            return
        end
    end
    spt.transform.localPosition = self.dragItemPos
    self:ClearDragTrans()
    self:ClearChoose()
end

function MistMapView:InstantiateDragTrans(mapItemIndex)
    if not self.dragTrans then
        mapItemIndex = tostring(mapItemIndex)
        local spt = self.mapItemList[mapItemIndex]
        self.dragTrans = Object.Instantiate(spt.gameObject).transform
        self.dragTrans:SetParent(self.dragLayerTrans, false)
        local mapPosList = self.mistMapModel:GetMapPosList()
        local mapItemScript = self.dragTrans:GetComponent("CapsUnityLuaBehav")
        mapItemScript:InitView(mapItemIndex, self.mistMapModel)
        mapItemScript:SetName(mapItemIndex)
    end
end

function MistMapView:ClearDragTrans()
    res.ClearChildren(self.dragLayerTrans)
    self.dragTrans = nil
end

function MistMapView:ClearChoose()
    for i, v in pairs(self.mapItemList) do
        v:SetChoose(false)
    end
end

-----------------------
--- 地图拖拽编辑 end
-----------------------

function MistMapView:OnBtnEditorMapClick()
    local authority = self.mistMapModel:GetAuthority()
    authority = tostring(authority)
    local authorityState = GuildAuthority[authority].selectMistMap == 1
    if not authorityState then
        DialogManager.ShowToastByLang("mist_authority_none")
        return
    end

    EventSystem.SendEvent("GuildWarMist_EditorMap", true)
    self.mistMapModel:CloneMap()
    GameObjectHelper.FastSetActive(self.saveMapBtn.gameObject, true)
    GameObjectHelper.FastSetActive(self.changeMapBtn.gameObject, true)
    GameObjectHelper.FastSetActive(self.cancelBtn.gameObject, true)
    GameObjectHelper.FastSetActive(self.editorMapGo, false)
    self.isEditorActive = true
end

function MistMapView:OnBtnSaveMapClick()
    self.isEditorActive = false

    -- 地图没有改变
    local isMapChanged = self.mistMapModel:IsMapChanged()
    if not isMapChanged then
        GameObjectHelper.FastSetActive(self.saveMapBtn.gameObject, false)
        GameObjectHelper.FastSetActive(self.changeMapBtn.gameObject, false)
        GameObjectHelper.FastSetActive(self.cancelBtn.gameObject, false)
        GameObjectHelper.FastSetActive(self.editorMapGo, true)
        DialogManager.ShowToastByLang("map_not_changed")
        return
    end
    self:SaveMap()
end

function MistMapView:SaveMap()
    self:coroutine(function()
        local posInfo = self.mistMapModel:GetPosInfo()
        local round = self.mistMapModel:GetRound()
        local response = req.guildWarSaveGuardsInfoMist(round, posInfo)
        if api.success(response) then
            local data = response.val
            self.mistMapModel:InitEditorWithProtocol(data)
            self:InitView(self.mistMapModel)
            GameObjectHelper.FastSetActive(self.saveMapBtn.gameObject, false)
            GameObjectHelper.FastSetActive(self.changeMapBtn.gameObject, false)
            GameObjectHelper.FastSetActive(self.cancelBtn.gameObject, false)
            GameObjectHelper.FastSetActive(self.editorMapGo, true)
            self.mistMapModel:CloneMap()
        end
    end)
end

function MistMapView:MistFightRefresh()
    GameObjectHelper.FastSetActive(self.saveMapBtn.gameObject, false)
    GameObjectHelper.FastSetActive(self.changeMapBtn.gameObject, false)
    GameObjectHelper.FastSetActive(self.cancelBtn.gameObject, false)
    GameObjectHelper.FastSetActive(self.editorMapGo, false)
    self.isEditorActive = false
end

function MistMapView:MistCanEditorRefresh()
    GameObjectHelper.FastSetActive(self.saveMapBtn.gameObject, false)
    GameObjectHelper.FastSetActive(self.changeMapBtn.gameObject, false)
    GameObjectHelper.FastSetActive(self.cancelBtn.gameObject, false)
    GameObjectHelper.FastSetActive(self.editorMapGo, true)
    self.isEditorActive = false
end

function MistMapView:OnBtnChangeMapClick()
    local isMapChanged = self.mistMapModel:IsMapChanged()
    if isMapChanged then
        DialogManager.ShowToastByLang("please_save_map")
    else
        local round = self.mistMapModel:GetRound()
        res.PushDialog("ui.controllers.guild.guildMistWar.GuildMistChooseMapCtrl", round)
    end
end

function MistMapView:OnBtnCancelClick()
    local isMapChanged = self.mistMapModel:IsMapChanged()
    if isMapChanged then
        DialogManager.ShowToastByLang("please_save_map")
    else
        self:MistCanEditorRefresh()
    end
end

-- 下一轮的阵容
function MistMapView:OnBtnNextRoundClick()
    local round = self.mistMapModel:GetRound()
    local nextRound = round + 1
    local isSHow = nextRound >= self.maxRound
    GameObjectHelper.FastSetActive(self.nextRoundBtn.gameObject, not isSHow)
    GameObjectHelper.FastSetActive(self.preRoundBtn.gameObject, true)
    self:ShowRound(nextRound)
    for i, v in pairs(self.mapItemList) do
        v:PlayMapItemOpenAnim()
    end
end

-- 上一轮的阵容
function MistMapView:OnBtnPreRoundClick()
    local round = self.mistMapModel:GetRound()
    local preRound = round - 1
    local canEditorMinRound = self.mistMapModel:GetCanEditorMinRound()
    if canEditorMinRound >= preRound then
        DialogManager.ShowToastByLang("mist_vote_old_limit")
        return
    end
    GameObjectHelper.FastSetActive(self.preRoundBtn.gameObject, preRound > 1)
    GameObjectHelper.FastSetActive(self.nextRoundBtn.gameObject, true)
    self:ShowRound(preRound)
    for i, v in pairs(self.mapItemList) do
        v:PlayMapItemOpenAnim()
    end
end

-- 显示指定轮次的防守阵容
function MistMapView:ShowRound(round)
    self:coroutine(function ()
        local response = req.guildWarGuardsInfoMistByRound(round)
        if api.success(response) then
            local data = response.val
            self:RefreshDefenderMap(data)
        end
    end)
end

-- 历史赛季
function MistMapView:OnBtnMyDataClick()
    local warState = self.mistMapModel:GetWarState()
    if warState == GUILDWAR_STATE.NOTSIGN then
        DialogManager.ShowToastByLang("mist_history_close")
    else
        res.PushDialog("ui.controllers.guild.guildMistWar.GuildMistWarMyDataCtrl")
    end
end

-- 说明
function MistMapView:OnBtnInstructionClick()
    local state = self.mistMapModel:GetWarState()
    local round = self.mistMapModel:GetRound()
    res.PushDialog("ui.controllers.guild.guildMistWar.GuildMistWarDescCtrl", state, round)
end

-- 赛程
function MistMapView:OnBtnScheduleClick()
    EventSystem.SendEvent("MistWar_ShowSchedule")
end

function MistMapView:RefreshDefenderMap(data, canEditorMinRound)
    self.mistMapModel:InitEditorWithProtocol(data)
    self.mistMapModel:SetCanEditorMinRound(canEditorMinRound)
    self:InitView(self.mistMapModel)
    EventSystem.SendEvent("GuildWarMist_EditorMap", true)
end

function MistMapView:OnEnterScene()
    EventSystem.AddEvent("GuildMistWar_RefreshGuardPosition", self, self.RefreshGuardPosition)
    EventSystem.AddEvent("MistMapModel_UpdateGuardData", self, self.RefreshMap)
    EventSystem.AddEvent("GuildWarMist_RefreshDefenderMap", self, self.RefreshDefenderMap)
    EventSystem.AddEvent("GuildWarMist_SaveMap", self, self.SaveMap)
end

function MistMapView:OnExitScene()
    EventSystem.RemoveEvent("GuildMistWar_RefreshGuardPosition", self, self.RefreshGuardPosition)
    EventSystem.RemoveEvent("MistMapModel_UpdateGuardData", self, self.RefreshMap)
    EventSystem.RemoveEvent("GuildWarMist_RefreshDefenderMap", self, self.RefreshDefenderMap)
    EventSystem.RemoveEvent("GuildWarMist_SaveMap", self, self.SaveMap)
end

return MistMapView

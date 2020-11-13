local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local EventSystems = UnityEngine.EventSystems
local Object = UnityEngine.Object
local Tweening = clr.DG.Tweening
local Tweener = Tweening.Tweener
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease
local DialogManager = require("ui.control.manager.DialogManager")
local GreenswardBuilderView = class(unity.base)

function GreenswardBuilderView:ctor()
    self.content = self.___ex.content
    self.renderCameraTrans = self.___ex.renderCameraTrans
    self.renderCamera = self.___ex.renderCamera
    self.mobileTouch = self.___ex.mobileTouch
    self.cameraTouchEvent = self.___ex.cameraTouchEvent
    self.gridLayout = self.___ex.gridLayout
    self.hasCameraMove = false
    self.constructionMap = {}
end

function GreenswardBuilderView:start()

end

function GreenswardBuilderView:GetPlayerRes()
    if not self.constructionRes then
        self.constructionRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Main/ConstructionFrame.prefab")
    end
    return self.constructionRes
end

function GreenswardBuilderView:InitView(greenswardBuildModel, greenswardResourceCache)
    self.greenswardBuildModel = greenswardBuildModel
    self.greenswardResourceCache = greenswardResourceCache
    local col = greenswardBuildModel:GetGridCol()
    local row = greenswardBuildModel:GetGridRow()

    self:coroutine(function ()
        self:InitOriginGrid(greenswardBuildModel)
        self:InitCameraTouch()

        local objRes = self:GetPlayerRes()
        local count = 0
        for i = 1, row do
            for j = 1, col do
                local rowIndex, colIndex = i - 1, j - 1
                local key = tostring(rowIndex) .. "_" .. tostring(colIndex)
                if not self.constructionMap[key] then
                    local obj = Object.Instantiate(objRes)
                    local script = res.GetLuaScript(obj)
                    script.btnClick = function(row, col) self:OnBtnConstruction(row, col) end
                    obj.transform:SetParent(self.content, false)
                    self.constructionMap[key] = script
                end
                local eventModelsMap = greenswardBuildModel:GetEventModels()
                self.constructionMap[key]:InitView(rowIndex, colIndex, eventModelsMap[key], self.greenswardResourceCache)
                count = count + 1
                if count % 5 == 0 then
                    unity.waitForNextEndOfFrame()
                end
            end
        end
    end)
end

function GreenswardBuilderView:InitOriginGrid(greenswardBuildModel)
    local row, col = greenswardBuildModel:GetJumpGirdNumber()
    self:OnMoveConstruction(row, col)
end

local GenerateAngle = 360
local Rate = 3.14
local Radian = 180
function GreenswardBuilderView:OnMoveConstruction(row, col)
    local pos = self:GetConstructionDestinationPos(row, col)
    self.renderCameraTrans.position = Vector3(pos.x, pos.y, self.renderCameraTrans.position.z)
end

function GreenswardBuilderView:GetConstructionDestinationPos(row, col)
    local cellX = self.gridLayout.cellSize.x
    local cellY = self.gridLayout.cellSize.y

    local totalCol = self.greenswardBuildModel:GetGridCol()
    local totalRow = self.greenswardBuildModel:GetGridRow()
    local ulPosx = - math.floor((totalCol - 1) / 2) * cellX
    local ucPosY = math.floor((totalRow - 1) / 2) * cellY
    local bcPosY = ucPosY - (totalRow - 1) * cellY

    local posX = ulPosx + (tonumber(col) * cellX)
    local posY = ucPosY - (tonumber(row) * cellY)
    local rotateX = self.renderCameraTrans.eulerAngles.x - GenerateAngle
    local offset =((math.abs(ucPosY) + math.abs(bcPosY)) / 2) * math.sin(rotateX * Rate / Radian)

    local cameraY = offset + posY
    local mobilePos = self.mobileTouch:GetClampToBoundaries(Vector3(posX, cameraY, 0))
    return mobilePos
end

local ShakeTime = 1
local MoveTime = 2
local Strength = 3
local Vibrato = 10
local Randomness = 90
function GreenswardBuilderView:OnJumpConstruction(row, col, map)
    local currentEventSystem = EventSystems.EventSystem.current
    currentEventSystem.enabled = false
    self.cameraTouchEvent.enabled = false
    self.greenswardBuildModel:SetAutoMoveStatue(true)
    local pos = self:GetConstructionDestinationPos(row, col)
    local vec3 = Vector3(pos.x, pos.y, self.renderCameraTrans.position.z)
    local moveInTweener = ShortcutExtensions.DOMove(self.renderCameraTrans, vec3, MoveTime, false)
    TweenSettingsExtensions.SetDelay(moveInTweener, ShakeTime)
    TweenSettingsExtensions.SetEase(moveInTweener, Ease.OutCubic)
    TweenSettingsExtensions.OnComplete(moveInTweener, function ()
        self.greenswardBuildModel:RefreshEventData(map)
        currentEventSystem.enabled = true
        self.cameraTouchEvent.enabled = true
        self.greenswardBuildModel:SetAutoMoveStatue(false)
    end)

    local cameraTweener = ShortcutExtensions.DOShakePosition(self.renderCamera, ShakeTime, Strength, Vibrato, Randomness, true)
    TweenSettingsExtensions.OnComplete(cameraTweener, function ()

    end)
end

-- 新手引导移动
function GreenswardBuilderView:OnMoveGrid(row, col, time)
    local moveTime = time or MoveTime
    local currentEventSystem = EventSystems.EventSystem.current
    currentEventSystem.enabled = false
    self.cameraTouchEvent.enabled = false
    self.greenswardBuildModel:SetAutoMoveStatue(true)
    local pos = self:GetConstructionDestinationPos(row, col)
    local vec3 = Vector3(pos.x, pos.y, self.renderCameraTrans.position.z)
    local moveInTweener = ShortcutExtensions.DOMove(self.renderCameraTrans, vec3, moveTime, false)
    TweenSettingsExtensions.SetEase(moveInTweener, Ease.OutCubic)
    TweenSettingsExtensions.OnComplete(moveInTweener, function ()
        currentEventSystem.enabled = true
        self.cameraTouchEvent.enabled = true
        self.greenswardBuildModel:SetAutoMoveStatue(false)
    end)
end

function GreenswardBuilderView:OnBtnConstruction(row, col)
    local hasMorale = self.greenswardBuildModel:HasMoraleCostByOpenEvent()
    if hasMorale then
        self:coroutine(function()
            local respone = req.greenswardAdventureOpen(row, col)
            if api.success(respone) then
                local data = respone.val
                local map = data.ret and data.ret.map or {}
                if data.base then
                    self.greenswardBuildModel:RefreshBaseInfo(data.base)
                end
                self.greenswardBuildModel:OpenEventData(map, row, col)
            end
        end)
    else
        local titleText = lang.trans("tips")
        local contentText = lang.trans("need_morale_enough2")
        local callback = function() res.PushDialog("ui.controllers.greensward.GreenswardMoraleDialogCtrl", self.greenswardBuildModel) end
        DialogManager.ShowMessageBox(titleText, contentText, callback)
    end
end

local ContactTime = 0.5
function GreenswardBuilderView:EventDataOpen(keys, row, col)
    self:coroutine(function()
        local eventModelsMap = self.greenswardBuildModel:GetEventModels()
        local openKey = row .. "_" .. col
        local eventModel = eventModelsMap[openKey]
        if eventModel then
            self.constructionMap[openKey]:CloudFadeOutAnimationPlay()
        end
        coroutine.yield(UnityEngine.WaitForSeconds(ContactTime))
        if eventModel then
            eventModel:CreateFadeInExtensions(self.constructionMap[openKey].eventCanvasGroup)
        end
        for k, key in pairs(keys) do
            self.constructionMap[key]:UpdateDetails()
        end
    end)
end

function GreenswardBuilderView:EventDataRefresh(keys)
    for k, key in pairs(keys) do
        self.constructionMap[key]:UpdateDetails()
    end
end

function GreenswardBuilderView:EventModelRefresh(keys)
    local eventModelsMap = self.greenswardBuildModel:GetEventModels()
    for k, key in pairs(keys) do
        local group = string.split(key, '_')
        local rowIndex = tonumber(group[1])
        local colIndex = tonumber(group[2])
        self.constructionMap[key]:InitView(rowIndex, colIndex, eventModelsMap[key], self.greenswardResourceCache)
    end
end

function GreenswardBuilderView:OpponentEventTrigger(eventModel)
    local dialogCtrl = eventModel:GetDialogCtrl()
    if dialogCtrl ~= "" then
        res.PushDialog(dialogCtrl, eventModel, self.greenswardResourceCache)
    end
end

function GreenswardBuilderView:GeneralEventTrigger(eventModel)
    local dialogCtrl = eventModel:GetDialogCtrl()
    if dialogCtrl ~= "" then
        res.PushDialog(dialogCtrl, eventModel, self.greenswardResourceCache)
    end
end

function GreenswardBuilderView:DialogTrigger()
    if self.cameraTouchEvent and self.greenswardBuildModel then
        self.greenswardBuildModel:SetCameraMoveStatue(false)
        local autoMove = self.greenswardBuildModel:GetAutoMoveStatue()
        if not autoMove then
            self.cameraTouchEvent.enabled = false
        end
    end
end

function GreenswardBuilderView:InitCameraTouch()
    local moveStatue = self.greenswardBuildModel:GetCameraMoveStatue()
    local autoMove = self.greenswardBuildModel:GetAutoMoveStatue()
    self.cameraTouchEvent.enabled = moveStatue and not autoMove
end

function GreenswardBuilderView:DialogDestroyTrigger()
    if self.cameraTouchEvent and self.greenswardBuildModel then
        self.greenswardBuildModel:SetCameraMoveStatue(true)
        local autoMove = self.greenswardBuildModel:GetAutoMoveStatue()
        if not autoMove then
            self.cameraTouchEvent.enabled = true
        end
    end
end

function GreenswardBuilderView:SubwayJump(row, col, map)
    self:OnJumpConstruction(row, col, map)
end

function GreenswardBuilderView:TreasureActivationEventTrigger(eventModel)
    self:coroutine(function()
		local row, col = eventModel:GetRow(), eventModel:GetCol()
        local respone = req.greenswardAdventureTreasureActivation(row, col)
        if api.success(respone) then
            local data = respone.val
            self.greenswardBuildModel:RefreshSingleEventData(row, col, data)
        end
    end)
end

function GreenswardBuilderView:TreasureOpenEventTrigger()

end

function GreenswardBuilderView:OnEnterScene()
    EventSystem.AddEvent("GreenswardEventDataOpen", self, self.EventDataOpen)
    EventSystem.AddEvent("GreenswardEventDataRefresh", self, self.EventDataRefresh)
    EventSystem.AddEvent("GreenswardEventModelRefresh", self, self.EventModelRefresh)
    EventSystem.AddEvent("GreenswardOpponentEventTrigger", self, self.OpponentEventTrigger)
    EventSystem.AddEvent("GreenswardGeneralEventTrigger", self, self.GeneralEventTrigger)
	EventSystem.AddEvent("GreenswardTreasureActivationEventTrigger", self, self.TreasureActivationEventTrigger)
	EventSystem.AddEvent("GreenswardTreasureOpenEventTrigger", self, self.TreasureOpenEventTrigger)
    EventSystem.AddEvent("GreenswardSubwayJump", self, self.SubwayJump)
    EventSystem.AddEvent("GreenswardMoveConstruction", self,self.OnMoveConstruction)
    EventSystem.AddEvent("DialogInsertCurrentScene", self, self.DialogTrigger)
    EventSystem.AddEvent("AllDialogBeDestroy", self, self.DialogDestroyTrigger)
    -- 照明弹模式
    EventSystem.AddEvent("GreenswardFlashBang_SelectStep", self, self.OnEnterFlashBang)
    EventSystem.AddEvent("GreenswardFlashBang_QuitFlashBang", self, self.OnQuitFlashBang)
    -- 道具更新
    EventSystem.AddEvent("Greensward_Item_Change", self, self.OnGreenswardItemUpdate)
    EventSystem.AddEvent("Greensward_UseItemEventRefresh", self, self.OnGreenswardItemUpdate)
    -- 格子动效移动（新手引导）
    EventSystem.AddEvent("Greensward_GridMove", self, self.OnMoveGrid)
end

function GreenswardBuilderView:OnExitScene()
    EventSystem.RemoveEvent("GreenswardEventDataOpen", self, self.EventDataOpen)
    EventSystem.RemoveEvent("GreenswardEventDataRefresh", self, self.EventDataRefresh)
    EventSystem.RemoveEvent("GreenswardEventModelRefresh", self, self.EventModelRefresh)
    EventSystem.RemoveEvent("GreenswardOpponentEventTrigger", self, self.OpponentEventTrigger)
    EventSystem.RemoveEvent("GreenswardGeneralEventTrigger", self, self.GeneralEventTrigger)
	EventSystem.RemoveEvent("GreenswardTreasureActivationEventTrigger", self, self.TreasureActivationEventTrigger)
	EventSystem.RemoveEvent("GreenswardTreasureOpenEventTrigger", self, self.TreasureOpenEventTrigger)
    EventSystem.RemoveEvent("GreenswardSubwayJump", self, self.SubwayJump)
    EventSystem.RemoveEvent("GreenswardMoveConstruction", self,self.OnMoveConstruction)
    EventSystem.RemoveEvent("DialogInsertCurrentScene", self, self.DialogTrigger)
    EventSystem.RemoveEvent("AllDialogBeDestroy", self, self.DialogDestroyTrigger)
    -- 照明弹模式
    EventSystem.RemoveEvent("GreenswardFlashBang_SelectStep", self, self.OnEnterFlashBang)
    EventSystem.RemoveEvent("GreenswardFlashBang_QuitFlashBang", self, self.OnQuitFlashBang)
    -- 道具更新
    EventSystem.RemoveEvent("Greensward_Item_Change", self, self.OnGreenswardItemUpdate)
    EventSystem.RemoveEvent("Greensward_UseItemEventRefresh", self, self.OnGreenswardItemUpdate)
    -- 格子动效移动（新手引导）
    EventSystem.RemoveEvent("Greensward_GridMove", self, self.OnMoveGrid)
end

-- 进入照明弹模式
function GreenswardBuilderView:OnEnterFlashBang()
    self:DisplaySuprmeMask(true)
end

-- 退出照明弹模式
function GreenswardBuilderView:OnQuitFlashBang()
    self:DisplaySuprmeMask(false)
end

-- 设置所有格子显示最高层级点击遮罩
function GreenswardBuilderView:DisplaySuprmeMask(isShow)
    for k, v in pairs(self.constructionMap) do
        v:DisplaySuprmeMask(isShow)
    end
end

--道具更新响应事件，更新与该道具相关的事件
function GreenswardBuilderView:OnGreenswardItemUpdate(id, num)
    local map = {}
    local eventModels = self.greenswardBuildModel:GetEventModels()
    for k, evetModel in pairs(eventModels or {}) do
        if evetModel:IsItemCorrelation(id) then
            map[evetModel:GetKey()] = evetModel:GetData()
        end
    end
    self.greenswardBuildModel:RefreshEventData(map)
end

return GreenswardBuilderView

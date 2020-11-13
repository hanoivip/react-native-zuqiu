local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local UI = UnityEngine.UI
local Image = UI.Image
local RectTransformUtility = UnityEngine.RectTransformUtility
local Num2LetterPos = require("data.Num2LetterPos")
local Letter2NumPos = require("data.Letter2NumPos")
local Formation = require("data.Formation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local FormationConstants = require("ui.scene.formation.FormationConstants")

local FormationKeyPlayerBoardView = class(unity.base)

function FormationKeyPlayerBoardView:ctor()
    self.keyPlayerContent = self.___ex.keyPlayerContent
    self.keyPlayerButtons = self.___ex.keyPlayerButtons
    self.keyPlayerHighLightBars = self.___ex.keyPlayerHighLightBars
    self.rowGroup = self.___ex.rowGroup
    self.buttonGroup = self.___ex.buttonGroup
    self.canvasGroup = self.___ex.canvasGroup
    self.playersNumber = 11
    self.realPlayersNumber = 0
    self.boardHeight = self.transform.rect.height
    self.boardWidth = self.transform.rect.width
    self.barHeight = self.boardHeight / self.playersNumber
    self.buttonMoveMinY = 0
    self.buttonMoveMaxY = self.boardHeight - self.barHeight / 2
    -- 关键球员type和pcid的表
    self.keyPlayers = {}
    -- 首发球员index和pcid的表
    self.initPlayers = {}
    -- 首发球员pcid和Bar的脚本的表
    self.initPlayerBars = {}
end

function FormationKeyPlayerBoardView:start()
end

function FormationKeyPlayerBoardView:InitView(playerTeamsModel, formationCacheDataModel)
    self.playerTeamsModel = playerTeamsModel
    self.formationCacheDataModel = formationCacheDataModel
    self:InitPlayersListArea()
    self:InitKeyPlayers()
end

-- 初始化首发球员列表
function FormationKeyPlayerBoardView:InitPlayersListArea()
    local barObj = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Formation/FormationKeyPlayerBar.prefab")
    local initPlayersData = self:RebuildInitPlayersData(self.formationCacheDataModel:GetInitPlayersCacheDataWithKeyPlayers())
    local index = 0
    for i, playerData in ipairs(initPlayersData) do
        index = index + 1
        local go = Object.Instantiate(barObj)
        go.transform:SetParent(self.keyPlayerContent, false)
        local goScript = go:GetComponent(clr.CapsUnityLuaBehav)
        if playerData.pcid ~= 0 then
            local cardModel = self.formationCacheDataModel:GetCardModelWithPcid(playerData.pcid)
            local pos = Num2LetterPos[tostring(playerData.pos)] or Num2LetterPos[tonumber(playerData.pos)]
            local displayPos = Letter2NumPos[pos].displayPos
            goScript:InitView(index, displayPos, cardModel)
            self.initPlayers[index] = playerData.pcid
            self.initPlayerBars[playerData.pcid] = goScript
        else
            goScript:InitView(index)
        end
    end
end

-- 从原始首发数据中筛选出真实的首发球员，并且按索引排列
function FormationKeyPlayerBoardView:RebuildInitPlayersData(initPlayersData)
    local realPlayers = {}
    local fakePlayers = {}
    for pos, pcid in pairs(initPlayersData) do
        local player = {}
        player.pos = pos
        player.pcid = pcid
        if pcid ~= 0 then
            table.insert(realPlayers, player)
            self.realPlayersNumber = self.realPlayersNumber + 1
        else
            table.insert(fakePlayers, player)
        end
    end
    table.sort(realPlayers, function (a, b)
        return tonumber(a.pos) < tonumber(b.pos)
    end)
    for i, v in ipairs(fakePlayers) do
        table.insert(realPlayers, v)
    end
    self.buttonMoveMinY = self.barHeight * (self.playersNumber - self.realPlayersNumber + 0.5)
    return realPlayers
end

function FormationKeyPlayerBoardView:HasKeyPlayers()
    local nowTeamData = self.playerTeamsModel:GetNowTeamData()
    return not (nowTeamData.captain == 0 and nowTeamData.freeKickShoot == 0 and nowTeamData.freeKickPass == 0 and nowTeamData.spotKick == 0 and nowTeamData.corner == 0)
end

-- 初始化关键球员数据以及关键球员按钮位置
function FormationKeyPlayerBoardView:InitKeyPlayers()
    if self.realPlayersNumber ~= 0 then
        local keyPlayersData = self.formationCacheDataModel:GetKeyPlayersCacheData()
        self.keyPlayers[FormationConstants.KeyPlayerType.CAPTAIN] = keyPlayersData.captain
        self.keyPlayers[FormationConstants.KeyPlayerType.FREEKICKSHOOT] = keyPlayersData.freeKickShoot
        self.keyPlayers[FormationConstants.KeyPlayerType.FREEKICKPASS] = keyPlayersData.freeKickPass
        self.keyPlayers[FormationConstants.KeyPlayerType.SPOTKICK] = keyPlayersData.spotKick
        self.keyPlayers[FormationConstants.KeyPlayerType.CORNER] = keyPlayersData.corner
        for index, pcid in ipairs(self.initPlayers) do
            if pcid == self.keyPlayers[FormationConstants.KeyPlayerType.CAPTAIN] then
                self:SetKeyPlayerButtonPos(FormationConstants.KeyPlayerType.CAPTAIN, index)
            end
            if pcid == self.keyPlayers[FormationConstants.KeyPlayerType.FREEKICKSHOOT] then
                self:SetKeyPlayerButtonPos(FormationConstants.KeyPlayerType.FREEKICKSHOOT, index)
            end
            if pcid == self.keyPlayers[FormationConstants.KeyPlayerType.FREEKICKPASS] then
                self:SetKeyPlayerButtonPos(FormationConstants.KeyPlayerType.FREEKICKPASS, index)
            end
            if pcid == self.keyPlayers[FormationConstants.KeyPlayerType.SPOTKICK] then
                self:SetKeyPlayerButtonPos(FormationConstants.KeyPlayerType.SPOTKICK, index)
            end
            if pcid == self.keyPlayers[FormationConstants.KeyPlayerType.CORNER] then
                self:SetKeyPlayerButtonPos(FormationConstants.KeyPlayerType.CORNER, index)
            end
        end
        self:SetKeyPlayerButtonState(FormationConstants.KeyPlayerType.CAPTAIN, true)
        self:SetKeyPlayerButtonState(FormationConstants.KeyPlayerType.FREEKICKSHOOT, true)
        self:SetKeyPlayerButtonState(FormationConstants.KeyPlayerType.FREEKICKPASS, true)
        self:SetKeyPlayerButtonState(FormationConstants.KeyPlayerType.SPOTKICK, true)
        self:SetKeyPlayerButtonState(FormationConstants.KeyPlayerType.CORNER, true)
    else
        self:SetKeyPlayerButtonState(FormationConstants.KeyPlayerType.CAPTAIN, false)
        self:SetKeyPlayerButtonState(FormationConstants.KeyPlayerType.FREEKICKSHOOT, false)
        self:SetKeyPlayerButtonState(FormationConstants.KeyPlayerType.FREEKICKPASS, false)
        self:SetKeyPlayerButtonState(FormationConstants.KeyPlayerType.SPOTKICK, false)
        self:SetKeyPlayerButtonState(FormationConstants.KeyPlayerType.CORNER, false)
        self.canvasGroup.blocksRaycasts = false
    end
end

function FormationKeyPlayerBoardView:SetKeyPlayerButtonState(keyPlayerType, isEnable)
    if isEnable then
        self.keyPlayerButtons[keyPlayerType]:GetComponent(Image).overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Formation/Images/KeyPlayerButtonNormal.png")
    else
        self.keyPlayerButtons[keyPlayerType]:GetComponent(Image).overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Formation/Images/KeyPlayerButtonDisable.png")
    end
end

-- 设置关键球员按钮位置
function FormationKeyPlayerBoardView:SetKeyPlayerButtonPos(keyPlayerType, keyPlayerIndex)
    local y = self.barHeight * (self.playersNumber - keyPlayerIndex + 0.5)
    local buttonTransform = self.keyPlayerButtons[keyPlayerType].transform
    buttonTransform.localPosition = Vector3(buttonTransform.localPosition.x, y, buttonTransform.localPosition.z)
end

-- 检查点击区域是否在关键球员按钮区域
function FormationKeyPlayerBoardView:CheckClickKeyPlayerButtonArea(eventData)
    for k, v in pairs(self.keyPlayerButtons) do
        if RectTransformUtility.RectangleContainsScreenPoint(v.transform, eventData.position, eventData.pressEventCamera) then
            return k
        end
    end
end

-- 获取点击点的局部位置
function FormationKeyPlayerBoardView:GetClickPointLocalPosition(eventData)
    local success, localPosition = RectTransformUtility.ScreenPointToLocalPointInRectangle(self.transform, eventData.position, eventData.pressEventCamera, Vector2.zero)
    if success then
        return localPosition
    end
end

-- 获取点击区域的首发球员索引
function FormationKeyPlayerBoardView:GetClickInitPlayerIndex(eventData)
    local localPosition = self:GetClickPointLocalPosition(eventData)
    local limitY = math.max(math.min(localPosition.y, self.buttonMoveMaxY), self.buttonMoveMinY)
    local index = math.ceil(limitY / self.barHeight)
    return self.playersNumber - index + 1
end

-- 设置关键球员
function FormationKeyPlayerBoardView:SetKeyPlayer(playerIndex, keyPlayerType)
    local highLightBar = self.keyPlayerHighLightBars[keyPlayerType]
    local highLightBarPosY = self.barHeight * (self.playersNumber - playerIndex + 0.5)
    highLightBar.transform.localPosition = Vector3(highLightBar.transform.localPosition.x, highLightBarPosY, highLightBar.transform.localPosition.z)
    highLightBar:SetActive(true)
    if playerIndex == nil then
        return
    end
    local pcid = self.initPlayers[playerIndex]
    if pcid ~= nil and self.initPlayerBars[pcid] ~= nil then
        self.initPlayerBars[pcid]:ShowKeyPlayerInfoBoard(keyPlayerType)
    end
end

-- 取消设置关键球员
function FormationKeyPlayerBoardView:UnsetKeyPlayer()
    if self.clickInitPlayerIndex then
        self.keyPlayerHighLightBars[self.currentKeyPlayerType]:SetActive(false)
        local pcid = self.initPlayers[self.clickInitPlayerIndex]
        if pcid ~= nil and self.initPlayerBars[pcid] ~= nil then
            self.initPlayerBars[pcid]:HideKeyPlayerInfoBoard()
        end
        self.clickInitPlayerIndex = nil
    end
end

-- 设置拖动的关键球员按钮位置
function FormationKeyPlayerBoardView:SetDraggedKeyPlayerButtonPosition(eventData)
    local localPosition = self:GetClickPointLocalPosition(eventData)
    local limitY = math.max(math.min(localPosition.y, self.buttonMoveMaxY), self.buttonMoveMinY)
    local buttonTransform = self.keyPlayerButtons[self.currentKeyPlayerType].transform
    buttonTransform.localPosition = Vector3(buttonTransform.localPosition.x, limitY, buttonTransform.localPosition.z)
    local clickPlayerIndex = self:GetClickInitPlayerIndex(eventData)
    if self.clickInitPlayerIndex ~= clickPlayerIndex then
        self:UnsetKeyPlayer()
        self:SetKeyPlayer(clickPlayerIndex, self.currentKeyPlayerType)
        self.clickInitPlayerIndex = clickPlayerIndex
    end
end

-- 缓存关键球员数据
function FormationKeyPlayerBoardView:CacheKeyPlayersData()
    if self.clickInitPlayerIndex then 
        for i, pcid in ipairs(self.initPlayers) do 
            if i == self.clickInitPlayerIndex then 
                self.keyPlayers[self.currentKeyPlayerType] = pcid
                break
            end
        end
    end
end

-- 点击确定按钮才真正缓存数据
function FormationKeyPlayerBoardView:SetKeyPlayersCacheData()
    self.formationCacheDataModel:SetKeyPlayersCacheData(self.keyPlayers)
end

-- 显示或隐藏关键球员按钮
function FormationKeyPlayerBoardView:ShowOrHideOtherKeyPlayerButtons(keyPlayerType, isShow)
    for k, keyPlayerButton in pairs(self.keyPlayerButtons) do
        if k ~= keyPlayerType then
            GameObjectHelper.FastSetActive(keyPlayerButton, isShow)
        end
    end
end

-- 显示或隐藏关键球员属性
function FormationKeyPlayerBoardView:ShowOrHideKeyPlayerAttr(isShow)
    for pcid, barScript in pairs(self.initPlayerBars) do
        barScript:ShowOrHideKeyPlayerAttr(self.currentKeyPlayerType, isShow)
    end
end

function FormationKeyPlayerBoardView:onPointerDown(eventData)
    local keyPlayerType = self:CheckClickKeyPlayerButtonArea(eventData)
    if keyPlayerType then
        self.currentKeyPlayerType = keyPlayerType
        self.clickInitPlayerIndex = self:GetClickInitPlayerIndex(eventData)
        self:SetKeyPlayer(self.clickInitPlayerIndex, keyPlayerType)
        self:ShowOrHideKeyPlayerAttr(true)
        self.keyPlayerButtons[self.currentKeyPlayerType]:GetComponent(Image).overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Formation/Images/KeyPlayerButtonNormal.png")
        self:ShowOrHideOtherKeyPlayerButtons(keyPlayerType, false)
    end
end

function FormationKeyPlayerBoardView:onBeginDrag(eventData)
    if self.currentKeyPlayerType then
        self.isDragging = true
        self:SetDraggedKeyPlayerButtonPosition(eventData)
    end
end

function FormationKeyPlayerBoardView:onDrag(eventData)
    if self.currentKeyPlayerType then
        self:SetDraggedKeyPlayerButtonPosition(eventData)
    end
end

function FormationKeyPlayerBoardView:onEndDrag(eventData)
    self.isDragging = false
end

function FormationKeyPlayerBoardView:onPointerUp(eventData)
    self:CacheKeyPlayersData()
    if self.isDragging then
        self:SetKeyPlayerButtonPos(self.currentKeyPlayerType, self.clickInitPlayerIndex)
    end
    self:UnsetKeyPlayer()
    self:ShowOrHideKeyPlayerAttr(false)
    if self.currentKeyPlayerType then
        self.keyPlayerButtons[self.currentKeyPlayerType]:GetComponent(Image).overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Formation/Images/KeyPlayerButtonNormal.png")
    end
    self:ShowOrHideOtherKeyPlayerButtons(self.currentKeyPlayerType, true)
    if self.currentKeyPlayerType then
        self.currentKeyPlayerType = nil
    end
end

return FormationKeyPlayerBoardView

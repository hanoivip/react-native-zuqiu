local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Input = UnityEngine.Input
local RectTransformUtility = UnityEngine.RectTransformUtility
local Vector3 = UnityEngine.Vector3
local Time = UnityEngine.Time
local AssetFinder = require("ui.common.AssetFinder")
local HonorPalaceItemModel = require("ui.models.honorPalace.HonorPalaceItemModel")

local LuaEventTriggerBeginDrag = clr.LuaEventTriggerBeginDrag
local LuaEventTriggerDrag = clr.LuaEventTriggerDrag
local LuaEventTriggerInitializePotentialDrag = clr.LuaEventTriggerInitializePotentialDrag

local TrophyItem = class(unity.base)

local TIME_OF_ENSURE_DRAG = 0.2
local DISTANCE_OF_ENSURE_DRAG = 1

function TrophyItem:ctor()
    self.rectTrans = self.___ex.rectTrans
    self.luaEventTrigger = self.___ex.luaEventTrigger:GetComponent(LuaEventTrigger)
    self.trophyImage = self.___ex.trophyImage
    self.trophyArea = self.___ex.trophyArea
    self.info = self.___ex.info
    self.canvasGroup = self.___ex.canvasGroup
    self.trophyName = self.___ex.trophyName
    self.emptyCup = self.___ex.emptyCup
    self.emptyName = self.___ex.emptyName
    self.animator = self.___ex.animator
    self.isCreateDragNodeDelayed = true
    self.hasCreateDragNode = false
    self.isBeginDrag = false
end

function TrophyItem:start()
    EventSystem.AddEvent("TrophyItem.EnableBeDraged", self, self.EnableBeDraged)
end

function TrophyItem:InitView(trophyId)
    self.trophyId = trophyId
    if trophyId ~= 0 then
        self:HideChild(true)
        self.trophyImage.overrideSprite = AssetFinder.GetHonorPalaceTrophyIcon(trophyId)
        self.trophyImage:SetNativeSize()
        self.trophyName.text = HonorPalaceItemModel:GetNameByID(trophyId)
        self:EnableBeDraged()
    else
        self:HideChild(false)
        self:DisableBeDraged()
    end
end

function TrophyItem:HideChild(state)
    --self.info:SetActive(state)
    self.trophyName.gameObject:SetActive(state)
    self.emptyName:SetActive(not state)
    self.trophyArea:SetActive(state)
    self.emptyCup:SetActive(not state)
end

function TrophyItem:IsShowInfo(isShowInfo)
    self.info:SetActive(isShowInfo)
    self.emptyCup:SetActive(isShowInfo)
end

function TrophyItem:SetPositon(posIndex)
    self.posIndex = posIndex
end

function TrophyItem:PlayShakeAnim(state)
    self.animator.enabled = state
    self.animator:Play("MetalMove")
end

function TrophyItem:PlayIdleAnim(state)
    self.animator.enabled = state
    self.animator:Play("MetalIdle")
end

function TrophyItem:onInitializePotentialDrag(eventData)
    self.isBeginDrag = false
    self.isCreateDragNodeDelayed = true
    self.recordTime = Time.unscaledTime
    self.hasCreateDragNode = false
    self:coroutine(function()
        while self.isCreateDragNodeDelayed == true do
            if Time.unscaledTime - self.recordTime > TIME_OF_ENSURE_DRAG then
                self.isCreateDragNodeDelayed = false
                self:CreateDraggingNode()
                self:FollowFinger(eventData)
            end
            coroutine.yield()
        end
    end)
end

function TrophyItem:onBeginDrag(eventData)
    if not self.hasCreateDragNode then 
        if math.abs(eventData.delta.x) / math.abs(eventData.delta.y) > DISTANCE_OF_ENSURE_DRAG then
            self:CreateDraggingNode()
            self.isCreateDragNodeDelayed = false
            self:FollowFinger(eventData)
        end
    end
    self.isBeginDrag = true
end

function TrophyItem:onDrag(eventData)
    if self.hasCreateDragNode then
        self:FollowFinger(eventData)
    end
end

function TrophyItem:onPointerUp(eventData)
    self.isCreateDragNodeDelayed = false
    if self.hasCreateDragNode == true and not self.isBeginDrag then
        self:DestroyDraggingNode()
    end
end

function TrophyItem:onEndDrag(eventData)
    self.isBeginDrag = false
    if self.hasCreateDragNode then
        self:DestroyDraggingNode()
        local isContainsSelf = RectTransformUtility.RectangleContainsScreenPoint(self.rectTrans, eventData.position, eventData.pressEventCamera)
        if not isContainsSelf then
            EventSystem.SendEvent("TrophyRoomView.DealWithTrophy", self.trophyId, self.oldPosIndex)
        end
    end
end

function TrophyItem:onDrop(eventData)
    EventSystem.SendEvent("TrophyRoomView.RecieveDropData", self.posIndex)
end

function TrophyItem:CreateDraggingNode()
    self.oldPosIndex = self.posIndex
    self.canvasGroup.alpha = 0.5
    self.hasCreateDragNode = true
    local node = Object.Instantiate(res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/HonorPalace/TrophyItem.prefab"))
    local nodeScript = node:GetComponent(clr.CapsUnityLuaBehav)
    nodeScript:InitView(self.trophyId)
    nodeScript:IsShowInfo(false)
    nodeScript:CloseBlocksRaycasts()
    self.draggingNode = node.transform
    self.draggingNode:SetParent(self.transform.root, false)
    self.draggingNode:SetAsLastSibling()
end

function TrophyItem:DestroyDraggingNode()
    self.canvasGroup.alpha = 1
    self.hasCreateDragNode = false
    Object.Destroy(self.draggingNode.gameObject)
end

function TrophyItem:FollowFinger(eventData)
    if eventData.pointerEnter ~= nil then
        local success, globalMousePos = RectTransformUtility.ScreenPointToWorldPointInRectangle(self.draggingNode.transform.parent, eventData.position, eventData.pressEventCamera, Vector3.zero)
        if success then
            self.draggingNode.transform.position = globalMousePos
        end
    end
end

function TrophyItem:CloseBlocksRaycasts()
    self.canvasGroup.blocksRaycasts = false
end

function TrophyItem:DisableBeDraged()
    self.luaEventTrigger.TrigBeginDrag = false
    self.luaEventTrigger.TrigEndDrag = false
    self.luaEventTrigger.TrigDrag = false
    self.luaEventTrigger.TrigInitializePotentialDrag = false
end

function TrophyItem:EnableBeDraged()
    if self.trophyId ~= 0 then
        self.luaEventTrigger.TrigBeginDrag = true
        self.luaEventTrigger.TrigEndDrag = true
        self.luaEventTrigger.TrigDrag = true
        self.luaEventTrigger.TrigInitializePotentialDrag = true
    end
end

function TrophyItem:onDestroy()
    EventSystem.RemoveEvent("TrophyItem.EnableBeDraged", self, self.EnableBeDraged)
end

return TrophyItem

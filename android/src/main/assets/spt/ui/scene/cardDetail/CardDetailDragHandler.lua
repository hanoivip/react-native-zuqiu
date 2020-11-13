local CardDetailDragHandler = class(unity.base)

local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local RectTransformUtility = UnityEngine.RectTransformUtility
local RectTransform = UnityEngine.RectTransform

local EventSystem = require("EventSystem")

function CardDetailDragHandler:ctor()
    local rectTrans = self.gameObject:GetComponent(RectTransform)
    self.width = rectTrans.rect.width
    self.trigMovePercent = 0.2
end

function CardDetailDragHandler:GetPointerLocalPosition(eventData)
    local success, pt = RectTransformUtility.ScreenPointToLocalPointInRectangle(self.transform, eventData.position, eventData.pressEventCamera, Vector2.zero)
    if success then
        return pt
    end
end

function CardDetailDragHandler:onBeginDrag(eventData)
    self.beginPos = self:GetPointerLocalPosition(eventData)
end

function CardDetailDragHandler:OnDrag(eventData)
end

function CardDetailDragHandler:onEndDrag(eventData)
    self.endPos = self:GetPointerLocalPosition(eventData)
    local vec = self.endPos - self.beginPos
    if vec.x / self.width > self.trigMovePercent then
        -- rigth
        EventSystem.SendEvent("CardDetailDrag", true)
    elseif vec.x / self.width < -self.trigMovePercent then
        EventSystem.SendEvent("CardDetailDrag", false)
    end
end

return CardDetailDragHandler

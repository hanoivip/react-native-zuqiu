local HomeDragHandler = class(unity.base)

local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local RectTransformUtility = UnityEngine.RectTransformUtility
local RectTransform = UnityEngine.RectTransform

local EventSystem = require("EventSystem")

function HomeDragHandler:ctor()
    local rectTrans = self.gameObject:GetComponent(RectTransform)
    self.width = rectTrans.rect.width
    self.trigMovePercent = 0.07
end

function HomeDragHandler:GetPointerLocalPosition(eventData)
    local success, pt = RectTransformUtility.ScreenPointToLocalPointInRectangle(self.transform, eventData.position, eventData.pressEventCamera, Vector2.zero)
    if success then
        return pt
    end
end

function HomeDragHandler:onBeginDrag(eventData)
    self.beginPos = self:GetPointerLocalPosition(eventData)
end

function HomeDragHandler:OnDrag(eventData)
end

function HomeDragHandler:onEndDrag(eventData)
    self.endPos = self:GetPointerLocalPosition(eventData)
    local vec = self.endPos - self.beginPos
    if vec.x / self.width > self.trigMovePercent then
        -- rigth
        EventSystem.SendEvent("FirstTeamDarg", true)
    elseif vec.x / self.width < -self.trigMovePercent then
        EventSystem.SendEvent("FirstTeamDarg", false)
    end
end

return HomeDragHandler

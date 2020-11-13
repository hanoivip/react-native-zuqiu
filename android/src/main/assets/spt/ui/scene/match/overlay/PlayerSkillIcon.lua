local UnityEngine = clr.UnityEngine
local System = UnityEngine.System
local Collections = System.Collections
local UI = UnityEngine.UI
local Text = UI.Text
local Image = UI.Image
local Generic = Collections.Generic
local Sprite = UnityEngine.Sprite
local Object = UnityEngine.Object
local PlayerSkillIcon = class(unity.base)
local RectTransform = UnityEngine.RectTransform
local CanvasGroup = UnityEngine.CanvasGroup
local Vector3 = UnityEngine.Vector3
local Screen = UnityEngine.Screen
local ParticleSystem = UnityEngine.ParticleSystem
local Camera = UnityEngine.Camera
local Canvas = UnityEngine.Canvas
local RectTransformUtility = UnityEngine.RectTransformUtility
local Time = UnityEngine.Time
local Mathf = UnityEngine.Mathf
local RenderMode = UnityEngine.RenderMode
local Vector2 = UnityEngine.Vector2
local Resources = UnityEngine.Resources

function PlayerSkillIcon:ctor()
    self.skillIconObj = self.___ex.skillIconObj
    self.skillIconImage = self.skillIconObj:GetComponent(Image)
    self.showTime = 0
    self.camera = Camera.main
    self.canvasWidth = 0
    self.canvasHeight = 0
    self.followPlayerObject = nil
    self.isOpenFade = false
    self.currentFadeState = nil
    self.startFadeTime = 0
    self.fadeTime = self.___ex.fadeTime
    self.deltaX = self.___ex.deltaX
    self.deltaY = self.___ex.deltaY
end

local FadeState =
{
    fadeIdle = 1,
    fadein = 2,
    fadeOut = 3
}

function PlayerSkillIcon:start()
    local canvasRectTransform = self.transform:GetComponent(RectTransform)
    self.canvasWidth = canvasRectTransform.rect.width
    self.canvasHeight = canvasRectTransform.rect.height
    self.canvas = self.transform:GetComponent(Canvas)
    self.canvas.renderMode = RenderMode.ScreenSpaceCamera
    self.canvas.worldCamera = self.camera
    self.canvas.planeDistance = 1
end

function PlayerSkillIcon:CurrentPlayerObject()
    return self.followPlayerObject
end

function PlayerSkillIcon:UpdateSkillIcon()
    if not self.followPlayerObject then
        return
    end
    self:SwitchFadeState()
end

function PlayerSkillIcon:SwitchFadeState()
    if self.currentFadeState == FadeState.fadein then
        self.showTime = self.showTime - Time.unscaledDeltaTime
        if self.showTime <= 0 then
            self.startFadeTime = self.fadeTime
            self.currentFadeState = FadeState.fadeOut
        end
        self:AdjustDirectionAndPosition()
    elseif self.currentFadeState == FadeState.fadeOut then
        self:HasFadeOut()
    elseif self.currentFadeState == FadeState.fadeIdle then
    end
end

function PlayerSkillIcon:HasFadeOut()
    if self.startFadeTime > 0 then
        self:AdjustDirectionAndPosition()
        self.startFadeTime = self.startFadeTime - Time.unscaledDeltaTime
        self.gameObject:GetComponent(CanvasGroup).alpha = self.gameObject:GetComponent(CanvasGroup).alpha -
        1 / self.fadeTime * Time.unscaledDeltaTime
    else
        self.gameObject:SetActive(false)
        self.currentFadeState = FadeState.fadeIdle
    end
end

function PlayerSkillIcon:InitialSkillIcon(followObject, skillIcon, deltaTime)
    self.currentFadeState = FadeState.fadein
    if deltaTime == nil then
        deltaTime = 5
    end
    self.gameObject:GetComponent(CanvasGroup).alpha = 1
    self.startFadeTime = 0
    self.followPlayerObject = followObject
    local path = "Assets/CapstonesRes/Game/UI/Common/Skill/Image/" .. skillIcon .. ".png"
    self.skillIconImage.overrideSprite = res.LoadRes(path, Sprite)
    self.showTime = deltaTime
end

function PlayerSkillIcon:AdjustDirectionAndPosition()
    local worldPos = self.followPlayerObject.transform.position 
    worldPos.y = worldPos.y + 1.8
    local pos = Camera.main.WorldToScreenPoint(worldPos)
    pos.y = pos.y + 40
    local viewPos = Camera.main.WorldToViewportPoint(self.followPlayerObject.transform.position)
    local isVisible =(Camera.main.isOrthoGraphic or viewPos.z > 0) and(viewPos.x > 0 and viewPos.x < 1 and viewPos.y > 0 and viewPos.y < 1)
    if (isVisible) then
        self.skillIconObj:SetActive(true)
        local imageRectTransform = self.skillIconObj:GetComponent(RectTransform)
        --imageRectTransform.anchoredPosition = Vector2(pos.x / self.canvas.scaleFactor, pos.y / self.canvas.scaleFactor)

--        local success, pt = RectTransformUtility.ScreenPointToLocalPointInRectangle(self.transform, Vector2(pos.x, pos.y), self.camera,  Vector2.zero)
--        if success then 
----            dump("pt.x = "..pt.x)
----            dump("pt.y = "..pt.y)
----            dump("pos.x = "..pos.x)
----            dump("pos.y = "..pos.y)

--            imageRectTransform.localPosition = Vector3(pt.x,pt.y,imageRectTransform.localPosition.z)
--        else
--            dump("error~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!")
--        end
    else
        self.skillIconObj:SetActive(false)
    end
end

return PlayerSkillIcon

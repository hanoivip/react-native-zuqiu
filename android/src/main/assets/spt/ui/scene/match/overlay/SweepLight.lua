local UnityEngine = clr.UnityEngine
local System = UnityEngine.System
local Collections = System.Collections
local UI = UnityEngine.UI
local Text = UI.Text
local Image = UI.Image
local Generic = Collections.Generic
local Sprite = UnityEngine.Sprite
local Object = UnityEngine.Object
local SweepLight = class(unity.base)
local RectTransform = UnityEngine.RectTransform
local Mathf = UnityEngine.Mathf
local Resources = UnityEngine.Resources
local Time = UnityEngine.Time
local Vector3 = UnityEngine.Vector3

function SweepLight:ctor()
    self.maskImage = self.___ex.maskImage:GetComponent(Image)
    self.lightObject = self.___ex.lightObject
    self.maxSpeed = self.___ex.maxSpeed
    self.smoothValue = 0
    self.startPosition = nil
    self.targetPosition = nil
    self.xVelocity = 0
    self.realtimeStamp = 0
end

function SweepLight:SweepLightData(maskPosition, maskSize, lightPosition, lightSize, endPosition, imagePath)
    local rect = self.transform:GetComponent(RectTransform)
    rect.sizeDelta = maskSize
    self.transform.localPosition = maskPosition
    local rect1 = self.lightObject.transform:GetComponent(RectTransform)
    rect1.sizeDelta = lightSize
    self.lightObject.transform.localPosition = lightPosition
    self.startPosition = lightPosition
    if imagePath ~= nil then 
        self.maskImage.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Match/MatchMenu/"..imagePath..".png", Sprite)
    end
    self.targetPosition = endPosition
end

function SweepLight:update()
    if Mathf.Abs(self.smoothValue - self.targetPosition.x) > 1 then
        self.smoothValue, self.xVelocity = Mathf.SmoothDamp(self.lightObject.transform.localPosition.x, self.targetPosition.x, self.xVelocity, 0.1, self.maxSpeed, Time.realtimeSinceStartup - self.realtimeStamp)
    else
        self.smoothValue = self.startPosition.x
    end
    self.realtimeStamp = Time.realtimeSinceStartup
    self.lightObject.transform.localPosition = Vector3(self.smoothValue, 0, 0)
end

return SweepLight

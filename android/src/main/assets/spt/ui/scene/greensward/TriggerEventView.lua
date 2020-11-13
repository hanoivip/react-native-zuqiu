local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local TriggerEventView = class(unity.base)

function TriggerEventView:ctor()
    self.image = self.___ex.image
    self.btnIcon = self.___ex.btnIcon
    self:Init()
end

function TriggerEventView:Init()
    self.btnIcon:regOnButtonClick(function (eventData)
        if self.eventModel:IsShowDialog() then
            self.eventModel:TriggerEvent()
        else
            self.eventModel:HandleEventExtension()
        end
    end)
end

function TriggerEventView:InitView(eventModel, greenswardResourceCache)
    self.eventModel = eventModel
    local eventIcon = eventModel:GetEventIcon()
    local bg = eventIcon[1] or ""
    self.image.overrideSprite = greenswardResourceCache:GetLogoRes(bg)
    self.image:SetNativeSize()

    self.eventModel:DestroyExtensions(self.pingpongTween)
    if self.eventModel:HasTweenExtension() then
        self.pingpongTween = self.eventModel:CreatePingPongExtensions(self.transform)
    end

    local uiParam = eventModel:GetUIParam()
    local pos = uiParam.icon_pos
    if pos then
        self.image.transform.anchoredPosition = Vector2(pos.x, pos.y)
    end
    local scale = uiParam.icon_scale
    if scale then
        self.image.transform.localScale = Vector3(scale.x, scale.y, scale.z)
    end
end

function TriggerEventView:onDestroy()
    self.eventModel:DestroyExtensions(self.pingpongTween)
end

return TriggerEventView

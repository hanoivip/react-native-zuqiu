local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlaneEventView = class(unity.base)

function PlaneEventView:ctor()
    self.image = self.___ex.image
    self.btnIcon = self.___ex.btnIcon
    self.imageCanvas = self.___ex.imageCanvas
    self:Init()
end

function PlaneEventView:Init()
    self.btnIcon:regOnButtonClick(function (eventData)
        if self.eventModel:IsShowDialog() then
            self.eventModel:TriggerEvent()
        end
    end)
    EventSystem.AddEvent("GreenswardPlaneEffectShow", self, self.PlaneEffectShow)
end

local AnimationTime = 0.8
function PlaneEventView:PlaneEffectShow(isFly)
    if isFly == self.eventModel:IsFlyAction() then
        self:coroutine(function()
            if not self.flyEffectRes then
                local flyAnimationRes = self.eventModel:GetFlyAnimationRes()
                local obj = Object.Instantiate(res.LoadRes(flyAnimationRes))
                obj.transform:SetParent(self.transform, false)
                self.flyEffectRes = obj
            end
            GameObjectHelper.FastSetActive(self.image.gameObject, true)
            self.eventModel:CreateFadeInExtensions(self.imageCanvas)
            coroutine.yield(UnityEngine.WaitForSeconds(AnimationTime))
            self:DeleteFlyEffect()
        end)
    end
end

function PlaneEventView:InitView(eventModel, greenswardResourceCache)
    self.eventModel = eventModel
    local eventIcon = eventModel:GetEventIcon()
    local bg = eventIcon[1] or ""
    self.image.overrideSprite = greenswardResourceCache:GetLogoRes(bg)
    self.image:SetNativeSize()
    local isShowPlane = self.eventModel:IsShowPlane()
    GameObjectHelper.FastSetActive(self.image.gameObject, isShowPlane)
end

function PlaneEventView:DeleteFlyEffect()
    if self.flyEffectRes then
        Object.Destroy(self.flyEffectRes)
    end
    self.flyEffectRes = nil
end

function PlaneEventView:onDestroy()
    self:DeleteFlyEffect()
    EventSystem.RemoveEvent("GreenswardPlaneEffectShow", self, self.PlaneEffectShow)
end

return PlaneEventView

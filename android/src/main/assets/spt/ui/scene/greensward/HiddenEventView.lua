local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local GameObjectHelper = require("ui.common.GameObjectHelper")

local HiddenEventView = class(unity.base, "HiddenEventView")

function HiddenEventView:ctor()
    self.content = self.___ex.content
    self.icon = self.___ex.icon
    self.btnIcon = self.___ex.btnIcon
    self.btnEvent = self.___ex.btnEvent
    self:Init()
end

function HiddenEventView:Init()
    self.btnEvent:regOnButtonClick(function(eventData)
        -- 拥有对应楼层的藏宝图
        if not self.isShow and self.eventModel:CanEssentialItemFill() then
            self.eventModel:ActivationEvent()
        end
    end)
    self.btnIcon:regOnButtonClick(function(eventData)
        if self.isShow then
            self.eventModel:TriggerEvent()
        end
    end)
end

function HiddenEventView:InitView(eventModel, greenswardResourceCache)
    self.eventModel = eventModel
    self.isShow = self.eventModel:IsShowDialog()
    self.eventModel:DestroyExtensions(self.pingpongTween)
    local isTreasureFound = self.eventModel:IsTreausreFound()
    if self.isShow and not isTreasureFound then
        if self.eventModel:HasTweenExtension() then
            self.pingpongTween = self.eventModel:CreatePingPongExtensions(self.transform)
        end

        local eventIcon = eventModel:GetEventIcon()
        local bg = eventIcon[1] or ""
        self.icon.overrideSprite = greenswardResourceCache:GetLogoRes(bg)
        self.icon:SetNativeSize()

        local uiParam = eventModel:GetUIParam()
        local pos = uiParam.icon_pos
        if pos then
            self.icon.transform.anchoredPosition = Vector2(pos.x, pos.y)
        end
        local scale = uiParam.icon_scale
        if scale then
            self.icon.transform.localScale = Vector3(scale.x, scale.y, scale.z)
        end
    elseif isTreasureFound then
        GameObjectHelper.FastSetActive(self.gameObject, false)
    end
    GameObjectHelper.FastSetActive(self.content.gameObject, self.isShow)
    GameObjectHelper.FastSetActive(self.btnEvent.gameObject, not self.isShow)
end

function HiddenEventView:onDestroy()
    self.eventModel:DestroyExtensions(self.pingpongTween)
end

return HiddenEventView

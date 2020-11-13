local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local GameObjectHelper = require("ui.common.GameObjectHelper")

local UseItemEventView = class(unity.base, "UseItemEventView")

function UseItemEventView:ctor()
    self.image = self.___ex.image
    self.btnIcon = self.___ex.btnIcon
    self.imgShadow = self.___ex.imgShadow
    self.btnTrigger = self.___ex.btnTrigger
    self:Init()
end

function UseItemEventView:Init()
    self.btnIcon:regOnButtonClick(function (eventData)
        if self.eventModel:IsShowDialog() then
            self.eventModel:TriggerEvent()
            self:UpdateTrigger()
        end
    end)
    self.btnTrigger:regOnButtonClick(function(eventData)
        local stuFill = tobool(tonumber(self.eventModel:GetCurrentState()) == self.eventModel.EventStatus.BeOperable) -- 可操作状态
        if stuFill and self.eventModel:CanEssentialItemFill() then -- 玩家拥有[必需道具]且满足数量条件
            local essentialItem = self.eventModel:GetEssentialItem()
            -- 更新同类型的其他事件
            for k, v in ipairs(essentialItem or {}) do
                EventSystem.SendEvent("Greensward_UseItemEventRefresh", v.id)
            end
            GameObjectHelper.FastSetActive(self.image.gameObject, true)
            GameObjectHelper.FastSetActive(self.imgShadow.gameObject, true)
            self:UpdateTrigger()
            self:PlayTweenExtensions()
        else
            self.eventModel:HandleClickEvent()
        end
    end)
end

function UseItemEventView:InitView(eventModel, greenswardResourceCache)
    self.eventModel = eventModel
    local eventIcon = eventModel:GetEventIcon()
    local bg = eventIcon[1] or "Seaweed"
    self.image.overrideSprite = greenswardResourceCache:GetLogoRes(bg)
    self.image:SetNativeSize()

    local uiParam = eventModel:GetUIParam()
    local pos = uiParam.icon_pos
    if pos then
        self.image.transform.anchoredPosition = Vector2(pos.x, pos.y)
    end
    local scale = uiParam.icon_scale
    if scale then
        self.image.transform.localScale = Vector3(scale.x, scale.y, scale.z)
    end

    GameObjectHelper.FastSetActive(self.image.gameObject, false)
    GameObjectHelper.FastSetActive(self.imgShadow.gameObject, false)
    GameObjectHelper.FastSetActive(self.btnTrigger.gameObject, true)
end

function UseItemEventView:PlayTweenExtensions()
    self.eventModel:DestroyExtensions(self.pingpongTween)
    if self.eventModel:HasTweenExtension() then
        self.transform.anchoredPosition = Vector2.zero
        self.pingpongTween = self.eventModel:CreatePingPongExtensions(self.transform)
    end
end

function UseItemEventView:UpdateTrigger()
    local isTrigger = tobool(tonumber(self.eventModel:GetCurrentState()) == self.eventModel.EventStatus.BeOperable)
                    and self.eventModel:ConsumeByItem()
                    and self.eventModel:CanConsumeItemFill()
    GameObjectHelper.FastSetActive(self.btnTrigger.gameObject, isTrigger)
end

function UseItemEventView:onDestroy()
    self.eventModel:DestroyExtensions(self.pingpongTween)
end

return UseItemEventView

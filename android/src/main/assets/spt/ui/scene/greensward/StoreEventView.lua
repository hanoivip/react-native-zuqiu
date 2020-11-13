local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local Timer = require("ui.common.Timer")
local LuaButton = require("ui.control.button.LuaButton")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local StoreEventView = class(LuaButton)

function StoreEventView:ctor()
    self.super.ctor(self)
--------Start_Auto_Generate--------
    self.residualTimeGo = self.___ex.residualTimeGo
    self.residualTimerTxt = self.___ex.residualTimerTxt
--------End_Auto_Generate----------
    self.image = self.___ex.image
    self:Init()
end

function StoreEventView:Init(eventModel)
    self:regOnButtonClick(function(eventData)
        local endTip = self.eventModel:GetEndTips()
        if endTip then
            DialogManager.ShowToastByLang(endTip)
        elseif self.eventModel:IsShowDialog() then
            self.eventModel:TriggerEvent()
        end
    end)
end

function StoreEventView:InitView(eventModel, greenswardResourceCache)
    self.eventModel = eventModel
    self.greenswardResourceCache = greenswardResourceCache
    local eventIcon = eventModel:GetEventIcon()
    local isShowResidualTimer = eventModel:IsShowResidualTimer()
    self.image.overrideSprite = greenswardResourceCache:GetLogoRes(eventIcon)
    self.image:SetNativeSize()
    local uiParam = eventModel:GetUIParam()
    local pos = uiParam.icon_pos
    if pos then
        self.transform.anchoredPosition = Vector2(pos.x, pos.y)
    end
    local scale = uiParam.icon_scale
    if scale then
        self.transform.localScale = Vector3(scale.x, scale.y, scale.z)
    end

    GameObjectHelper.FastSetActive(self.residualTimeGo, isShowResidualTimer)
    if isShowResidualTimer then
        self:RefreshTimer()
    end
end

function StoreEventView:RefreshTimer()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
    local remainTime = self.eventModel:GetRemainTime()
    local isPreserveEvent = self.eventModel:IsPreserveEvent()
    if remainTime <= 1 then
        self.residualTimerTxt.text = lang.trans("belatedGift_item_nil_time")
        GameObjectHelper.FastSetActive(self.residualTimeGo, false)
        GameObjectHelper.FastSetActive(self.gameObject, isPreserveEvent)
        return
    end
    self.residualTimer = Timer.new(remainTime, function(time)
        if time <= 1 then
            self.residualTimerTxt.text = lang.trans("belatedGift_item_nil_time")
            GameObjectHelper.FastSetActive(self.residualTimeGo, false)
            GameObjectHelper.FastSetActive(self.gameObject, isPreserveEvent)
            if isPreserveEvent then
                local eventIcon = self.eventModel:GetEventIcon()
                self.image.overrideSprite = self.greenswardResourceCache:GetLogoRes(eventIcon)
                self.image:SetNativeSize()
            end
            return
        else
            local t = string.convertSecondToTime(time)
            self.residualTimerTxt.text = tostring(t)
        end
    end)
end

function StoreEventView:onDestroy()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
end

return StoreEventView

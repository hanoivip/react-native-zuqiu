local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Animator = UnityEngine.Animator
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local LuaButton = require("ui.control.button.LuaButton")
local ConstructionFrameView = class(LuaButton)

function ConstructionFrameView:ctor()
    self.super.ctor(self)
    self.image = self.___ex.image
    self.cloud = self.___ex.cloud
    self.pic = self.___ex.pic
    self.eventArea = self.___ex.eventArea
    self.cloudCanvasGroup = self.___ex.cloudCanvasGroup
    self.eventCanvasGroup = self.___ex.eventCanvasGroup
    -- 最高层级遮罩
    self.suprmeClick = self.___ex.suprmeClick

    self.eventRes = {}
    self:Init()
end

function ConstructionFrameView:Init()
    self:regOnButtonClick(function (eventData)
        if self.eventModel:HasUnlock() then
            self:OnButtonClick()
        else
            self.eventModel:HandleClickEvent()
        end
    end)
    self.suprmeClick:regOnButtonClick(function()
        EventSystem.SendEvent("GreenswardFlashBang_OnClickMapFrame", self, self.eventModel)
    end)
end

function ConstructionFrameView:InitView(row, col, eventModel, greenswardResourceCache)
    self.row = row
    self.col = col
    self.eventModel = eventModel
    self.greenswardResourceCache = greenswardResourceCache
    self:DeleteOldDetails()
    self:UpdateDetails()
end

function ConstructionFrameView:UpdateDetails()
    local basePic = self.eventModel:GetBasePic()
    self.image.overrideSprite = self.greenswardResourceCache:GetGrassRes(basePic)
    local hasFog = self.eventModel:HasFog()
    GameObjectHelper.FastSetActive(self.cloud.gameObject, hasFog)
    if hasFog then
        self.cloud.overrideSprite = self.greenswardResourceCache:GetCloudRes(self.eventModel:GetFogRes())
        self:DeleteAllEventRes() -- 从没有迷雾状态更新会有迷雾状态，需要删除所有事件
        self:UpdateEffect()
    else
        self:DeleteUnusedCloudRes()
        self:UpdateEventDetails()
    end

    local picIndex = self.eventModel:GetPicIndex()
    local hasPic = false
    if not hasFog and picIndex and picIndex ~= "" then
        hasPic = true
        self.pic.overrideSprite = self.greenswardResourceCache:GetPicRes(picIndex)
    end
    GameObjectHelper.FastSetActive(self.pic.gameObject, hasPic)
end

function ConstructionFrameView:UpdateEffect()
    local isUnlock = self.eventModel:HasUnlock() -- 可解锁动效云
    if isUnlock then
        self.cloud.enabled = false
        self:InstantiateDynamicCloud()
    else
        self.cloud.enabled = true
        self:DeleteDynamicCloud()
    end

    local cloudEffectRes = self.eventModel:GetCloudEffectRes() -- 特殊云效果
    if cloudEffectRes then
        self:InstantiateDynamicCloudEffect()
    else
        self:DeleteDynamicEffectCloud()
    end
end

function ConstructionFrameView:CloudAnimationPlay()
    local ani = self:GetCloudAnimation()
    if ani then
        ani:Play("EffectFog", 0, 0)
    end
end

function ConstructionFrameView:CloudFadeOutAnimationPlay()
    local ani = self:GetCloudAnimation()
    if ani then
        ani:Play("EffectFogClose", 0, 0)
    end
end

function ConstructionFrameView:GetCloudAnimation()
    if self.dynamicCloudRes then
        return self.dynamicCloudRes:GetComponent(Animator)
    end
end

function ConstructionFrameView:DeleteUnusedCloudRes()
    self.cloud.enabled = true
    self:DeleteDynamicCloud()
    self:DeleteDynamicEffectCloud()
end

function ConstructionFrameView:DeleteOldDetails()
    local lastEventId, script = next(self.eventRes)
    if lastEventId then
        self:DeleteEventRes(script.gameObject)
    end
end

function ConstructionFrameView:DeleteEventRes(obj)
    if obj then
        Object.Destroy(obj)
    end
    self.eventRes = { }
end

function ConstructionFrameView:DeleteDynamicCloud()
    if self.dynamicCloudRes then
        Object.Destroy(self.dynamicCloudRes)
    end
    self.dynamicCloudRes = nil
end

function ConstructionFrameView:DeleteDynamicEffectCloud()
    if self.dynamicCloudEffectRes then
        Object.Destroy(self.dynamicCloudEffectRes)
    end
    self.dynamicCloudEffectRes = nil
end

function ConstructionFrameView:InstantiateDynamicCloud()
    if not self.dynamicCloudRes then
        local path = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Effect/EffectFog.prefab"
        local obj = Object.Instantiate(res.LoadRes(path))
        obj.transform:SetParent(self.cloud.transform, false)
        self.dynamicCloudRes = obj
        self:CloudAnimationPlay()
    end
end

function ConstructionFrameView:InstantiateDynamicCloudEffect()
    if not self.dynamicCloudEffectRes then
        local cloudEffectRes = self.eventModel:GetCloudEffectRes()
        local obj = Object.Instantiate(res.LoadRes(cloudEffectRes))
        obj.transform:SetParent(self.cloud.transform, false)
        self.dynamicCloudEffectRes = obj
    end
end

function ConstructionFrameView:UpdateEventDetails()
    local hasEvent = self.eventModel:HasEvent()
    local eventId = self.eventModel:GetEventId()
    local eventScript = self.eventRes[eventId]
    local lastEventId, script = next(self.eventRes)
    if lastEventId and lastEventId ~= eventId then -- 在某些事件触发时，会改变建筑内eventId
        self:DeleteEventRes(obj)
    end

    if hasEvent then -- 事件完成后有些事件会保留事件状态
        local isTheEventOver = self.eventModel:IsTheEventOver()
        local isPreserveEvent = self.eventModel:IsPreserveEvent()
        if isTheEventOver then
            if isPreserveEvent then
                self:InstantiateEvent(eventId)
            elseif eventScript then
                self:DeleteEventRes(eventScript.gameObject)
            end
        else
            self:InstantiateEvent(eventId)
        end
    elseif eventScript then
        self:DeleteEventRes(eventScript.gameObject)
    end
end

function ConstructionFrameView:InstantiateEvent(eventId)
    local eventScript = self.eventRes[eventId]
    local eventResName = self.eventModel:GetEventResName()
    if not eventScript then
        local path = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Event/" .. eventResName .. ".prefab"
        local obj = Object.Instantiate(res.LoadRes(path))
        obj.transform:SetParent(self.eventArea, false)
        local script = res.GetLuaScript(obj)
        self.eventRes[eventId] = script
    end
    self.eventRes[eventId]:InitView(self.eventModel, self.greenswardResourceCache)
end

function ConstructionFrameView:OnButtonClick()
    if self.btnClick then
        self.btnClick(self.row, self.col)
    end
end

-- 设置显示最高层级点击遮罩
function ConstructionFrameView:DisplaySuprmeMask(isShow)
    GameObjectHelper.FastSetActive(self.suprmeClick.gameObject, isShow)
end

-- 删除详细事件的prefab
function ConstructionFrameView:DeleteAllEventRes()
    for eventId, eventScript in pairs(self.eventRes) do
        self:DeleteEventRes(eventScript.gameObject)
    end
end

return ConstructionFrameView

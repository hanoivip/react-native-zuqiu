local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local Time = UnityEngine.Time
local WaitForEndOfFrame = UnityEngine.WaitForEndOfFrame
local Object = UnityEngine.Object
local Color = UnityEngine.Color
local Tweening = clr.DG.Tweening
local Tweener = Tweening.Tweener
local DOTween = Tweening.DOTween
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease
local LoopType = Tweening.LoopType
local TweenExtensions = Tweening.TweenExtensions
local RapidBlurEffect = clr.RapidBlurEffect
local Camera = UnityEngine.Camera
local PlayerLevelUpView = class(unity.base)
local EventSystem = require("EventSystem")
local AssetFinder = require("ui.common.AssetFinder")
local DialogManager = require("ui.control.manager.DialogManager")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local tostring = tostring
local tonumber = tonumber

-- 从低到高品质经验卡的道具ID
local expItemIDMap = {
    1001, 1002, 1003, 1004
}

local textAnimationDuration = 1.5
local textAnimationScale = 1.5
local textAnimationDefalutScale = 1
local addUpIntervalTime = 0.3 -- 连续使用经验饮料时的初始时间
local intervalTime = 0.02 -- 连续使用经验饮料时的间隔
local minIntervalTime = 0.01 -- 连续使用经验饮料时的最小时间
local startDurableTime = 1    -- 按下多长时间之后开始连续使用

function PlayerLevelUpView:ctor()
    self.expItem = self.___ex.expItem
    self.level = self.___ex.level
    self.levelLimit = self.___ex.levelLimit
    self.levelLimitObj = self.___ex.levelLimitObj
    self.levelProgress = self.___ex.levelProgress
    self.expItemNum = self.___ex.expItemNum
    self.abilityChange = self.___ex.abilityChange
    self.abilitySet = self.___ex.abilitySet
    self.abilityPlusSet = self.___ex.abilityPlusSet
    self.effectMap = self.___ex.effectMap
    self.effectLight = self.___ex.effectLight
    self.clickButton = self.___ex.clickButton
    self.clickArea = self.___ex.clickArea
    self.barRect = self.___ex.barRect
    self.rapidBlurEffectData = {}
    self.currentFillAmount = 0
    self.currentUseItem = nil
end

function PlayerLevelUpView:Close()
    local moveOut = ShortcutExtensions.DOAnchorPosY(self.barRect.transform, self.barRect.sizeDelta.y, 0.5)
    TweenSettingsExtensions.SetEase(moveOut, Ease.OutQuart)
    TweenSettingsExtensions.OnComplete(moveOut, function()  --Lua assist checked flag
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)
end

function PlayerLevelUpView:start()
    self.barRect.anchoredPosition = Vector2(0, self.barRect.sizeDelta.y)
    local moveIn = ShortcutExtensions.DOAnchorPosY(self.barRect.transform, 0, 0.5)
    TweenSettingsExtensions.SetEase(moveIn, Ease.OutQuart)

    self.clickButton:regOnButtonClick(function()
        self:Close()
    end)
    self.clickArea:regOnButtonClick(function()
        self:Close()
        if self.onClickArea then
            self.onClickArea()
        end
    end)

    for i = 1, 4 do
        self.expItem["level" .. tostring(i)]:regOnButtonDown(function()
            self:OnExpItemLevelDown(i)
        end)
        self.expItem["level" .. tostring(i)]:regOnButtonUp(function()
            self:OnExpItemLevelUp(i)
        end)
    end

    self.tweener = ShortcutExtensions.DOScale(self.level.transform, textAnimationScale, textAnimationDuration / 2)
    TweenSettingsExtensions.SetEase(self.tweener, Ease.OutElastic)
    TweenSettingsExtensions.SetAutoKill(self.tweener, false)
    TweenExtensions.Pause[Tweener](self.tweener)

    self:LoadModule()
end

function PlayerLevelUpView:EventAddExp()
    if self.addExpCallBack then
        self.addExpCallBack()
    end
end

function PlayerLevelUpView:EventLevelUp()
    if self.levelUpCallBack then
        self.levelUpCallBack()
    end
end

function PlayerLevelUpView:OnExpItemLevelDown(level)
    self.isTouching = true
    self.lastPressItemIndex = nil
    self.touchStartTime = Time.time
    self.consumeCount = 0
    self.addUpIntervalTime = addUpIntervalTime
    if self.clickExpItemDown then
        self.clickExpItemDown()
    end

    self:coroutine(function()
        while self.isTouching do
            if Time.time - self.touchStartTime > startDurableTime then
                if self.clickExpItemPressing then
                    self:SetEveryTimeEffect(level)
                    local message = self.clickExpItemPressing(level, self.consumeCount + 1)
                    if message and type(message) == "string" then
                        self.errorMessage = message
                    else
                        self:SetLevelUpEffectOnce()
                        self.consumeCount = self.consumeCount + 1
                    end
                end
            end
            coroutine.yield(UnityEngine.WaitForSeconds(self.addUpIntervalTime))
            if self.addUpIntervalTime > minIntervalTime then 
                self.addUpIntervalTime = self.addUpIntervalTime - intervalTime
            else
                self.addUpIntervalTime = minIntervalTime
            end
        end
    end)
end

local AnimatorEffectMap =
{
    "ExpItemLightAnimationLow",
    "ExpItemLightAnimationMiddle",
    "ExpItemLightAnimationHigh",
    "ExpItemLightAnimationSuper"
}

-- 单次点击特效
function PlayerLevelUpView:SetEveryTimeEffect(level)
    if not level then return end
    self.currentUseItem = level
    local effectAnimator = self.effectMap["level" .. level]
    GameObjectHelper.FastSetActive(effectAnimator.gameObject, true)
    effectAnimator:Play(AnimatorEffectMap[level], 0, 0)
end

-- 单次关闭点击特效
function PlayerLevelUpView:DisableUseEffect(level)
    if not level then return end
    local effectAnimator = self.effectMap["level" .. level]
    GameObjectHelper.FastSetActive(effectAnimator.gameObject, false)
end

-- 转圈播放特效
function PlayerLevelUpView:SetEffectLight()
    GameObjectHelper.FastSetActive(self.effectLight.gameObject, true)
    self.effectLight:Play("ProgressLightAnimation", 0, 0)
end

function PlayerLevelUpView:SetLevelUpEffectLast()
    self:SetEveryTimeEffect(self.lastPressItemIndex)
    self.levelUpEndAudio.PlayAudio("Assets/CapstonesRes/Game/Audio/UI/CardLevelUp/levelUpEnd.wav", 0.5)
end

function PlayerLevelUpView:SetLevelUpEffectOnce()
    if not self.levelUpRotationAudio.isPlaying then
        self.levelUpStartAudio.PlayAudio("Assets/CapstonesRes/Game/Audio/UI/CardLevelUp/levelUpStart.wav", 0.5)
    end
    GameObjectHelper.FastSetActive(self.levelLimitObj, false)
end

function PlayerLevelUpView:OnExpItemLevelUp(level)
    self.isTouching = false
    self.lastPressItemIndex = level
    if self.clickExpItemUp then
        self.clickExpItemUp(level, self.consumeCount)
    end
end

function PlayerLevelUpView:InitView(cardModel, itemsMapModel)
    if self.aniCor then
        self:StopCoroutine(self.aniCor)
        self.aniCor = nil
    end
    -- 动画中使用
    self.cardModel = cardModel
    self.animateExp = cardModel:GetExp()
    --end
    self.level.text = tostring(cardModel:GetLevel())
    self.levelLimit.text = "/" .. tostring(cardModel:GetLevelLimit())
    local percent = tonumber(cardModel:GetExp() - cardModel:GetExpLimit()) / tonumber(cardModel:GetLevelUpExp())
    self.levelProgress.fillAmount = percent
    self.currentFillAmount = percent
    for i = 1, 4 do
        self.expItemNum["level" .. tostring(i)].text = "x" .. tostring(tonumber(itemsMapModel:GetItemNum(expItemIDMap[i])))
    end
end

function PlayerLevelUpView:ShowAbilityIncrease(currentAbility, cacheAbilty)
end

function PlayerLevelUpView:SetExp(cardLevel, expPerecent, animateExp)
    self.animateExp = animateExp
    self.level.text = tostring(cardLevel)
    self.levelProgress.fillAmount = tonumber(expPerecent)
    if tonumber(expPerecent) < self.currentFillAmount then 
        self:SetEffectLight()
    end
    self.currentFillAmount = expPerecent
end

function PlayerLevelUpView:SetItem(level, num)
    self.expItemNum["level" .. tostring(level)].text = "x" .. tostring(num)
end

function PlayerLevelUpView:EventResetItemNum(id, num)
    if self.resetItemNumCallBack then
        self.resetItemNumCallBack(id, num)
    end
end

function PlayerLevelUpView:LoadModule()
    EventSystem.AddEvent("CardDetailModel_AddExp", self, self.EventAddExp)
    EventSystem.AddEvent("CardDetailModel_UpdateLevelUp", self, self.EventLevelUp)
    EventSystem.AddEvent("ItemsMapModel_ResetItemNum", self, self.EventResetItemNum)
    EventSystem.AddEvent("ToastDestroy", self, self.ToastDestroy)

    self.levelUpStartAudio = audio.GetPlayer("levelUpStart")
    self.levelUpEndAudio = audio.GetPlayer("levelUpEnd")
    self.levelUpRotationAudio = audio.GetPlayer("levelUpRotation")

    self:SetNewCameraBlur(Camera.main)
end

function PlayerLevelUpView:SetNewCameraBlur(camera)
    assert(camera)
    local rapidBlurEffect = camera.gameObject:GetComponent(RapidBlurEffect)
    if rapidBlurEffect then
        rapidBlurEffect.enabled = false
    end
end

function PlayerLevelUpView:UnloadModule()
    EventSystem.RemoveEvent("CardDetailModel_AddExp", self, self.EventAddExp)
    EventSystem.RemoveEvent("CardDetailModel_UpdateLevelUp", self, self.EventLevelUp)
    EventSystem.RemoveEvent("ItemsMapModel_ResetItemNum", self, self.EventResetItemNum)
    EventSystem.RemoveEvent("ToastDestroy", self, self.ToastDestroy)

    self:DestroyAudio(self.levelUpStartAudio)
    self:DestroyAudio(self.levelUpEndAudio)
    self:DestroyAudio(self.levelUpRotationAudio)
end

function PlayerLevelUpView:onDestroy()
    -- delete tweener
    if self.tweener then
        TweenExtensions.Kill(self.tweener)
    end
    self:UnloadModule()
end

-- animation
function PlayerLevelUpView:ExecuteAddExpAnimation(atEndExp)
    if not self.animateExp then return end

    -- 停掉之前还在执行的coroutine
    if self.aniCor then
        self:StopCoroutine(self.aniCor)
    end

    local atStartExp = self.animateExp

    local startTime = Time.time
    self.aniCor = self:coroutine(function()
        local timer = 0

        local lastLerpPerecnt
        TweenExtensions.PlayForward(self.tweener)
        while timer < 1 do
            timer = timer + Time.unscaledDeltaTime / textAnimationDuration
            timer = math.min(timer, 1)
            local lerpExp = math.floor(math.lerp(atStartExp, atEndExp, timer))
            local lerpLevel = self.cardModel:GetLevelWithExp(lerpExp)
            local lerpPercent = tonumber(lerpExp - self.cardModel:GetExpLimitEx(lerpLevel)) / tonumber(self.cardModel:GetLevelUpExpEx(lerpLevel))
            self:SetExp(lerpLevel, lerpPercent, lerpExp)
            if lastLerpPerecnt and (lerpPercent - lastLerpPerecnt) < 0 then
                self.levelUpRotationAudio.PlayAudio("Assets/CapstonesRes/Game/Audio/UI/CardLevelUp/levelUpRotation.wav", 0.5)
            end
            lastLerpPerecnt = lerpPercent

            coroutine.yield(WaitForEndOfFrame())
        end
        TweenExtensions.Pause[Tweener](self.tweener)
        local backTweener = ShortcutExtensions.DOScale(self.level.transform, textAnimationDefalutScale, textAnimationDuration / 2)
        TweenSettingsExtensions.OnComplete(backTweener, function()  --Lua assist checked flag
            GameObjectHelper.FastSetActive(self.levelLimitObj, true)
            EventSystem.SendEvent("Card_ExpEndChange")
        end)
        self.aniCor = nil
    end)
end

function PlayerLevelUpView:HideParticle()
end

function PlayerLevelUpView:DestroyAudio(audioPlayer)
    if audioPlayer == nil or audioPlayer == clr.null then
        return
    end
    Object.Destroy(audioPlayer.gameObject)
end

function PlayerLevelUpView:POpToast(msg)
    if not self.currentToast then 
        self.currentToast = DialogManager.ShowToast(msg)
    end
end

function PlayerLevelUpView:ToastDestroy()
    self.currentToast = nil
end

return PlayerLevelUpView

local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local Tweening = clr.DG.Tweening
local Tweener = Tweening.Tweener
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local TweenExtensions = Tweening.TweenExtensions
local Ease = Tweening.Ease
local LoopType = Tweening.LoopType
local GreenswardEventActionEffectHelper = {}

local PosY = 20
local ShowTime = 2
function GreenswardEventActionEffectHelper.CreatePingPongExtensions(transform, posY, showTime)
    posY = posY or PosY
    showTime = showTime or ShowTime
    local pingpongTween = ShortcutExtensions.DOAnchorPosY(transform, posY, showTime)
    TweenSettingsExtensions.SetEase(pingpongTween, Ease.InOutQuad)
    TweenSettingsExtensions.SetLoops(pingpongTween, -1, LoopType.Yoyo)
    return pingpongTween
end

local InitalValue = 0.1
local FinalValue = 1
local FadeTime = 1
function GreenswardEventActionEffectHelper.CreateFadeInExtensions(canvasGroup)
    canvasGroup.alpha = InitalValue
    local tween = ShortcutExtensions.DOFade(canvasGroup, FinalValue, FadeTime)
    TweenSettingsExtensions.SetEase(tween, Ease.OutQuad)
    return tween
end

local InitalOutValue = 0.2
local FinalOutValue = 1
local FadeOutTime = 0.5
function GreenswardEventActionEffectHelper.CreateFadeOutExtensions(canvasGroup)
    canvasGroup.alpha = FinalOutValue
    local tween = ShortcutExtensions.DOFade(canvasGroup, InitalOutValue, FadeOutTime)
    TweenSettingsExtensions.SetEase(tween, Ease.InOutQuad)
    return tween
end

function GreenswardEventActionEffectHelper.DestroyExtensions(tween)
    if tween then
        TweenExtensions.Kill(tween)
    end
end

local ShowTime = 0.2
local RepeatTime = 6 -- 2次一个循环
function GreenswardEventActionEffectHelper.BlingExtensions(currentNum, preNum, sequence, actComponent, initColor)
    local dValue = currentNum - preNum
    if preNum ~= 0 and dValue ~= 0 then
        GreenswardEventActionEffectHelper.DestroyExtensions(sequence)
        initColor = initColor or Color.white
        actComponent.color = initColor
        sequence = Tweening.DOTween.Sequence()
        local color = (dValue > 0) and Color.green or Color.red
        local blendInTweener = ShortcutExtensions.DOColor(actComponent, color, ShowTime)
        TweenSettingsExtensions.SetEase(blendInTweener, Ease.InQuad)
        TweenSettingsExtensions.Append(sequence, blendInTweener)
        TweenSettingsExtensions.AppendCallback(sequence, function ()
            local oblendInTweener = ShortcutExtensions.DOColor(actComponent, initColor, ShowTime)
            TweenSettingsExtensions.SetEase(oblendInTweener, Ease.OutQuad)
        end)
        TweenSettingsExtensions.SetLoops(sequence, RepeatTime, Tweening.LoopType.Yoyo)
        return sequence
    end
    return nil
end

function GreenswardEventActionEffectHelper.BlingMoraleEffectExtensions(sequence, actComponent)
    local initColor = Color.black
    local newSequence = GreenswardEventActionEffectHelper.BlingExtensions(1, 2, sequence, actComponent, initColor)
    return newSequence
end

function GreenswardEventActionEffectHelper.CreateSizeMoveExtensions(rectTrans, vec2, moveTime, func)
    local moveOutSizeTweener = ShortcutExtensions.DOSizeDelta(rectTrans, vec2, moveTime, false)
    TweenSettingsExtensions.SetEase(moveOutSizeTweener, Ease.OutCubic)
    TweenSettingsExtensions.OnComplete(moveOutSizeTweener, function ()
        if func then
            func()
        end
    end)
    return moveOutSizeTweener
end

return GreenswardEventActionEffectHelper

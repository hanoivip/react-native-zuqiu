local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local Tweening = clr.DG.Tweening
local Tweener = Tweening.Tweener
local DOTween = Tweening.DOTween
local Sequence = Tweening.Sequence
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease

local DialogAnimation = {}

local appearTimeDuration = 0.2
local disappearAlpha = 0.5

function DialogAnimation.Appear(transform, canvasGroup)
    if transform then
        local tweenerX = ShortcutExtensions.DOScaleX(transform, 0, appearTimeDuration)
        TweenSettingsExtensions.From(tweenerX)
        TweenSettingsExtensions.SetEase(tweenerX, Ease.OutBack)
        local tweenerY = ShortcutExtensions.DOScaleY(transform, 0, appearTimeDuration)
        TweenSettingsExtensions.From(tweenerY)
        TweenSettingsExtensions.SetEase(tweenerY, Ease.OutBack)
    end
    if canvasGroup then
        local tweenerA = ShortcutExtensions.DOFade(canvasGroup, disappearAlpha, appearTimeDuration)
        TweenSettingsExtensions.From(tweenerA)
    end
end

function DialogAnimation.Disappear(transform, canvasGroup, callback)
    local tweenerX = ShortcutExtensions.DOScaleX(transform, 0, appearTimeDuration)
    TweenSettingsExtensions.SetEase(tweenerX, Ease.InBack)
    local tweenerY = ShortcutExtensions.DOScaleY(transform, 0, appearTimeDuration)
    TweenSettingsExtensions.SetEase(tweenerY, Ease.InBack)
    if type(callback) == "function"then
        TweenSettingsExtensions.OnComplete(tweenerX, function()  --Lua assist checked flag
            callback()
        end)
    end
    if canvasGroup then
        ShortcutExtensions.DOFade(canvasGroup, disappearAlpha, appearTimeDuration)
    end
end

local DefaultScaleRatio = 0.97
local StandardScaleRatio = 1
local DestinationScaleRatio = 1.03
function DialogAnimation.AppearWithSlow(transform, canvasGroup)
    if transform then
        local mySequence = DOTween.Sequence()
        transform.localScale = Vector3(DefaultScaleRatio, DefaultScaleRatio, DefaultScaleRatio)
        local scale1 = ShortcutExtensions.DOScale(transform, DestinationScaleRatio, appearTimeDuration)
        TweenSettingsExtensions.Append(mySequence, scale1)
        local scale2 = ShortcutExtensions.DOScale(transform, StandardScaleRatio, appearTimeDuration)
        TweenSettingsExtensions.SetEase(scale2, Ease.OutBack)
        TweenSettingsExtensions.Append(mySequence, scale2)
    end
    if canvasGroup then
        local tweenerA = ShortcutExtensions.DOFade(canvasGroup, disappearAlpha, appearTimeDuration)
        TweenSettingsExtensions.From(tweenerA)
    end
end

local DisappearScaleRatio = 0.9
function DialogAnimation.DisappearWithSlow(transform, canvasGroup, callback)
    local mySequence = DOTween.Sequence()
    transform.localScale = Vector3(StandardScaleRatio, StandardScaleRatio, StandardScaleRatio)
    local scale1 = ShortcutExtensions.DOScale(transform, DestinationScaleRatio, appearTimeDuration / 2)
    TweenSettingsExtensions.Append(mySequence, scale1)
    local scale2 = ShortcutExtensions.DOScale(transform, DisappearScaleRatio, appearTimeDuration / 2)
    TweenSettingsExtensions.SetEase(scale2, Ease.InBack)
    TweenSettingsExtensions.Append(mySequence, scale2)
    if type(callback) == "function" then
        TweenSettingsExtensions.OnComplete(scale2, function()  --Lua assist checked flag
            callback()
        end)
    end
    if canvasGroup then
        ShortcutExtensions.DOFade(canvasGroup, disappearAlpha, appearTimeDuration)
    end
end

return DialogAnimation

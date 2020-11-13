local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Quaternion = UnityEngine.Quaternion
local Tweening = clr.DG.Tweening
local DOTween = Tweening.DOTween
local Tweener = Tweening.Tweener
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CardLineItemView = class(unity.base)

function CardLineItemView:ctor()
    self.connet = self.___ex.connet
    self.moveLine = self.___ex.moveLine
    self.doneEffect = self.___ex.doneEffect
    self.upEffect = self.___ex.upEffect
    self.rightEffect = self.___ex.rightEffect
    self.leftEffect = self.___ex.leftEffect
    self.arrowEffect = self.___ex.arrowEffect
end

function CardLineItemView:InitView(index, equipNum, nextOpenIndex)
    self.index = index
    self.equipNum = equipNum
    self.nextOpenIndex = nextOpenIndex
    if index < nextOpenIndex then 
        self.connet.transform.anchoredPosition = Vector2(-self.connet.transform.rect.width / 2, 0)
        self.connet.transform.localRotation = Quaternion.Euler(0, 0, 90)
    elseif index > nextOpenIndex then 
        self.connet.transform.anchoredPosition = Vector2(self.connet.transform.rect.width / 2, 0)
        self.connet.transform.localRotation = Quaternion.Euler(0, 0, 270)
    end
    GameObjectHelper.FastSetActive(self.connet, not(index == nextOpenIndex))
    GameObjectHelper.FastSetActive(self.moveLine, index == nextOpenIndex)
end

function CardLineItemView:ShowLineEffect()
    local mySequence = DOTween.Sequence()
    self.doneEffect.fillAmount = 0
    self.upEffect.fillAmount = 0
    self.arrowEffect.fillAmount = 0
    self.rightEffect.fillAmount = 0
    self.leftEffect.fillAmount = 0
    TweenSettingsExtensions.AppendInterval(mySequence, 0.35)
    GameObjectHelper.FastSetActive(self.doneEffect.gameObject, true)
    local doneInTweener = ShortcutExtensions.DOFillAmount(self.doneEffect, 1, 0.2)
    TweenSettingsExtensions.Append(mySequence, doneInTweener)
    if self.index < self.nextOpenIndex then 
        GameObjectHelper.FastSetActive(self.rightEffect.gameObject, true)
        local rightInTweener = ShortcutExtensions.DOFillAmount(self.rightEffect, 1, 0.2)
        TweenSettingsExtensions.Append(mySequence, rightInTweener)
    elseif self.index > self.nextOpenIndex then 
        GameObjectHelper.FastSetActive(self.leftEffect.gameObject, true)
        local leftInTweener = ShortcutExtensions.DOFillAmount(self.leftEffect, 1, 0.2)
        TweenSettingsExtensions.Append(mySequence, leftInTweener)
    else
        GameObjectHelper.FastSetActive(self.upEffect.gameObject, true)
        local upInTweener = ShortcutExtensions.DOFillAmount(self.upEffect, 1, 0.2)
        TweenSettingsExtensions.Append(mySequence, upInTweener)
        GameObjectHelper.FastSetActive(self.arrowEffect.gameObject, true)
        local arrowInTweener = ShortcutExtensions.DOFillAmount(self.arrowEffect, 1, 0.2)
        TweenSettingsExtensions.Append(mySequence, arrowInTweener)
    end
end

function CardLineItemView:DisableLineEffect()
    GameObjectHelper.FastSetActive(self.doneEffect.gameObject, false)
    GameObjectHelper.FastSetActive(self.upEffect.gameObject, false)
    GameObjectHelper.FastSetActive(self.arrowEffect.gameObject, false)
    GameObjectHelper.FastSetActive(self.rightEffect.gameObject, false)
    GameObjectHelper.FastSetActive(self.leftEffect.gameObject, false)
end

return CardLineItemView
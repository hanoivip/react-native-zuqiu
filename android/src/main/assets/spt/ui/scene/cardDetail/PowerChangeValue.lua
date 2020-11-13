local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Tweening = clr.DG.Tweening
local TweenExtensions = Tweening.TweenExtensions
local Tweener = Tweening.Tweener
local Sequence = Tweening.Sequence
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease
local UISoundManager = require("ui.control.manager.UISoundManager")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PowerChangeValue = class(unity.base)

-- 距离屏幕中心点移动的距离
local MoveDistance = 100

function PowerChangeValue:ctor()
    self.content = self.___ex.content
    self.contentCanvasGroup = self.___ex.contentCanvasGroup
    self.valueText = self.___ex.valueText
    self.prePower = nil
end

function PowerChangeValue:InitPower(power)
    if self.prePower and self.prePower ~= power then 
        local changeValue = power - self.prePower
        local symbol = changeValue < 0 and '' or '+'
        self.valueText.text = symbol .. changeValue
        GameObjectHelper.FastSetActive(self.gameObject, true)
        self.transform.anchoredPosition = Vector2(self.transform.anchoredPosition.x, 0)
        self.contentCanvasGroup.alpha = 1
        self:PlayInAnim()
    else
        GameObjectHelper.FastSetActive(self.gameObject, false)
    end
    self.prePower = power
end

function PowerChangeValue:InitView(value)
    self.valueText.text = value
    self:PlayInAnim()
end

local MoveInTime = 0.3
function PowerChangeValue:PlayInAnim()
    local fadeInTweener = ShortcutExtensions.DOFade(self.contentCanvasGroup, 0, MoveInTime)
    TweenSettingsExtensions.From(fadeInTweener)
    TweenSettingsExtensions.SetEase(fadeInTweener, Ease.OutCubic)

    local moveInTweener = ShortcutExtensions.DOAnchorPosY(self.content, -MoveDistance, MoveInTime)
    TweenSettingsExtensions.From(moveInTweener)
    TweenSettingsExtensions.SetEase(moveInTweener, Ease.OutCubic)
    TweenSettingsExtensions.OnComplete(moveInTweener, function ()  --Lua assist checked flag
        self:PlayOutAnim()
    end)
end

local MoveOutTime = 0.3
local waitTime = 1.5
function PowerChangeValue:PlayOutAnim()
    local fadeOutTweener = ShortcutExtensions.DOFade(self.contentCanvasGroup, 0, MoveOutTime)
    TweenSettingsExtensions.SetDelay(fadeOutTweener, waitTime)
    TweenSettingsExtensions.SetEase(fadeOutTweener, Ease.OutCubic)

    local moveOutTweener = ShortcutExtensions.DOAnchorPosY(self.content, MoveDistance, MoveOutTime)
    TweenSettingsExtensions.SetDelay(moveOutTweener, waitTime)
    TweenSettingsExtensions.SetEase(moveOutTweener, Ease.OutCubic)
end

function PowerChangeValue:CardDetailChange()
    self.prePower = nil
end

function PowerChangeValue:EnterScene()
    EventSystem.AddEvent("CardDetail_Change_Card", self, self.CardDetailChange)
end

function PowerChangeValue:ExitScene()
    EventSystem.RemoveEvent("CardDetail_Change_Card", self, self.CardDetailChange)
    self.prePower = nil
end

return PowerChangeValue

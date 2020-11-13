local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local Image = UI.Image
local RectTransform = UnityEngine.RectTransform
local Screen = UnityEngine.Screen
local Tweening = clr.DG.Tweening
local DOTween = Tweening.DOTween
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease

local DeployedPanel = class(unity.base)

function DeployedPanel:ctor()
    self.rect = nil
    self.orignalPosition = nil
    self.stayTime = 3
end

function DeployedPanel:awake()
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.orignalPosition = self.rect.localPosition
end

function DeployedPanel:Display()
    self.rect.localPosition = self.orignalPosition
    self:MoveInOut()
end

function DeployedPanel:MoveInOut()
    local tweenerMoveIn = ShortcutExtensions.DOMoveX(self.transform, -74, 0.4, false)
    TweenSettingsExtensions.From(tweenerMoveIn)
    TweenSettingsExtensions.SetEase(tweenerMoveIn, Ease.OutCubic)

    local tweenerMoveOut = ShortcutExtensions.DOMoveX(self.transform, -74, 0.4, false)
    TweenSettingsExtensions.SetDelay(tweenerMoveOut, self.stayTime)
    TweenSettingsExtensions.SetEase(tweenerMoveOut, Ease.OutCubic)

    local mySequence = DOTween.Sequence()
    TweenSettingsExtensions.Append(mySequence, tweenerMoveIn)
    TweenSettingsExtensions.Append(mySequence, tweenerMoveOut)
    TweenSettingsExtensions.AppendCallback(mySequence, function ()
        self:EndAnimation()
    end)
end

function DeployedPanel:EndAnimation()
    self.rect.localPosition = self.orignalPosition
    self.gameObject:SetActive(false)
end

return DeployedPanel

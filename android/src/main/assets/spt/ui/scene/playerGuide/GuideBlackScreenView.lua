local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local Tweening = clr.DG.Tweening
local Tweener = Tweening.Tweener
local DOTween = Tweening.DOTween
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local TweenExtensions = Tweening.TweenExtensions

local GuideBlackScreenView = class(unity.base)

function GuideBlackScreenView:ctor()
    self.boardCanvasGroup = self.___ex.boardCanvasGroup
    self.dialog = self.___ex.dialog
    self.btnContinue = self.___ex.btnContinue
end

function GuideBlackScreenView:start()
    if self.btnContinue then
        self.btnContinue:regOnButtonClick(function()
            self:OnContinue()
        end)
    end
    self.boardCanvasGroup.alpha = 0.3
end

function GuideBlackScreenView:InitView()
    local playerInfoModel = PlayerInfoModel.new()
    self.dialog.text = lang.trans(GuideManager.guideModel:GetDialogText(GuideManager.guideModel:GetCurStep()), playerInfoModel:GetName())

    self.fadeIn = ShortcutExtensions.DOFade(self.boardCanvasGroup, 1, 1.5)
    TweenSettingsExtensions.OnComplete(self.fadeIn, function()  --Lua assist checked flag
        self.fadeOut = ShortcutExtensions.DOFade(self.boardCanvasGroup, 0.3, 1.5)
        TweenSettingsExtensions.OnComplete(self.fadeOut, function()  --Lua assist checked flag
            GuideManager.Show(GuideManager.moduleInstance)
        end)
    end)
end

function GuideBlackScreenView:OnContinue()
    self:killTweens()
    self.fadeOutQuick = ShortcutExtensions.DOFade(self.boardCanvasGroup, 0, 0.5)
    TweenSettingsExtensions.OnComplete(self.fadeOutQuick, function()  --Lua assist checked flag
        GuideManager.Show(GuideManager.moduleInstance)
    end)
end

function GuideBlackScreenView:killTweens()
    if self.fadeIn then
        TweenExtensions.Kill(self.fadeIn)
    end
    if self.fadeOut then
        TweenExtensions.Kill(self.fadeOut)
    end
end

function GuideBlackScreenView:onDestroy()
    self:killTweens()
    if self.fadeOutQuick then
        TweenExtensions.Kill(self.fadeOutQuick)
    end
end

return GuideBlackScreenView

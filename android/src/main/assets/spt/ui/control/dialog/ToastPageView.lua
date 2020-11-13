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

local ToastPageView = class(unity.base)

-- 距离屏幕中心点移动的距离
local MoveDistance = 100

local LastToast = {
    spt = nil,
    tweeners = {},
}

function ToastPageView.MoveAwayLastToast()
    if LastToast.spt and LastToast.spt ~= clr.null then
        if LastToast.spt.content.anchoredPosition.y <= 0 then
            for k, v in ipairs(LastToast.tweeners) do
                TweenExtensions.Kill(k)
            end
            LastToast.spt:PlayOutAnimWithoutDelay()            
        end
    end
end

function ToastPageView:ctor()
    -- 内容框
    self.content = self.___ex.content
    self.contentCanvasGroup = self.___ex.contentCanvasGroup
    -- 消息文本
    self.toastText = self.___ex.toastText
    -- 音效
    self.snd = self.___ex.snd
    -- 要显示的消息
    self.msg = nil

    ToastPageView.MoveAwayLastToast()
    LastToast = {
        spt = self,
        tweeners = {},
    }
end

-- @param params
-- {
--     -- 初始位置
--       initPosition = {x, y}
--     },
-- }

function ToastPageView:InitView(msg, params)
    self.msg = msg
    self.params = params
    
    self:BuildPage()
end

function ToastPageView:BuildToastConfig()
    if type(self.params) == 'table' then 
        local initPosition = self.params.initPosition
        if initPosition then 
            self.transform.anchoredPosition = Vector2(initPosition.x, initPosition.y)
        end
    end
end

function ToastPageView:start()
    UISoundManager.play(self.snd)
    self:PlayInAnim()
    self:BuildToastConfig()
end

function ToastPageView:BuildPage()
    self.toastText.text = self.msg
end

function ToastPageView:PlayInAnim()
    local fadeInTweener = ShortcutExtensions.DOFade(self.contentCanvasGroup, 0, 0.3)
    TweenSettingsExtensions.From(fadeInTweener)
    TweenSettingsExtensions.SetEase(fadeInTweener, Ease.OutCubic)
    TweenSettingsExtensions.OnComplete(fadeInTweener, function ()  --Lua assist checked flag
        LastToast.tweeners[fadeInTweener] = nil
    end)
    LastToast.tweeners[fadeInTweener] = true

    local moveInTweener = ShortcutExtensions.DOAnchorPosY(self.content, -MoveDistance, 0.3)
    TweenSettingsExtensions.From(moveInTweener)
    TweenSettingsExtensions.SetEase(moveInTweener, Ease.OutCubic)
    TweenSettingsExtensions.OnComplete(moveInTweener, function ()  --Lua assist checked flag
        LastToast.tweeners[moveInTweener] = nil
        self:PlayOutAnim()
    end)
    LastToast.tweeners[moveInTweener] = true
end

function ToastPageView:PlayOutAnimWithoutDelay()
    local fadeOutTweener = ShortcutExtensions.DOFade(self.contentCanvasGroup, 0, 0.3)
    TweenSettingsExtensions.SetEase(fadeOutTweener, Ease.OutCubic)
    TweenSettingsExtensions.OnComplete(fadeOutTweener, function ()  --Lua assist checked flag
        self:Destroy()
    end)

    local moveOutTweener = ShortcutExtensions.DOAnchorPosY(self.content, MoveDistance, 0.3)
    TweenSettingsExtensions.SetEase(moveOutTweener, Ease.OutCubic)
    TweenSettingsExtensions.OnComplete(moveOutTweener, function ()  --Lua assist checked flag
        self:Destroy()
    end)
end

function ToastPageView:PlayOutAnim()
    local fadeOutTweener = ShortcutExtensions.DOFade(self.contentCanvasGroup, 0, 0.3)
    TweenSettingsExtensions.SetDelay(fadeOutTweener, 1)
    TweenSettingsExtensions.SetEase(fadeOutTweener, Ease.OutCubic)
    TweenSettingsExtensions.OnComplete(fadeOutTweener, function ()  --Lua assist checked flag
        LastToast.tweeners[fadeOutTweener] = nil
        self:Destroy()
    end)
    LastToast.tweeners[fadeOutTweener] = true

    local moveOutTweener = ShortcutExtensions.DOAnchorPosY(self.content, MoveDistance, 0.3)
    TweenSettingsExtensions.SetDelay(moveOutTweener, 1)
    TweenSettingsExtensions.SetEase(moveOutTweener, Ease.OutCubic)
    TweenSettingsExtensions.OnComplete(moveOutTweener, function ()  --Lua assist checked flag
        LastToast.tweeners[moveOutTweener] = nil
        self:Destroy()
    end)
    LastToast.tweeners[moveOutTweener] = true
end

function ToastPageView:Destroy()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
        EventSystem.SendEvent("ToastDestroy")
    end
end

return ToastPageView

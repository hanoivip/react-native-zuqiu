local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Tweening = clr.DG.Tweening
local TweenExtensions = Tweening.TweenExtensions
local Tweener = Tweening.Tweener
local DOTween = Tweening.DOTween
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local ThanksListView = class(unity.base)

function ThanksListView:ctor()
	self.area = self.___ex.area
	self.contentRect = self.___ex.contentRect
	self.verticalLayout = self.___ex.verticalLayout
	self.desc = self.___ex.desc
	self.title = self.___ex.title
	self.canvasGroup = self.___ex.canvasGroup
	self.close = self.___ex.close
	self.tweenersMap = {}
end

function ThanksListView:InitView(title, desc)
	self.title.text = title
	self.desc.text = desc
end

function ThanksListView:start()
	DialogAnimation.Appear(self.transform, self.canvasGroup)
    self.close:regOnButtonClick(function()
        self:Close()
    end)

	self:MoveEffect()
end

local minTime = 10
local DelayTime = 2
function ThanksListView:MoveEffect()
	self:coroutine(function() 
		coroutine.yield()
		local areaH = self.area.rect.height
		self.contentRect.anchoredPosition = Vector2(0, 0)
		local offsetY = self.verticalLayout.preferredHeight
		if offsetY > areaH then 
			local costTime = math.round(offsetY / areaH) + minTime
			self:DOAnchorPosY(areaH, offsetY, costTime)
		end
	end)
end

function ThanksListView:DOAnchorPosY(areaH, offsetY, costTime)
	self:CleanTween()
	local moveInTweener = ShortcutExtensions.DOAnchorPosY(self.contentRect, offsetY, costTime)
	TweenSettingsExtensions.SetEase(moveInTweener, Ease.Linear)
	TweenSettingsExtensions.SetDelay(moveInTweener, DelayTime)
	TweenSettingsExtensions.OnComplete(moveInTweener, function()
		self.contentRect.anchoredPosition = Vector2(0, - areaH)
		self:DOAnchorPosY(areaH, offsetY, costTime)
	end )
	TweenSettingsExtensions.SetAutoKill(moveInTweener, false)
	self.tweenersMap['moveInTweener'] = moveInTweener
end

function ThanksListView:CleanTween()
	for k, v in pairs(self.tweenersMap) do
		if v then 
			TweenExtensions.Kill(v)
		end
	end
end

function ThanksListView:Close()
	self:CleanTween()

    DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

return ThanksListView
local UnityEngine = clr.UnityEngine
local RectTransform = UnityEngine.RectTransform
local CommentaryManager = require("ui.control.manager.CommentaryManager")

local HeroOneOption = class(unity.base)

function HeroOneOption:ctor()
    self.hand = self.___ex.hand
    self.handAnimator = self.___ex.handAnimator
    self.target = nil
    self.dialogId = 0
end

function HeroOneOption:lateUpdate()
    self:FollowTarget()
end

function HeroOneOption:ShowDialog(dialog, targetObject)
    self.dialogId = dialog.dialogId
    self.audioOnDismiss = dialog.audioOnDismiss
    self.target = targetObject:GetComponent(RectTransform)
    self:FollowTarget()
    self.gameObject:SetActive(true)
    self.handAnimator:Play("Base Layer.GuideHandClick", 0)
end

function HeroOneOption:DismissDialog()
    ___demoManager:OnDemoMatchDialogDismiss(self.dialogId)
    if self.audioOnDismiss then
        CommentaryManager.GetInstance():PlayDemoMatchCommentary(self.audioOnDismiss)
    end
    self.gameObject:SetActive(false)
end

function HeroOneOption:FollowTarget()
    self.hand.anchoredPosition = self.target.anchoredPosition
end

return HeroOneOption

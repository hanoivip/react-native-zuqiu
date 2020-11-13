local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local CommentaryManager = require("ui.control.manager.CommentaryManager")

local HeroTwoOptions = class(unity.base)

function HeroTwoOptions:ctor()
    self.option1 = self.___ex.option1
    self.option2 = self.___ex.option2
    self.target1 = nil
    self.target2 = nil
    self.dialogId = 0
    self.duration = 1.5
    self.startTime = nil
end

function HeroTwoOptions:start()
end

function HeroTwoOptions:lateUpdate()
    self:FollowTarget()
    if TimeWrap.GetUnscaledTime() - self.startTime >= self.duration then
        self:DismissDialog()
    end
end

function HeroTwoOptions:ShowDialog(dialog, targetObject1, targetObject2)
    self.dialogId = dialog.dialogId
    self.audioOnShow = dialog.audioOnShow
    if #self.audioOnShow > 0 then
        CommentaryManager.GetInstance():PlayDemoMatchCommentary(self.audioOnShow[1])
    end
    self.target1 = targetObject1:GetComponent(RectTransform)
    self.target2 = targetObject2:GetComponent(RectTransform)
    self:FollowTarget()
    self.gameObject:SetActive(true)
    self.startTime = TimeWrap.GetUnscaledTime()
end

function HeroTwoOptions:DismissDialog()
    ___demoManager:OnDemoMatchDialogDismiss(self.dialogId)
    self.gameObject:SetActive(false)
end

function HeroTwoOptions:FollowTarget()
    self.option1.anchoredPosition = Vector2(self.target1.anchoredPosition.x, self.target1.anchoredPosition.y - 15)
    self.option2.anchoredPosition = Vector2(self.target2.anchoredPosition.x, self.target2.anchoredPosition.y - 15)
end

return HeroTwoOptions

local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local RectTransform = UnityEngine.RectTransform
local CommentaryManager = require("ui.control.manager.CommentaryManager")

local DemoMatchFreeShoot = class(unity.base)

function DemoMatchFreeShoot:ctor()
    self.ballLight = self.___ex.ballLight
    self.dialogId = 0
    self.rect = nil
end

function DemoMatchFreeShoot:WorldToRectPosition(worldPosition)
    if self.rect == nil then
        self.rect = self.gameObject:GetComponent(RectTransform).rect
    end
    local viewPortPos = CameraCtrlWrap.WorldToViewportPoint(worldPosition)
    return Vector2(viewPortPos.x * self.rect.width, viewPortPos.y * self.rect.height)
end

function DemoMatchFreeShoot:ShowDialog(dialog)
    self.dialogId = dialog.dialogId
    self.audioOnDismiss = dialog.audioOnDismiss
    local ballPos = BallActionExecutorWrap.GetBallPosition()
    local screenBallPos = self:WorldToRectPosition(ballPos)
    self.ballLight.anchoredPosition = screenBallPos
    self.gameObject:SetActive(true)
end

function DemoMatchFreeShoot:DismissDialog()
    if self.audioOnDismiss then
        CommentaryManager.GetInstance():PlayDemoMatchCommentary(self.audioOnDismiss)
    end
    ___demoManager:OnDemoMatchDialogDismiss(self.dialogId)
    self.gameObject:SetActive(false)
end

return DemoMatchFreeShoot

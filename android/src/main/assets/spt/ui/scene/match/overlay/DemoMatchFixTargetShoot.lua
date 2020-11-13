local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local Quaternion = UnityEngine.Quaternion
local RectTransform = UnityEngine.RectTransform

local CommentaryManager = require("ui.control.manager.CommentaryManager")
local ActionLayerUtils = require("coregame.actionlayer.ActionLayerUtils")
local ActionLayerConfig = require("coregame.actionlayer.ActionLayerConfig")
local vector2 = require("emulator.libs.vector_lua")
local DemoMatchFixTargetShoot = class(unity.base)

local Phase1Duration = 0.68
local Phase2Duration = 1.32
local Phase3Duration = 0.75

function DemoMatchFixTargetShoot:ctor()
    self.ballLight = self.___ex.ballLight
    self.target = self.___ex.target
    self.hand = self.___ex.hand
    self.handAnimator = self.___ex.handAnimator
    self.line = self.___ex.line
    self.ballScreenPos = nil
    self.targetScreenPos = nil
    self.shootDirection = nil
    self.dialogId = 0
    self.rect = nil
    self.startTime = nil
    self.isFingerDown = nil
end

function DemoMatchFixTargetShoot:update()
    self:MoveFinger(TimeWrap.GetUnscaledTime())
end

function DemoMatchFixTargetShoot:GetTargetWorldPosition(ballPosition)
    local targetWorldPos = {}
    targetWorldPos.z = ballPosition.z > 0 and ActionLayerConfig.GoalPositionZ or -ActionLayerConfig.GoalPositionZ
    if self.dialogId == 10 then
        targetWorldPos.x = ballPosition.x > 0 and ActionLayerConfig.GoalWidth - 1 or -ActionLayerConfig.GoalWidth + 1
        targetWorldPos.y = 1
    else
        targetWorldPos.x = ballPosition.x > 0 and -ActionLayerConfig.GoalWidth + 1.2 or ActionLayerConfig.GoalWidth - 1.2
        targetWorldPos.y = ActionLayerConfig.GoalHeight - 1
    end
    return targetWorldPos
end

function DemoMatchFixTargetShoot:WorldToRectPosition(worldPosition)
    if self.rect == nil then
        self.rect = self.gameObject:GetComponent(RectTransform).rect
    end
    local viewPortPos = CameraCtrlWrap.WorldToViewportPoint(worldPosition)
    return Vector2(viewPortPos.x * self.rect.width, viewPortPos.y * self.rect.height)
end

function DemoMatchFixTargetShoot:ShowDialog(dialog)
    self.dialogId = dialog.dialogId
    self.audioOnDismiss = dialog.audioOnDismiss
    self.startTime = TimeWrap.GetUnscaledTime()
    self.isFingerDown = false
    self.gameObject:SetActive(true)

    local ballPos = BallActionExecutorWrap.GetBallPosition()
    self.ballScreenPos = self:WorldToRectPosition(ballPos)
    self.ballLight.anchoredPosition = self.ballScreenPos
    self.hand.anchoredPosition = self.ballScreenPos

    local targetPos = self:GetTargetWorldPosition(ballPos)
    self.targetScreenPos = self:WorldToRectPosition(targetPos)
    self.target.anchoredPosition = self.targetScreenPos

    self.shootDirection = Vector2(self.targetScreenPos.x - self.ballScreenPos.x, self.targetScreenPos.y - self.ballScreenPos.y)

    local distance = vector2.dist(self.ballScreenPos, self.targetScreenPos)
    local lineScreenPos = Vector2((self.ballScreenPos.x + self.targetScreenPos.x) / 2, (self.ballScreenPos.y + self.targetScreenPos.y) / 2)
    self.line.anchoredPosition = lineScreenPos
    self.line.sizeDelta = Vector2(self.line.rect.width, distance - 80)
    self.line.rotation = Quaternion.FromToRotation(Vector3.up, Vector3(self.targetScreenPos.x - self.ballScreenPos.x, self.targetScreenPos.y - self.ballScreenPos.y, 0))
end

function DemoMatchFixTargetShoot:DismissDialog()
    if self.audioOnDismiss then
        CommentaryManager.GetInstance():PlayDemoMatchCommentary(self.audioOnDismiss)
    end
    ___demoManager:OnDemoMatchDialogDismiss(self.dialogId)
    self.gameObject:SetActive(false)
end

function DemoMatchFixTargetShoot:IsTouchShootValid(shootEndPosition)
    if ActionLayerUtils.IsInGoal(shootEndPosition.x, shootEndPosition.y) == true then
        local shootEndScreenPos = self:WorldToRectPosition(shootEndPosition)
        return vector2.sqrdist(shootEndScreenPos, self.target.anchoredPosition) < 1600
    end
    return false
end

function DemoMatchFixTargetShoot:PlayFingerDownAnim()
    self.handAnimator:Play("Base Layer.GuideHandDown", 0)
    self.isFingerDown = true
end

function DemoMatchFixTargetShoot:PlayFingerUpAnim()
    self.handAnimator:Play("Base Layer.GuideHandUp", 0)
    self.isFingerDown = false
end

function DemoMatchFixTargetShoot:MoveFinger(currentTime)
    if currentTime <= self.startTime + Phase1Duration then
        if self.isFingerDown == false then
            self:PlayFingerDownAnim()
        end
        self.hand.anchoredPosition = self.ballScreenPos
    elseif currentTime < self.startTime + Phase1Duration + Phase2Duration then
        local percent = (currentTime - Phase1Duration - self.startTime) / Phase2Duration
        local lerpPos = Vector2(self.ballScreenPos.x + self.shootDirection.x * percent, self.ballScreenPos.y + self.shootDirection.y * percent)
        self.hand.anchoredPosition = lerpPos
    elseif currentTime < self.startTime + Phase1Duration + Phase2Duration + Phase3Duration then
        if self.isFingerDown == true then
            self:PlayFingerUpAnim()
        end
        self.hand.anchoredPosition = self.targetScreenPos
    else
        self.startTime = currentTime
        self.isFingerDown = false
    end
end

return DemoMatchFixTargetShoot

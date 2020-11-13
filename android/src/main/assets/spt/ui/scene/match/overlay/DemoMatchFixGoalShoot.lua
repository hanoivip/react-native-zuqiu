local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3

local ActionLayerConfig = require("coregame.actionlayer.ActionLayerConfig")
local DemoMatchFixGoalShoot = class(unity.base)

function DemoMatchFixGoalShoot:ctor()
    self.ballLight = self.___ex.ballLight
    self.target = self.___ex.target
    self.dialogId = 0
    self.rect = nil
end

function DemoMatchFixGoalShoot:GetTargetDoorPositionAndSize(ballPosition)
    local lowerLeft = {}
    lowerLeft.z = ballPosition.z > 0 and ActionLayerConfig.GoalPositionZ or -ActionLayerConfig.GoalPositionZ
    lowerLeft.x = ballPosition.z > 0 and -ActionLayerConfig.GoalWidth or ActionLayerConfig.GoalWidth
    lowerLeft.y = 0
    local lowerleftScreen = self:WorldToRectPosition(lowerLeft)

    local upperRight = {}
    upperRight.z = ballPosition.z > 0 and ActionLayerConfig.GoalPositionZ or -ActionLayerConfig.GoalPositionZ
    upperRight.x = ballPosition.z > 0 and ActionLayerConfig.GoalWidth or -ActionLayerConfig.GoalWidth
    upperRight.y = ActionLayerConfig.GoalHeight
    local upperRightScreen = self:WorldToRectPosition(upperRight)

    local size = {}
    size.x = math.abs(upperRightScreen.x - lowerleftScreen.x)
    size.y = upperRightScreen.y - lowerleftScreen.y

    return Vector2((lowerleftScreen.x + upperRightScreen.x) / 2, (lowerleftScreen.y + upperRightScreen.y) / 2), Vector2(size.x, size.y)
end

function DemoMatchFixGoalShoot:WorldToRectPosition(worldPosition)
    if self.rect == nil then
        self.rect = self.gameObject:GetComponent(RectTransform).rect
    end
    local viewPortPos = CameraCtrlWrap.WorldToViewportPoint(worldPosition)
    return Vector2(viewPortPos.x * self.rect.width, viewPortPos.y * self.rect.height)
end

function DemoMatchFixGoalShoot:ShowDialog(dialogId)
    self.dialogId = dialogId
    self.gameObject:SetActive(true)

    local ballPos = BallActionExecutorWrap.GetBallPosition()
    local ballScreenPos = self:WorldToRectPosition(ballPos)
    self.ballLight.anchoredPosition = ballScreenPos

    local doorScreenPos, doorSize = self:GetTargetDoorPositionAndSize(ballPos)
    self.target.anchoredPosition = doorScreenPos
    self.target.sizeDelta = doorSize
end

function DemoMatchFixGoalShoot:DismissDialog()
    ___demoManager:OnDemoMatchDialogDismiss(self.dialogId)
    self.gameObject:SetActive(false)
end

return DemoMatchFixGoalShoot

local MatchInfoModel = require("ui.models.MatchInfoModel")
local EnumType = require("coregame.EnumType")
local MatchEventType = EnumType.MatchEventType
local BroadcastSpot = EnumType.BroadcastSpot
local BallActionType = EnumType.BallActionType
local ShootResult = EnumType.ShootResult
local Deg2Rad = math.deg2Rad
local Rad2Deg = math.rad2Deg
local Vector2 = Vector2Lua
local Vector3 = Vector3Lua
local Quaternion = QuaternionLua
local Camera = clr.UnityEngine.Camera

local CameraCtrlCore = class(unity.base)

function CameraCtrlCore:ctor()
    ___cameraCtrlCore = self

    self.parameters = {
        defaultFieldOfView = 18,
        baseFieldOfView = 45,
        gate1 = Vector3(0, 1.4, -55),
        gate2 = Vector3(0, 1.4, 55),
        penaltyKickPosition1 = Vector3(0, 0, -44),
        penaltyKickPosition2 = Vector3(0, 0, 44),
        beamHeight = 2.44,

        mainBroadcastSpot = Vector3(-50, 14, 0),
        leftCelebrateCameraPos = Vector3(0, 10.7, 13),
        rightCelebrateCameraPos = Vector3(0, 10.7, -13),
        celebrateTime = 6,
        depressTime = 3,

        maxZOffset = 25,
        responseZOffset = 10,
        standardXDistance = 55,
        xDistanceTolerance = 2,
        minXValue = -65,
        lookAtMinXValue = -23,
        lookAtMaxXValue = 23,

        cameraDefollowDistanceBehind = 20,
        cameraDefollowHeightBehind = 10,
        cameraFollowMoveDuration = 1,
        cameraDefollowMoveDuration = 1,
    }

    self.ballSegNumFromKickOff = 0
    self.shootTargetGate = nil
    self.defaultHorizontalFOV = 0
    self.broadcastSpot = nil
    self.matchInfoModel = MatchInfoModel.GetInstance()

    self.usedPlayBackCameraParameterIndices = { }
end

function CameraCtrlCore:start()
    self:calculateDefaultHorizontalFOV()
    if not self.matchInfoModel:IsDemoMatch() then
        self:setFirstKickOffCameraMoveActions()
    end

    self:forceSwitchCamera()
end

local firstKickOffCameraMoveActions = {
    {
        {
            originPos = Vector3(0, 70, 0),
            destPos = Vector3(0, 70, 0),
            originLookAtPos = Vector3(0, 0, 0),
            destLookAtPos = Vector3(0, 0, 0),
            duration = 1,
            rotationSpeed = 5,
            fov = 25,
        },
        {
            originPos = Vector3(-41, 6.34, 0),
            destPos = Vector3(-41, 6.34, 0),
            originLookAtPos = Vector3(3, 0, 0),
            destLookAtPos = Vector3(3, 0, 0),
            duration = 1,
            rotationSpeed = 0,
            fov = 5,
        },
    },
    {
        {
            originPos = Vector3(-41, 6.34, 0),
            destPos = Vector3(-41, 6.34, 0),
            originLookAtPos = Vector3(3, 0, 0),
            destLookAtPos = Vector3(3, 0, 0),
            duration = 0.5,
            rotationSpeed = 0,
            fov = 5,
        },
    },
    {
        {
            originPos = Vector3(-75, 20, 0),
            destPos = Vector3(-55, 12.5, 0),
            originLookAtPos = Vector3(0, 0, 0),
            destLookAtPos = Vector3(0, 0, 0),
            duration = 0.5,
            rotationSpeed = 0,
            fov = 25,
        },
    },
}

local function randomSelect(array)
    local randomNumber = math.random()
    local avgProb = 1 / #array
    local probSum = 0
    for _, v in ipairs(array) do
        probSum = probSum + avgProb
        if math.cmpf(randomNumber, probSum) <= 0 then
            return v
        end
    end
end

function CameraCtrlCore:setFirstKickOffCameraMoveActions()
    local firstKickOffCameraMoveParameters = randomSelect(firstKickOffCameraMoveActions)
    for _, cameraMoveParameter in ipairs(firstKickOffCameraMoveParameters) do
        CameraCtrlWrap.EnqueueCameraMoveAction(cameraMoveParameter.originPos, cameraMoveParameter.destPos,
            cameraMoveParameter.originLookAtPos, cameraMoveParameter.destLookAtPos, cameraMoveParameter.duration,
            cameraMoveParameter.rotationSpeed, cameraMoveParameter.fov)
    end
end

function CameraCtrlCore:calculateDefaultHorizontalFOV()
    local radAngle = self.parameters.defaultFieldOfView * Deg2Rad
    local radHFOV = 2 * math.atan(math.tan(radAngle / 2) * CameraCtrlWrap.GetCameraAspect())
    self.defaultHorizontalFOV = Rad2Deg * radHFOV
end

function CameraCtrlCore:forceSwitchCamera()
    CameraCtrlWrap.SetForceSwitchCamera(true)
end

function CameraCtrlCore:clearUsedPlayBackCameraParameterIndices()
    self.usedPlayBackCameraParameterIndices = { }
end

--Contrarotate vector v in X-Z plane
local function rotateXZ(v, degreeAngle)
    local radiusAngle = degreeAngle * Deg2Rad

    local ca = math.cos(radiusAngle)
    local sa = math.sin(radiusAngle)

    return Vector3(v.x * ca - v.z * sa, v.y, v.x * sa + v.z * ca)
end

--Contrarotate vector v in Y-X plane
local function rotateYX(v, degreeAngle)
    local radiusAngle = degreeAngle * Deg2Rad

    local ca = math.cos(radiusAngle)
    local sa = math.sin(radiusAngle)

    return Vector3(v.y * sa + v.x * ca, v.y * ca - v.x * sa, v.z)
end

function CameraCtrlCore:setCameraByMatchEvent(eventType, ballOwner)
    if self.matchInfoModel:IsDemoMatch() then
        return
    end
    self:resetCameraStates()
    local ballOwnerPos = GameHubWrap.GetPlayerPosition(ballOwner)
    local ballOwnerForward = GameHubWrap.GetPlayerForward(ballOwner)
    if eventType == MatchEventType.NontimedKickOff or eventType == MatchEventType.TimedKickOff then
        self:setKickOffCamera()
        return
    elseif eventType == MatchEventType.PenaltyKick then
        self:setPenaltyKickCamera()
        return
    elseif eventType == MatchEventType.CenterDirectFreeKick or eventType == MatchEventType.WingDirectFreeKick then
        self:setDirectFreeKickCamera(eventType, ballOwnerPos)
        return
    elseif eventType == MatchEventType.GoalKick then
        self:setGoalKickCamera()
        return
    elseif eventType == MatchEventType.IndirectFreeKick or eventType == MatchEventType.GoalKick then
        self:setIndirectFreeKickCamera()
        return
    elseif eventType == MatchEventType.ThrowIn then
        self:setThrowInCamera()
        return
    elseif eventType == MatchEventType.CornerKick then
        self:setCornerKickCamera(ballOwnerPos, ballOwnerForward)
        return
    elseif eventType == MatchEventType.PenaltyShootOutKick then
        self:setPenaltyShootOutKickCamera()
        return
    --elseif
        --eventType == MatchEventType.PrepareToKickOff or eventType == MatchEventType.NormalPlayOn or eventType == MatchEventType.Substitution
        --or eventType == MatchEventType.PenaltyShootOut or eventType == MatchEventType.GameOver
    end
end

function CameraCtrlCore:setDemoMatchCameraByMatchEvent(eventType, ballOwner)
    self:resetCameraStates()
    if eventType == MatchEventType.PenaltyKick then
        self:setPenaltyKickCamera()
        return
    elseif eventType == MatchEventType.CenterDirectFreeKick then
        self:setDirectFreeKickCamera(eventType, GameHubWrap.GetPlayerPosition(ballOwner))
        return
    elseif eventType == MatchEventType.CornerKick then
        self:setCornerKickCamera(GameHubWrap.GetPlayerPosition(ballOwner), GameHubWrap.GetPlayerForward(ballOwner))
        return
    else
        self.ballSegNumFromKickOff = 100
        self:setBroadcast(BroadcastSpot.MainSpot)
        self:setPosAndLookAt(self.parameters.mainBroadcastSpot, GameHubWrap.GetPlayerPosition(ballOwner))
    end
end

function CameraCtrlCore:setPlayBackCameraByMatchEvent(eventType, ballOwner)
    self:resetCameraStates()
    local ballOwnerPos = GameHubWrap.GetPlayerPosition(ballOwner)
    local ballOwnerForward = GameHubWrap.GetPlayerForward(ballOwner)
    if eventType == MatchEventType.PenaltyKick then
        self:setPlayBackPenaltyKickCamera()
        return
    elseif eventType == MatchEventType.PenaltyShootOutKick then
        self:setPlayBackPenaltyShootOutKickCamera()
        return
    elseif eventType == MatchEventType.CenterDirectFreeKick then
        self:setPlayBackCenterDirectFreeKickCamera(eventType, ballOwnerPos)
        return
    elseif eventType == MatchEventType.WingDirectFreeKick then
        self:setPlayBackWingDirectFreeKickCamera(eventType, ballOwnerPos)
        return
    elseif eventType == MatchEventType.GoalKick then
        self:setPlayBackGoalKickCamera()
        return
    elseif eventType == MatchEventType.IndirectFreeKick or eventType == MatchEventType.GoalKick then
        self:setIndirectFreeKickCamera()
        return
    elseif eventType == MatchEventType.ThrowIn then
        self:setThrowInCamera()
        return
    elseif eventType == MatchEventType.CornerKick then
        self:setPlayBackCornerKickCamera(ballOwnerPos, ballOwnerForward)
        return
    end
end

function CameraCtrlCore:resetCameraStates()
    CameraCtrlWrap.SetInPositionMove(false)
    CameraCtrlWrap.SetInLookAtMove(false)
    CameraCtrlWrap.SetIsCameraFollowPlayer(false)
    CameraCtrlWrap.SetIsCameraDefollowPlayer(false)
    CameraCtrlWrap.SetStartTime(TimeWrap.GetUnscaledTime())
    CameraCtrlWrap.SetPositionVelocity(Vector3.zero)
    CameraCtrlWrap.SetLookAtVelocity(Vector3.zero)
    CameraCtrlWrap.SetRotationSpeed(0)
    CameraCtrlWrap.SetCameraRotation(Quaternion(0, 0, 0, 0))
    CameraCtrlWrap.ClearCameraMoveAction()
    CameraCtrlWrap.EndShakeCamera()
    self:forceSwitchCamera()
    self.isInManualOperateView = false
end

function CameraCtrlCore:setPosAndLookAt(position, lookAt)
    self:setPosition(position)
    self:setLookAt(lookAt)
end

function CameraCtrlCore:setPosition(position)
    CameraCtrlWrap.SetCameraContainerPosition(position)
end

function CameraCtrlCore:setLookAt(lookAt)
    CameraCtrlWrap.SetLookAt(lookAt)
    CameraCtrlWrap.SetCameraContainerLookAt(lookAt)
end

function CameraCtrlCore:setKickOffCamera()
    self.ballSegNumFromKickOff = 0
    self:setBroadcast(BroadcastSpot.MainSpot)
    CameraCtrlWrap.EnqueueCameraMoveAction(Vector3(-80, 20, 0), Vector3(-80, 20, 0), Vector3(0, 0, 0), Vector3(0, 0, 0), 5, 0, self.parameters.defaultFieldOfView)
end

function CameraCtrlCore:setLookAtSpectatorCamera()
    self.ballSegNumFromKickOff = 0
    self:setBroadcast(BroadcastSpot.MainSpot)
    CameraCtrlWrap.EnqueueCameraMoveAction(Vector3(-80, 20, 0), Vector3(-80, 20, 0), Vector3(0, 20, 0), Vector3(0, 20, 0), 5, 0, self.parameters.defaultFieldOfView)
end

function CameraCtrlCore:setPenaltyKickCamera()
    self:setBroadcast(BroadcastSpot.Special)

    local isFromLeftToRight = GameHubWrap.IsFromLeftToRight()

    self.shootTargetGate = isFromLeftToRight and self.parameters.gate1 or self.parameters.gate2
    local penaltyKickPosition = isFromLeftToRight and self.parameters.penaltyKickPosition1 or self.parameters.penaltyKickPosition2
    local tmpLookAt = Vector3(self.shootTargetGate.x, 0, self.shootTargetGate.z)
    local tmpBallPos = Vector3(penaltyKickPosition.x, 0, penaltyKickPosition.z)

    local initCameraPos = tmpBallPos + (tmpBallPos - tmpLookAt).normalized * 15
    initCameraPos = Vector3(initCameraPos.x, 3, initCameraPos.z)
    local initLookAt = (penaltyKickPosition + self.shootTargetGate) / 2

    CameraCtrlWrap.EnqueueCameraMoveAction(initCameraPos, initCameraPos, initLookAt, initLookAt, 5, 0, self.parameters.defaultFieldOfView)
end

function CameraCtrlCore:setPenaltyShootOutKickCamera()
    self:setBroadcast(BroadcastSpot.Special)

    local isFromLeftToRight = GameHubWrap.IsFromLeftToRight()
    local initCameraPos = isFromLeftToRight and Vector3(0, 9.31, -20) or Vector3(0, 9.31, 20)
    local initLookAt = isFromLeftToRight and Vector3(0, 1.05, -48.45) or Vector3(0, 1.05, 48.45)

    self.shootTargetGate = isFromLeftToRight and self.parameters.gate1 or self.parameters.gate2

    CameraCtrlWrap.EnqueueCameraMoveAction(initCameraPos, initCameraPos, initLookAt, initLookAt, 15, 0, self.parameters.defaultFieldOfView)
end

function CameraCtrlCore:getPlayBackIsFromLeftToRight()
    return ___playbackManager.isPlaybackMatchHighlights
        and ___playbackManager:GetIsFromLeftToRightInMatchHighlights()
        or GameHubWrap.IsFromLeftToRight()
end

function CameraCtrlCore:setPlayBackPenaltyKickCamera()
    self:setBroadcast(BroadcastSpot.PlayBackSpecial)

    local shootTargetGate = self:getPlayBackIsFromLeftToRight() and self.parameters.gate1 or self.parameters.gate2
    local ballPosition = BallActionExecutorWrap.GetBallPosition()

    local initCameraPos
    local initLookAt
    local fov

    local randomNumber = math.random()
    if randomNumber < 0.5 then
        initCameraPos = Vector3(30, 10, math.sign(shootTargetGate.z) * 10)
        initLookAt = shootTargetGate * 0.5 + ballPosition * 0.5
        fov = 12
    else
        initCameraPos = Vector3(-30, 10, math.sign(shootTargetGate.z) * 10)
        initLookAt = shootTargetGate * 0.5 + ballPosition * 0.5
        fov = 12
    end

    CameraCtrlWrap.EnqueueCameraMoveAction(initCameraPos, initCameraPos, initLookAt, initLookAt, 5, 0, fov)
end

function CameraCtrlCore:setPlayBackPenaltyShootOutKickCamera()
    self:setBroadcast(BroadcastSpot.PlayBackSpecial)

    local ballPosition = BallActionExecutorWrap.GetBallPosition()

    local initCameraPos
    local initLookAt
    local fov

    local randomNumber = math.random()
    if randomNumber < 0.5 then
        initCameraPos = Vector3(30, 10, math.sign(self.shootTargetGate.z) * 10)
        initLookAt = self.shootTargetGate * 0.5 + ballPosition * 0.5
        fov = 12
    else
        initCameraPos = Vector3(-30, 10, math.sign(self.shootTargetGate.z) * 10)
        initLookAt = self.shootTargetGate * 0.5 + ballPosition * 0.5
        fov = 12
    end

    CameraCtrlWrap.EnqueueCameraMoveAction(initCameraPos, initCameraPos, initLookAt, initLookAt, 5, 0, fov)
end

function CameraCtrlCore:setDirectFreeKickCamera(eventType, ballOwnerPos)
    self:setBroadcast(BroadcastSpot.Special)

    local targetGate
    local isFromLeftToRight = GameHubWrap.IsFromLeftToRight()
    if eventType == MatchEventType.CenterDirectFreeKick then
        targetGate = isFromLeftToRight and self.parameters.gate1 or self.parameters.gate2
    else
        targetGate = isFromLeftToRight and self.parameters.penaltyKickPosition1 or self.parameters.penaltyKickPosition2
    end

    local tmpLookAt = Vector3(targetGate.x, 0, targetGate.z)
    local tmpBallPos = Vector3(BallActionExecutorWrap.GetBallPosition().x, 0, BallActionExecutorWrap.GetBallPosition().z)
    local initCameraPos = tmpBallPos + (tmpBallPos - tmpLookAt).normalized * 24
    initCameraPos = Vector3(initCameraPos.x, 5.5, initCameraPos.z)

    local initLookAt = (targetGate + BallActionExecutorWrap.GetBallPosition()) / 2

    CameraCtrlWrap.EnqueueCameraMoveAction(initCameraPos, initCameraPos, initLookAt, initLookAt, 3, 0, self.parameters.defaultFieldOfView)
end

function CameraCtrlCore:setPlayBackCenterDirectFreeKickCamera(eventType, ballOwnerPos)
    self:setBroadcast(BroadcastSpot.PlayBackSpecial)

    local targetGate = self:getPlayBackIsFromLeftToRight() and self.parameters.gate1 or self.parameters.gate2

    local candidatePlayBackCenterDirectFreeKickCameraParameters = {
        {
            initCameraPos = Vector3(math.sign(BallActionExecutorWrap.GetBallPosition().x) * 45, 10, math.sign(targetGate.z) * 10),
            initLookAt = targetGate * 0.35 + BallActionExecutorWrap.GetBallPosition() * 0.65,
            fov = 18,
        },
        {
            initCameraPos = Vector3(math.sign(BallActionExecutorWrap.GetBallPosition().x) * 15, 15, -math.sign(targetGate.z) * 5),
            initLookAt = targetGate * 0.35 + BallActionExecutorWrap.GetBallPosition() * 0.65,
            fov = 20,
        },
        {
            initCameraPos = Vector3(math.sign(BallActionExecutorWrap.GetBallPosition().x) * 45, 10, math.sign(targetGate.z) * 10),
            initLookAt = BallActionExecutorWrap.GetBallPosition(),
            fov = 10,
        },
        {
            initCameraPos = Vector3(math.sign(BallActionExecutorWrap.GetBallPosition().x) * 50, 10, math.sign(targetGate.z) * 30),
            initLookAt = BallActionExecutorWrap.GetBallPosition(),
            fov = 10,
        },
        {
            initCameraPos = Vector3(-math.sign(BallActionExecutorWrap.GetBallPosition().x) * 50, 10, math.sign(targetGate.z) * 20),
            initLookAt = BallActionExecutorWrap.GetBallPosition(),
            fov = 10,
        },
    }

    local selectedCameraParameters = self:selectCameraParameter(candidatePlayBackCenterDirectFreeKickCameraParameters)

    CameraCtrlWrap.EnqueueCameraMoveAction(selectedCameraParameters.initCameraPos, selectedCameraParameters.initCameraPos,
    selectedCameraParameters.initLookAt, selectedCameraParameters.initLookAt, 5, 0, selectedCameraParameters.fov)
end

function CameraCtrlCore:setPlayBackWingDirectFreeKickCamera(eventType, ballOwnerPos)
    self:setBroadcast(BroadcastSpot.PlayBackSpecial)

    local isFromLeftToRight = self:getPlayBackIsFromLeftToRight()
    local targetGate = isFromLeftToRight and self.parameters.gate1 or self.parameters.gate2
    local penaltyKickPosition = isFromLeftToRight and self.parameters.penaltyKickPosition1 or self.parameters.penaltyKickPosition2

    local candidatePlayBackWingDirectFreeKickCameraParameters = {
        {
            initCameraPos = Vector3(math.sign(BallActionExecutorWrap.GetBallPosition().x) * 65, 10, math.sign(targetGate.z) * 25),
            initLookAt = penaltyKickPosition * 0.6 + BallActionExecutorWrap.GetBallPosition() * 0.4,
            fov = 14,
        },
        {
            initCameraPos = Vector3(math.sign(BallActionExecutorWrap.GetBallPosition().x) * 70, 10, math.sign(targetGate.z) * 40),
            initLookAt = penaltyKickPosition * 0.5 + BallActionExecutorWrap.GetBallPosition() * 0.4 + targetGate * 0.1,
            fov = 14,
        },
        {
            initCameraPos = Vector3(-math.sign(BallActionExecutorWrap.GetBallPosition().x) * 60, 10, math.sign(penaltyKickPosition.z) * 45),
            initLookAt = penaltyKickPosition * 0.7 + BallActionExecutorWrap.GetBallPosition() * 0.1 + targetGate * 0.2,
            fov = 14,
        },
        {
            initCameraPos = Vector3(-math.sign(BallActionExecutorWrap.GetBallPosition().x) * 65, 10, math.sign(penaltyKickPosition.z) * 20),
            initLookAt = penaltyKickPosition * 0.65 + BallActionExecutorWrap.GetBallPosition() * 0.15 + targetGate * 0.2,
            fov = 16,
        },
    }

    local selectedCameraParameters = self:selectCameraParameter(candidatePlayBackWingDirectFreeKickCameraParameters)

    CameraCtrlWrap.EnqueueCameraMoveAction(selectedCameraParameters.initCameraPos, selectedCameraParameters.initCameraPos,
    selectedCameraParameters.initLookAt, selectedCameraParameters.initLookAt, 5, 0, selectedCameraParameters.fov)
end

function CameraCtrlCore:setGoalKickCamera()
    local randomNumber = math.random()

    local initCameraPos
    local initLookAt
    local isFromLeftToRight = GameHubWrap.IsFromLeftToRight()
    if randomNumber < 0.75 then
        self:setBroadcast(BroadcastSpot.BaseLineSpot)
        self.shootTargetGate = isFromLeftToRight and self.parameters.gate1 or self.parameters.gate2

        initCameraPos = Vector3(0, 15, -math.sign(self.shootTargetGate.z) * 67)
        initLookAt = Vector3(0, -15, 0)
        CameraCtrlWrap.EnqueueCameraMoveAction(initCameraPos, initCameraPos, initLookAt, initLookAt, 2, 0, self.parameters.baseFieldOfView)
    else
        self:setBroadcast(BroadcastSpot.MainSpot)
        local destX = math.max(self.parameters.minXValue, BallActionExecutorWrap.GetBallPosition().x - self.parameters.standardXDistance)
        local destZ = math.min(math.max(BallActionExecutorWrap.GetBallPosition().z, -self.parameters.maxZOffset), self.parameters.maxZOffset)
        initCameraPos = Vector3(destX, self.parameters.mainBroadcastSpot.y, destZ)

        local lookAt = isFromLeftToRight and initCameraPos + rotateXZ(BallActionExecutorWrap.GetBallPosition() - initCameraPos, -self.defaultHorizontalFOV / 4)
            or initCameraPos + rotateXZ(BallActionExecutorWrap.GetBallPosition() - initCameraPos, self.defaultHorizontalFOV / 4)
        local lookAtX = math.clamp(lookAt.x, self.parameters.lookAtMinXValue, self.parameters.lookAtMaxXValue)
        initLookAt = Vector3(lookAtX, lookAt.y, lookAt.z)

        CameraCtrlWrap.EnqueueCameraMoveAction(initCameraPos, initCameraPos, initLookAt, initLookAt, 1, 0, self.parameters.defaultFieldOfView)
    end
end

function CameraCtrlCore:setPlayBackGoalKickCamera()
    local randomNumber = math.random()

    local initCameraPos
    local initLookAt
    local isFromLeftToRight = self:getPlayBackIsFromLeftToRight()
    if randomNumber < 0.75 then
        self:setBroadcast(BroadcastSpot.BaseLineSpot)
        self.shootTargetGate = isFromLeftToRight and self.parameters.gate1 or self.parameters.gate2

        initCameraPos = Vector3(0, 15, -math.sign(self.shootTargetGate.z) * 67)
        initLookAt = Vector3(0, -15, 0)
        CameraCtrlWrap.EnqueueCameraMoveAction(initCameraPos, initCameraPos, initLookAt, initLookAt, 2, 0, self.parameters.baseFieldOfView)
    else
        self:setBroadcast(BroadcastSpot.MainSpot)
        local destX = math.max(self.parameters.minXValue, BallActionExecutorWrap.GetBallPosition().x - self.parameters.standardXDistance)
        local destZ = math.min(math.max(BallActionExecutorWrap.GetBallPosition().z, -self.parameters.maxZOffset), self.parameters.maxZOffset)
        initCameraPos = Vector3(destX, self.parameters.mainBroadcastSpot.y, destZ)

        local lookAt = isFromLeftToRight and initCameraPos + rotateXZ(BallActionExecutorWrap.GetBallPosition() - initCameraPos, -self.defaultHorizontalFOV / 4)
            or initCameraPos + rotateXZ(BallActionExecutorWrap.GetBallPosition() - initCameraPos, self.defaultHorizontalFOV / 4)
        local lookAtX = math.clamp(lookAt.x, self.parameters.lookAtMinXValue, self.parameters.lookAtMaxXValue)
        initLookAt = Vector3(lookAtX, lookAt.y, lookAt.z)

        CameraCtrlWrap.EnqueueCameraMoveAction(initCameraPos, initCameraPos, initLookAt, initLookAt, 1, 0, self.parameters.defaultFieldOfView)
    end
end

function CameraCtrlCore:setIndirectFreeKickCamera()
    self:setBroadcast(BroadcastSpot.MainSpot)

    local initCameraPos
    local initLookAt

    local destX = math.max(self.parameters.minXValue, BallActionExecutorWrap.GetBallPosition().x - self.parameters.standardXDistance)
    local destZ = math.min(math.max(BallActionExecutorWrap.GetBallPosition().z, -self.parameters.maxZOffset), self.parameters.maxZOffset)
    initCameraPos = Vector3(destX, self.parameters.mainBroadcastSpot.y, destZ)

    local lookAt = GameHubWrap.IsFromLeftToRight() and initCameraPos + rotateXZ(BallActionExecutorWrap.GetBallPosition() - initCameraPos, -self.defaultHorizontalFOV / 4)
        or initCameraPos + rotateXZ(BallActionExecutorWrap.GetBallPosition() - initCameraPos, self.defaultHorizontalFOV / 4)
    local lookAtX = math.clamp(lookAt.x, self.parameters.lookAtMinXValue, self.parameters.lookAtMaxXValue)
    initLookAt = Vector3(lookAtX, lookAt.y, lookAt.z)

    CameraCtrlWrap.EnqueueCameraMoveAction(initCameraPos, initCameraPos, initLookAt, initLookAt, 1, 0, self.parameters.defaultFieldOfView)
end

function CameraCtrlCore:setThrowInCamera()
    self:setBroadcast(BroadcastSpot.MainSpot)

    local initCameraPos = Vector3(math.max(self.parameters.minXValue, BallActionExecutorWrap.GetBallPosition().x - self.parameters.standardXDistance),
        self.parameters.mainBroadcastSpot.y, math.min(math.max(BallActionExecutorWrap.GetBallPosition().z, -self.parameters.maxZOffset), self.parameters.maxZOffset))
    local lookAtX = math.clamp(BallActionExecutorWrap.GetBallPosition().x, -30, self.parameters.lookAtMaxXValue)

    local initLookAt = Vector3(lookAtX, BallActionExecutorWrap.GetBallPosition().y, BallActionExecutorWrap.GetBallPosition().z)

    CameraCtrlWrap.EnqueueCameraMoveAction(initCameraPos, initCameraPos, initLookAt, initLookAt, 2, 0, self.parameters.defaultFieldOfView)
end

function CameraCtrlCore:setCornerKickCamera(ballOwnerPos, ballOwnerForward)
    self:setBroadcast(BroadcastSpot.Special)

    local penaltyKickPosition = GameHubWrap.IsFromLeftToRight() and self.parameters.penaltyKickPosition1 or self.parameters.penaltyKickPosition2

    local randomNumber = math.random()

    local cornerCameraPosition
    local cornerCameraLookAt
    if randomNumber < 0.5 then
        local tmpLookAt = Vector3(penaltyKickPosition.x, 0, math.sign(penaltyKickPosition.z) * 42)
        local tmpBallPos = Vector3(BallActionExecutorWrap.GetBallPosition().x, 0, BallActionExecutorWrap.GetBallPosition().z)

        cornerCameraPosition = tmpBallPos + (tmpBallPos - tmpLookAt).normalized * 16
        cornerCameraPosition = Vector3(cornerCameraPosition.x, 3.2, cornerCameraPosition.z)
        cornerCameraLookAt = tmpLookAt
    else
        cornerCameraPosition = Vector3(-math.sign(BallActionExecutorWrap.GetBallPosition().x) * 35, 15, math.sign(BallActionExecutorWrap.GetBallPosition().z) * 22.6)
        cornerCameraLookAt = Vector3(math.sign(BallActionExecutorWrap.GetBallPosition().x) * 7.8, 0, math.sign(BallActionExecutorWrap.GetBallPosition().z) * 50.22)
    end

    CameraCtrlWrap.EnqueueCameraMoveAction(cornerCameraPosition, cornerCameraPosition, cornerCameraLookAt, cornerCameraLookAt, 3, 0, self.parameters.defaultFieldOfView)
end

function CameraCtrlCore:setPlayBackCornerKickCamera(ballOwnerPos, ballOwnerForward)
    self:setBroadcast(BroadcastSpot.PlayBackSpecial)

    local isFromLeftToRight = self:getPlayBackIsFromLeftToRight()
    local penaltyKickPosition = isFromLeftToRight and self.parameters.penaltyKickPosition1 or self.parameters.penaltyKickPosition2
    local shootTargetGate = isFromLeftToRight and self.parameters.gate1 or self.parameters.gate2

    local candidatePlayBackCornerKickCameraParameters = {
        {
            cornerCameraPosition = Vector3(math.sign(BallActionExecutorWrap.GetBallPosition().x) * 67.4, 10, math.sign(BallActionExecutorWrap.GetBallPosition().z) * 50),
            cornerCameraLookAt = penaltyKickPosition * 0.35 + BallActionExecutorWrap.GetBallPosition() * 0.6 + shootTargetGate * 0.05,
            fov = 14,
        },
        {
            cornerCameraPosition = Vector3(-math.sign(BallActionExecutorWrap.GetBallPosition().x) * 50, 10, math.sign(penaltyKickPosition.z) * 45),
            cornerCameraLookAt = penaltyKickPosition * 0.7 + BallActionExecutorWrap.GetBallPosition() * 0.1 + shootTargetGate * 0.2,
            fov = 14,
        },
        {
            cornerCameraPosition = Vector3(-math.sign(BallActionExecutorWrap.GetBallPosition().x) * 50, 10, math.sign(penaltyKickPosition.z) * 20),
            cornerCameraLookAt = penaltyKickPosition * 0.7 + BallActionExecutorWrap.GetBallPosition() * 0.1 + shootTargetGate * 0.2,
            fov = 14,
        },
    }

    local selectedCameraParameters = self:selectCameraParameter(candidatePlayBackCornerKickCameraParameters)

    CameraCtrlWrap.EnqueueCameraMoveAction(selectedCameraParameters.cornerCameraPosition, selectedCameraParameters.cornerCameraPosition,
    selectedCameraParameters.cornerCameraLookAt, selectedCameraParameters.cornerCameraLookAt, 5, 0, selectedCameraParameters.fov)
end

function CameraCtrlCore:setNormalPlayBackBroadcast()
    self:resetCameraStates()

    local shootTargetGate = self:getPlayBackIsFromLeftToRight() and self.parameters.gate1 or self.parameters.gate2
    local cameraSign = math.sign(shootTargetGate.z)
    local ballPosition = BallActionExecutorWrap.GetBallPosition()
    local candidateNormalPlayBackCameraParameters = {
        {
            broadcast = BroadcastSpot.PlayBackNormal,
            initCameraPos = Vector3(60, 20, 15 * cameraSign),
            initLookAt = ballPosition,
            fov = 10,
        },
        {
            broadcast = BroadcastSpot.PlayBackNormal,
            initCameraPos = Vector3(-60, 20, 15 * cameraSign),
            initLookAt = ballPosition,
            fov = 10,
        },
        {
            broadcast = BroadcastSpot.PlayBackNormal,
            initCameraPos = Vector3(65, 25, 0),
            initLookAt = ballPosition,
            fov = 15,
        },
        {
            broadcast = BroadcastSpot.PlayBackNormal,
            initCameraPos = Vector3(-65, 25, 0),
            initLookAt = ballPosition,
            fov = 15,
        },
        {
            broadcast = BroadcastSpot.PlayBackNormal,
            initCameraPos = Vector3(0, 30, -cameraSign * 40),
            initLookAt = ballPosition,
            fov = 15,
        },
        {
            broadcast = BroadcastSpot.PlayBackGoalView,
            initCameraPos = Vector3(-math.sign(ballPosition.x) * 3.3, 2, cameraSign * 57.4),
            initLookAt = Vector3(math.sign(ballPosition.x) * 0, 0, cameraSign * 52),
            fov = 50,
        },
    }

    local centralFieldCameraPosition = Vector3(0, 15, -cameraSign * 25)
    --当满足一定距离条件时才使用中场近景摄像机策略，太近的不采用此位置摄像机
    if Vector2.Distance(Vector2(centralFieldCameraPosition.x, centralFieldCameraPosition.z), Vector2(ballPosition.x, ballPosition.z)) >= 25 then
        table.insert(candidateNormalPlayBackCameraParameters, {
            broadcast = BroadcastSpot.PlayBackNormal,
            initCameraPos = centralFieldCameraPosition,
            initLookAt = ballPosition,
            fov = 10,
        })
    end

    local selectedCameraParameters = self:selectCameraParameter(candidateNormalPlayBackCameraParameters)

    self:setBroadcast(selectedCameraParameters.broadcast)
    CameraCtrlWrap.EnqueueCameraMoveAction(selectedCameraParameters.initCameraPos, selectedCameraParameters.initCameraPos,
    selectedCameraParameters.initLookAt, selectedCameraParameters.initLookAt, 3, 0, selectedCameraParameters.fov)
end

function CameraCtrlCore:checkGoalViewCameraShake()
    if self:isPlayBackGoalView() then
        CameraCtrlWrap.StartShakeCamera()
    end
end

function CameraCtrlCore:selectCameraParameter(candidatePlaybackCameraParameters)
    local candidateIndices = table.keys(candidatePlaybackCameraParameters)

    local unusedCameraParameterIndices = { }
    for _, i in ipairs(candidateIndices) do
        if not table.isArrayInclude(self.usedPlayBackCameraParameterIndices, i) then
            table.insert(unusedCameraParameterIndices, i)
        end
    end

    if #unusedCameraParameterIndices == 0 then
        self:clearUsedPlayBackCameraParameterIndices()
        unusedCameraParameterIndices = candidateIndices
    end

    local selectedCameraParameterIndex = randomSelect(unusedCameraParameterIndices)
    table.insert(self.usedPlayBackCameraParameterIndices, selectedCameraParameterIndex)

    return candidatePlaybackCameraParameters[selectedCameraParameterIndex]
end

function CameraCtrlCore:isPlayBackGoalView()
    return self:isBroadcast(BroadcastSpot.PlayBackGoalView)
end

function CameraCtrlCore:onBallActionStart(segment)
    if not ___playbackManager.isPlaybackMatchHighlights and self:isKickOffBallAction(segment) then
        return
    end

    if math.cmpf(segment.Time, 0.2) > 0 and not (math.abs(segment["start"].x) > 37 and Vector3.Distance(segment["start"], segment["end"]) < 5) then --掷界外球球在手中时摄像机保持不动
        self:forceSwitchCamera()
        if self:isBroadcast(BroadcastSpot.MainSpot) then
            if self.isInManualOperateView then
                self:changeBroadcastSpot(self.parameters.mainBroadcastSpot, segment)
                self.isInManualOperateView = false
            else
                self:checkCameraMoveWithBallAction(segment)
            end
        elseif self:isBroadcast(BroadcastSpot.PlayBackNormal) then
            CameraCtrlWrap.EnqueueCameraMoveAction(CameraCtrlWrap.GetCameraContainerPosition(), CameraCtrlWrap.GetCameraContainerPosition(), CameraCtrlWrap.GetLookAt(), segment["end"], segment.Time / 2 / TimeWrap.GetTimeScale(), 0, CameraCtrlWrap.GetCameraFov())
        elseif self:isBroadcast(BroadcastSpot.PlayBackSpecial) then
            CameraCtrlWrap.EnqueueCameraMoveAction(CameraCtrlWrap.GetCameraContainerPosition(), CameraCtrlWrap.GetCameraContainerPosition(), CameraCtrlWrap.GetLookAt(), segment["end"], segment.Time / 3 / TimeWrap.GetTimeScale(), 0, CameraCtrlWrap.GetCameraFov())
        elseif self:isBroadcast(BroadcastSpot.PlayBackGoalView) then
            CameraCtrlWrap.EnqueueCameraMoveAction(CameraCtrlWrap.GetCameraContainerPosition(), CameraCtrlWrap.GetCameraContainerPosition(), CameraCtrlWrap.GetLookAt(), CameraCtrlWrap.GetLookAt(), segment.Time, 0, CameraCtrlWrap.GetCameraFov())
        end
    end
end

function CameraCtrlCore:isKickOffBallAction(segment)
    if self.ballSegNumFromKickOff < 3 then
        self.ballSegNumFromKickOff = self.ballSegNumFromKickOff + 1
        return true
    end

    return false
end

function CameraCtrlCore:checkCameraMoveWithBallAction(segment)
    local destPos = self:getCameraDestPosition(segment)
    local destLookAtPos = self:getCameraDestLookAtPosition(segment)

    CameraCtrlWrap.EnqueueCameraMoveAction(CameraCtrlWrap.GetCameraContainerPosition(), destPos, CameraCtrlWrap.GetLookAt(), destLookAtPos, segment.Time / TimeWrap.GetTimeScale(), 0, self.parameters.defaultFieldOfView)
end

function CameraCtrlCore:getCameraDestPosition(segment)
    local cameraContainerPosition = CameraCtrlWrap.GetCameraContainerPosition()
    local cameraXToChange = math.abs(segment["end"].x - cameraContainerPosition.x) > self.parameters.standardXDistance + self.parameters.xDistanceTolerance
        or math.abs(segment["end"].x - cameraContainerPosition.x) < self.parameters.standardXDistance - self.parameters.xDistanceTolerance
    local cameraZToChange = math.abs(segment["end"].z - cameraContainerPosition.z) > self.parameters.responseZOffset
    if cameraZToChange or cameraXToChange then
        local destX = cameraContainerPosition.x
        if cameraXToChange then
            destX = math.max(self.parameters.minXValue, segment["end"].x - self.parameters.standardXDistance)
        end

        local destZ = cameraContainerPosition.z
        if cameraZToChange then
            destZ = math.min(math.max(segment["end"].z, -self.parameters.maxZOffset), self.parameters.maxZOffset)
        end

        return Vector3(destX, self.parameters.mainBroadcastSpot.y, destZ)
    end

    return cameraContainerPosition
end

function CameraCtrlCore:getCameraDestLookAtPosition(segment)
    if GameHubWrap.IsFromLeftToRight() then
        if not self:inLeftOneThirdView(segment["end"]) or not self:inCentralVerticalPos(segment["end"]) then
            return self:calcLookAtPositionWithBallAction(segment, -self.defaultHorizontalFOV / 4)
        end
    else
        if not self:inRightOneThirdView(segment["end"]) or not self:inCentralVerticalPos(segment["end"]) then
            return self:calcLookAtPositionWithBallAction(segment, self.defaultHorizontalFOV / 4)
        end
    end

    return CameraCtrlWrap.GetLookAt()
end

function CameraCtrlCore:calcLookAtPositionWithBallAction(segment, destBallAngle)
    local destLookAtPos = CameraCtrlWrap.GetDestPos() + rotateXZ(segment["end"] - CameraCtrlWrap.GetDestPos(), destBallAngle)
    destLookAtPos = Vector3(math.clamp(destLookAtPos.x, self.parameters.lookAtMinXValue, self.parameters.lookAtMaxXValue), destLookAtPos.y, destLookAtPos.z)

    return destLookAtPos
end

local function getSideJudgeValueXZ(position, startPos, endPos)
    return (endPos.x - startPos.x) * (position.z - startPos.z) - (endPos.z - startPos.z) * (position.x - startPos.x)
end

local function getSideJudgeValueYX(position, startPos, endPos)
    return (endPos.y - startPos.y) * (position.x - startPos.x) - (endPos.x - startPos.x) * (position.y - startPos.y)
end

local function isInLeftOfVectorXZ(position, startPos, endPos)
    return getSideJudgeValueXZ(position, startPos, endPos) >= 0
end

local function isInRightOfVectorXZ(position, startPos, endPos)
    return getSideJudgeValueXZ(position, startPos, endPos) <= 0
end

local function isBelowVectorYX(position, startPos, endPos)
    return getSideJudgeValueYX(position, startPos, endPos) >= 0
end

local function isAboveVectorYX(position, startPos, endPos)
    return getSideJudgeValueYX(position, startPos, endPos) <= 0
end

function CameraCtrlCore:inLeftOneThirdView(position)
    local rightBoardPoint = CameraCtrlWrap.GetDestPos() + rotateXZ(CameraCtrlWrap.GetLookAt() - CameraCtrlWrap.GetDestPos(), self.defaultHorizontalFOV / 6)
    local leftBoardPoint = CameraCtrlWrap.GetDestPos() + rotateXZ(CameraCtrlWrap.GetLookAt() - CameraCtrlWrap.GetDestPos(), self.defaultHorizontalFOV / 2)

    return isInLeftOfVectorXZ(position, CameraCtrlWrap.GetDestPos(), rightBoardPoint) and isInRightOfVectorXZ(position, CameraCtrlWrap.GetDestPos(), leftBoardPoint)
end

function CameraCtrlCore:inRightOneThirdView(position)
    local rightBoardPoint = CameraCtrlWrap.GetDestPos() + rotateXZ(CameraCtrlWrap.GetLookAt() - CameraCtrlWrap.GetDestPos(), -self.defaultHorizontalFOV / 2)
    local leftBoardPoint = CameraCtrlWrap.GetDestPos() + rotateXZ(CameraCtrlWrap.GetLookAt() - CameraCtrlWrap.GetDestPos(), -self.defaultHorizontalFOV / 6)

    return isInLeftOfVectorXZ(position, CameraCtrlWrap.GetDestPos(), rightBoardPoint) and isInRightOfVectorXZ(position, CameraCtrlWrap.GetDestPos(), leftBoardPoint)
end

function CameraCtrlCore:inCentralVerticalPos(position)
    local upBoardPoint = CameraCtrlWrap.GetDestPos() + rotateYX(CameraCtrlWrap.GetLookAt() - CameraCtrlWrap.GetDestPos(), -self.parameters.defaultFieldOfView / 6)
    local downBoardPoint = CameraCtrlWrap.GetDestPos() + rotateYX(CameraCtrlWrap.GetLookAt() - CameraCtrlWrap.GetDestPos(), self.parameters.defaultFieldOfView / 6)

    return isBelowVectorYX(position, CameraCtrlWrap.GetDestPos(), upBoardPoint) and isAboveVectorYX(position, CameraCtrlWrap.GetDestPos(), downBoardPoint)
end

function CameraCtrlCore:onShootViewStart(ballPositionOnShoot, playerPositionOnShoot)
    if ___matchUI.inPenaltyShootOut then
        return
    end

    CameraCtrlWrap.ClearCameraMoveAction()
    CameraCtrlWrap.SetIsCameraFollowPlayer(true)
    self.isInManualOperateView = false
    self:setBroadcast(BroadcastSpot.Special)

    self.shootTargetGate = GameHubWrap.IsFromLeftToRight() and self.parameters.gate1 or self.parameters.gate2

    local sideAngleProportion = playerPositionOnShoot.y >= 1.5 and 1 / 4 or 1 / 8
    local centralAngleProportion = 0.5 - sideAngleProportion
    local shootDistance = Vector2.Distance(Vector2(ballPositionOnShoot.x, ballPositionOnShoot.z), Vector2(self.shootTargetGate.x, self.shootTargetGate.z))
    local gamma = (150 + 0.3 * shootDistance) * Deg2Rad
    if math.cmpf(shootDistance, 0) == 0 then shootDistance = 0.01 end
    local beta = gamma - math.atan((self.parameters.beamHeight - playerPositionOnShoot.y) / shootDistance)
    local alpha = math.pi - gamma
    local distanceBehind = Vector3.Distance(playerPositionOnShoot, Vector3(0, self.parameters.beamHeight, self.shootTargetGate.z))
        * math.sin(math.pi / 2 - alpha)
        * math.sin(math.pi - beta - 2 * centralAngleProportion * self.parameters.defaultFieldOfView * Deg2Rad)
        / math.sin(2 * centralAngleProportion * self.parameters.defaultFieldOfView * Deg2Rad)
    local distanceHeightBehind = playerPositionOnShoot.y + distanceBehind / math.tan(math.pi / 2 - alpha)
    local lookAtDistanceFoward = distanceBehind
        * math.sin(centralAngleProportion * self.parameters.defaultFieldOfView * Deg2Rad)
        / math.sin(math.pi - beta - centralAngleProportion * self.parameters.defaultFieldOfView * Deg2Rad)
        / math.sin(math.pi / 2 - alpha)

    local tmpLookAt = Vector3(self.shootTargetGate.x, 0, self.shootTargetGate.z)
    local tmpPlayerDest = Vector3(playerPositionOnShoot.x, 0, playerPositionOnShoot.z)

    local destPos = tmpPlayerDest + (tmpPlayerDest - tmpLookAt).normalized * distanceBehind
    destPos = Vector3(destPos.x, distanceHeightBehind, destPos.z)
    local destLookAtPos = playerPositionOnShoot + (Vector3(0, self.parameters.beamHeight, self.shootTargetGate.z) - playerPositionOnShoot).normalized * lookAtDistanceFoward

    self:setPositionMoveStartAndEnd(CameraCtrlWrap.GetCameraContainerPosition(), destPos)
    self:setLookAtMoveStartAndEnd(CameraCtrlWrap.GetLookAt(), destLookAtPos)
    self:setMoveTimeInfo(TimeWrap.GetUnscaledTime(), self.parameters.cameraFollowMoveDuration)
end

function CameraCtrlCore:setPositionMoveStartAndEnd(originPos, destPos)
    CameraCtrlWrap.SetOriginPos(originPos)
    CameraCtrlWrap.SetDestPos(destPos)
end

function CameraCtrlCore:setLookAtMoveStartAndEnd(originLookAtPos, destLookAtPos)
    CameraCtrlWrap.SetOriginLookAtPos(originLookAtPos)
    CameraCtrlWrap.SetDestLookAtPos(destLookAtPos)
end

function CameraCtrlCore:setMoveTimeInfo(startTime, moveDuration)
    CameraCtrlWrap.SetStartTime(startTime)
    CameraCtrlWrap.SetMoveDuration(moveDuration)
end

function CameraCtrlCore:onShootViewEnd(shootResult)
    if ___matchUI.inPenaltyShootOut then
        return
    end

    CameraCtrlWrap.SetIsCameraFollowPlayer(false)

    if self.matchInfoModel:IsDemoMatch() then
        return
    end

    CameraCtrlWrap.SetIsCelebrateDefollow(false)
    local tmpLookAt = Vector3(self.shootTargetGate.x, 0, self.shootTargetGate.z)
    local tmpCameraPos = Vector3(CameraCtrlWrap.GetCameraContainerPosition().x, 0, CameraCtrlWrap.GetCameraContainerPosition().z)
    local destPos = tmpCameraPos + (tmpCameraPos - tmpLookAt).normalized * self.parameters.cameraDefollowDistanceBehind
    destPos = Vector3(destPos.x, self.parameters.cameraDefollowHeightBehind, destPos.z)
    local destLookAtPos = self.shootTargetGate
    local moveDuration = self.parameters.cameraDefollowMoveDuration

    self:setPositionMoveStartAndEnd(CameraCtrlWrap.GetCameraContainerPosition(), destPos)
    self:setLookAtMoveStartAndEnd(CameraCtrlWrap.GetLookAt(), destLookAtPos)
    self:setMoveTimeInfo(TimeWrap.GetUnscaledTime(), moveDuration)
end

local function calculateCameraBehindPosition(referencePostion, directionStartPosition, behindDistance, height)
    local tmpDirectionStartPosition = Vector3(directionStartPosition.x, 0, directionStartPosition.z)
    local tmpReferencePostion = Vector3(referencePostion.x, 0, referencePostion.z)
    local destPos = tmpReferencePostion + (tmpReferencePostion - tmpDirectionStartPosition).normalized * behindDistance
    destPos.y = height

    return destPos
end

local function calcManualOperateViewCenterPosition(action, shootTargetGate, manualPlayerPosition)
    local manualOperateAction = action.athleteAction.manualOperateAction
    local centerPos = Vector3(0, 0, 0)
    local count = 0
    local manualPlayerToGateVec = shootTargetGate - manualPlayerPosition
    for _, manualPass in ipairs(manualOperateAction.passList) do
        local playerPos = GameHubWrap.GetPlayerPosition(manualPass.onfieldId - 1)
        local targetAthleteToGateVec = playerPos - manualPlayerPosition
        if Vector2.Angle(Vector2(manualPlayerToGateVec.x, manualPlayerToGateVec.z), Vector2(targetAthleteToGateVec.x, targetAthleteToGateVec.z)) < 90 then
            centerPos.x = centerPos.x + playerPos.x
            centerPos.y = centerPos.y + playerPos.y
            centerPos.z = centerPos.z + playerPos.z
            count = count + 1
        end
    end

    if count == 0 then
        return nil
    else
        centerPos = centerPos / count
        return centerPos
    end
end

function CameraCtrlCore:onManualOperateViewStart(manualPlayerPosition, action)
    CameraCtrlWrap.ClearCameraMoveAction()
    self.isInManualOperateView = true

    CameraCtrlWrap.SetIsCameraFollowPlayer(true)

    self.shootTargetGate = GameHubWrap.IsFromLeftToRight() and self.parameters.gate1 or self.parameters.gate2

    local passTargetAthleteCenter = calcManualOperateViewCenterPosition(action, self.shootTargetGate, manualPlayerPosition)
    local hasManualOperateShootOption = action.athleteAction.manualOperateAction.isShootEnabled

    if passTargetAthleteCenter then
        self.viewCenterPosition = hasManualOperateShootOption and self.shootTargetGate * 0.5 + passTargetAthleteCenter * 0.5
            or self.shootTargetGate * 0.3 + passTargetAthleteCenter * 0.7
    else
        self.viewCenterPosition = self.shootTargetGate
    end

    self.manualOperateViewStartPlayerPosition = clone(manualPlayerPosition)

    local destPos = calculateCameraBehindPosition(manualPlayerPosition, self.viewCenterPosition, -0.4 * math.abs(self.manualOperateViewStartPlayerPosition.x) + 40, -0.25 * math.abs(self.manualOperateViewStartPlayerPosition.x) + 17)
    local destLookAtPos = manualPlayerPosition + Vector2.Normalize(self.viewCenterPosition - manualPlayerPosition) * (12 + math.abs(self.manualOperateViewStartPlayerPosition.x) * 0.1)

    self:setPositionMoveStartAndEnd(CameraCtrlWrap.GetCameraContainerPosition(), destPos)
    self:setLookAtMoveStartAndEnd(CameraCtrlWrap.GetLookAt(), destLookAtPos)
    self:setMoveTimeInfo(TimeWrap.GetUnscaledTime(), 0.7)
end

function CameraCtrlCore:onFingerRotate(fingerMoveDeltaPosition)
    local centerVec = self.manualOperateViewStartPlayerPosition + Vector2.Normalize(self.viewCenterPosition - self.manualOperateViewStartPlayerPosition) * (12 + math.abs(self.manualOperateViewStartPlayerPosition.x) * 0.1) - self.manualOperateViewStartPlayerPosition

    local originLookAtVector = CameraCtrlWrap.GetDestLookAtPos() - self.manualOperateViewStartPlayerPosition
    local originAngle = Vector2.Angle(Vector2(originLookAtVector.x, originLookAtVector.z), Vector2(centerVec.x, centerVec.z))

    CameraCtrlWrap.SetDestLookAtPos(self.manualOperateViewStartPlayerPosition + rotateXZ(CameraCtrlWrap.GetDestLookAtPos() - self.manualOperateViewStartPlayerPosition, -fingerMoveDeltaPosition.x * 0.08))

    local maxAngle = 150
    local mostRightLookAtPosition = self.manualOperateViewStartPlayerPosition + rotateXZ(centerVec, -maxAngle)
    local mostLeftLookAtPosition = self.manualOperateViewStartPlayerPosition + rotateXZ(centerVec, maxAngle)

    local destVector = CameraCtrlWrap.GetDestLookAtPos() - self.manualOperateViewStartPlayerPosition
    local angle = Vector2.Angle(Vector2(destVector.x, destVector.z), Vector2(centerVec.x, centerVec.z))

    if angle > maxAngle and angle > originAngle then
        CameraCtrlWrap.SetDestLookAtPos(fingerMoveDeltaPosition.x < 0 and mostLeftLookAtPosition or mostRightLookAtPosition)
    end

    CameraCtrlWrap.SetDestPos(calculateCameraBehindPosition(self.manualOperateViewStartPlayerPosition, CameraCtrlWrap.GetDestLookAtPos(), -0.4 * math.abs(self.manualOperateViewStartPlayerPosition.x) + 40, -0.25 * math.abs(self.manualOperateViewStartPlayerPosition.x) + 17))
end

function CameraCtrlCore:onManualOperateViewDribble(segment, isNextActionDribble)
    if math.cmpf(segment.Time, 0.1) > 0 then
        CameraCtrlWrap.SetIsCameraFollowPlayer(false)
        self:forceSwitchCamera()

        local destPos
        local destLookAt
        if isNextActionDribble or math.cmpf(segment.Time, 0.5) > 0 then
            destPos = calculateCameraBehindPosition(segment["end"], self.shootTargetGate, 22, 3)
            destLookAt = (segment["end"] + self.shootTargetGate ) / 2
            CameraCtrlWrap.EnqueueCameraMoveAction(CameraCtrlWrap.GetCameraContainerPosition(), destPos,
                CameraCtrlWrap.GetLookAt(), destLookAt, segment.Time / 2, 0, self.parameters.defaultFieldOfView)
        else
            destPos = CameraCtrlWrap.GetCameraContainerPosition() + segment["end"] - segment["start"]
            destLookAt = CameraCtrlWrap.GetLookAt() + segment["end"] - segment["start"]
            CameraCtrlWrap.EnqueueCameraMoveAction(CameraCtrlWrap.GetCameraContainerPosition(), destPos,
                CameraCtrlWrap.GetLookAt(), destLookAt, segment.Time, 0, self.parameters.defaultFieldOfView)
        end
    end
end

function CameraCtrlCore:onManualOperateViewPrepass(segment)
    if math.cmpf(segment.Time, 0.1) > 0 then
        CameraCtrlWrap.SetIsCameraFollowPlayer(false)

        self:forceSwitchCamera()

        local destPos = CameraCtrlWrap.GetCameraContainerPosition() + segment["end"] - segment["start"]
        local destLookAt = CameraCtrlWrap.GetLookAt() + segment["end"] - segment["start"]
        CameraCtrlWrap.EnqueueCameraMoveAction(CameraCtrlWrap.GetCameraContainerPosition(), destPos,
            CameraCtrlWrap.GetLookAt(), destLookAt, segment.Time, 0, self.parameters.defaultFieldOfView)
    end
end

function CameraCtrlCore:onManualOperateViewPass(segment)
    CameraCtrlWrap.SetIsCameraFollowPlayer(false)
    self:forceSwitchCamera()
    local destPos = CameraCtrlWrap.GetCameraContainerPosition() + segment["end"] - segment["start"]
    -- 问题:边路传球战术情况下，容易出现摄像机追不上传球人的情况
    -- 解决:传球动作开始时判断球的目标点是否在当前屏幕内，如果不在则加快摄像机位移速度
    local pos = segment["end"]
    local viewPos = Camera.main:WorldToViewportPoint(pos)
    local moveDuration = segment.Time
    if viewPos.x < 0 or viewPos.x > 1 or viewPos.y < 0 or viewPos.y > 1 then
        moveDuration = segment.Time * 0.5
    end
    
    CameraCtrlWrap.EnqueueCameraMoveAction(CameraCtrlWrap.GetCameraContainerPosition(), destPos,
        CameraCtrlWrap.GetLookAt(), segment["end"], moveDuration, 0, self.parameters.defaultFieldOfView)
end

function  CameraCtrlCore:setBroadcast(broadcast)
    self.broadcastSpot = broadcast
end

function  CameraCtrlCore:isBroadcast(broadcast)
    return self.broadcastSpot == broadcast
end

function CameraCtrlCore:checkBroadcastSpotSwitch(segment)
    local fraction = (TimeWrap.GetUnscaledTime() - CameraCtrlWrap.GetStartTime()) / CameraCtrlWrap.GetMoveDuration()
    if (not CameraCtrlWrap.GetIsCameraFollowPlayer() and not CameraCtrlWrap.GetIsCameraDefollowPlayer())
        and not self:isBroadcast(BroadcastSpot.MainSpot)
        and not self:isBroadcast(BroadcastSpot.PlayBackNormal)
        and not self:isBroadcast(BroadcastSpot.PlayBackSpecial)
        and not self:isBroadcast(BroadcastSpot.PlayBackGoalView)
        and CameraCtrlWrap.GetCameraMoveActionCount() == 0 and math.cmpf(fraction, 1) > 0 then
        self:checkBallPosition(segment)
    end
end

function CameraCtrlCore:checkBallPosition(segment)
    if not self:isBroadcast(MainSpot) then
        self:changeBroadcastSpot(self.parameters.mainBroadcastSpot, segment)
        self:setBroadcast(BroadcastSpot.MainSpot)
    end
end

function CameraCtrlCore:changeBroadcastSpot(cameraPosition, segment)
    local originPos = Vector3(math.max(self.parameters.minXValue, BallActionExecutorWrap.GetBallPosition().x - self.parameters.standardXDistance),
        cameraPosition.y, math.min(math.max(BallActionExecutorWrap.GetBallPosition().z, -self.parameters.maxZOffset), self.parameters.maxZOffset))
    local destPos = Vector3(math.max(self.parameters.minXValue, segment["end"].x - self.parameters.standardXDistance),
        cameraPosition.y, math.min(math.max(segment["end"].z, -self.parameters.maxZOffset), self.parameters.maxZOffset))

    local ballMoveDistance = Vector3.Distance(segment["start"], segment["end"])
    local moveDuration = math.cmpf(ballMoveDistance, 0) > 0 and Vector3.Distance(BallActionExecutorWrap.GetBallPosition(), segment["end"]) / ballMoveDistance * segment.Time or 1

    local rotateXZAngle = GameHubWrap.IsFromLeftToRight() and -self.defaultHorizontalFOV / 4 or self.defaultHorizontalFOV / 4

    local originLookAtPos = originPos + rotateXZ(BallActionExecutorWrap.GetBallPosition() - originPos, rotateXZAngle)
    originLookAtPos = Vector3(math.clamp(originLookAtPos.x, self.parameters.lookAtMinXValue, self.parameters.lookAtMaxXValue), originLookAtPos.y, originLookAtPos.z)

    local destLookAtPos = destPos + rotateXZ(segment["end"] - destPos, rotateXZAngle)
    destLookAtPos = Vector3(math.clamp(destLookAtPos.x, self.parameters.lookAtMinXValue, self.parameters.lookAtMaxXValue), destLookAtPos.y, destLookAtPos.z)

    self:forceSwitchCamera()
    CameraCtrlWrap.EnqueueCameraMoveAction(originPos, destPos,
                originLookAtPos, destLookAtPos, moveDuration, 0, self.parameters.defaultFieldOfView)
end

function CameraCtrlCore:modifyDefaultFov(fov)
    self.preDefaultFov = self.parameters.defaultFieldOfView
    self.parameters.defaultFieldOfView = fov
    CameraCtrlWrap.SetCameraFov(fov)
end

function CameraCtrlCore:resetDefaultFov()
    if self.preDefaultFov then
        self.parameters.defaultFieldOfView = self.preDefaultFov
    end
end

return CameraCtrlCore
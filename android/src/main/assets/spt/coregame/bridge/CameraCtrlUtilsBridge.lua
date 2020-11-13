function CameraCtrlUtilsBridge_OnBallActionStart(segment)
    ___cameraCtrlCore:onBallActionStart(segment)
end

function CameraCtrlUtilsBridge_SetNormalPlayBackBroadcast()
    ___cameraCtrlCore:setNormalPlayBackBroadcast()
end

function CameraCtrlUtilsBridge_SetCameraByMatchEvent(eventType, ballOwner)
    ___cameraCtrlCore:setCameraByMatchEvent(eventType, ballOwner)
end

function CameraCtrlUtilsBridge_SetPlayBackCameraByMatchEvent(eventType, ballOwner)
    ___cameraCtrlCore:setPlayBackCameraByMatchEvent(eventType, ballOwner)
end

function CameraCtrlUtilsBridge_OnShootViewStart(ballPositionOnShoot, playerPositionOnShoot)
    ___cameraCtrlCore:onShootViewStart(ballPositionOnShoot, playerPositionOnShoot)
end

function CameraCtrlUtilsBridge_OnShootViewEnd(shootResult)
    ___cameraCtrlCore:onShootViewEnd(shootResult)
end

function CameraCtrlUtilsBridge_CheckBroadcastSpotSwitch(segment)
    ___cameraCtrlCore:checkBroadcastSpotSwitch(segment)
end

function CameraCtrlUtilsBridge_OnManualOperateViewStart(manualPlayerPosition, action)
    ___cameraCtrlCore:onManualOperateViewStart(manualPlayerPosition, action)
end

function CameraCtrlUtilsBridge_OnManualOperateViewPass(segment)
    ___cameraCtrlCore:onManualOperateViewPass(segment)
end

function CameraCtrlUtilsBridge_OnManualOperateViewPrepass(segment)
    ___cameraCtrlCore:onManualOperateViewPrepass(segment)
end

function CameraCtrlUtilsBridge_OnManualOperateViewDribble(segment, isNextActionDribble)
    ___cameraCtrlCore:onManualOperateViewDribble(segment, isNextActionDribble)
end

function CameraCtrlUtilsBridge_OnFingerRotate(fingerMoveDeltaPosition)
    ___cameraCtrlCore:onFingerRotate(fingerMoveDeltaPosition)
end
local TrainShootCamera = class(unity.base)

local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local Time = UnityEngine.Time
local TrailRenderer = UnityEngine.TrailRenderer

local EventSystem = require("EventSystem")

local TrainConst = require("training.TrainConst")

-- /**
--  * CounterClockWise XZ rotation
--  * */
local function RotateXZ(v, degreeAngle)
    local radiusAngle = math.rad(degreeAngle)
    
    local ca = math.cos(radiusAngle)
    local sa = math.sin(radiusAngle)
    
    return Vector3(v.x * ca - v.z * sa, v.y, v.x * sa + v.z * ca)
end

-- /**
--  * CounterClockWise YZ rotation
--  * */
local function RotateYZ(v, degreeAngle)
    local radiusAngle = math.rad(degreeAngle)
    
    local ca = math.cos(radiusAngle)
    local sa = math.sin(radiusAngle)
    
    return Vector3(v.x, v.y * ca - v.z * sa, v.y * sa + v.z * ca)
end

local function GetJudgeXZ(p0, p1, p2)
    return (p2.x - p1.x) * (p0.z - p1.z) - (p2.z - p1.z) * (p0.x - p1.x)
end

local function GetJudgeYZ(p0, p1, p2)
    return (p2.y - p1.y) * (p0.z - p1.z) - (p2.z - p1.z) * (p0.y - p1.y)
end


function TrainShootCamera:ctor()
    self.cameraCtrl = self.___ex.cameraCtrl
    self.ball = self.___ex.ball

    self.FOV = 25
    self.lookAt = Vector3.zero
    self.originLookAtPos = Vector3.zero
    local radAngle = math.rad(self.FOV)
    local radHFOV = 2 * math.atan(math.tan(radAngle / 2) * self.cameraCtrl.aspect)
    self.horizontalFOV = math.deg(radHFOV)
    self.isFromLeftToRight = true
    
    EventSystem.AddEvent("training_ball_action_start", self, self.OnNewBallActionStarted)
    EventSystem.AddEvent("training_ball_action_complete", self, self.OnBallActionCompleted)
    EventSystem.AddEvent("training_change_broadcast_spot", self, self.ChangeBroadcastSpot)
    EventSystem.AddEvent("training_camera_follow_when_shoot", self, self.OnFollowPlayerOnShoot)
    EventSystem.AddEvent("training_camera_defollow_when_shoot", self, self.OnDefollowPlayerOnShoot)
    EventSystem.AddEvent("training_ball_trail_start", self, self.OnShootTrailStart)
end

function TrainShootCamera:start()
end

function TrainShootCamera:onDestroy()
    EventSystem.RemoveEvent("training_ball_action_start", self, self.OnNewBallActionStarted)
    EventSystem.RemoveEvent("training_ball_action_complete", self, self.OnBallActionCompleted)
    EventSystem.RemoveEvent("training_change_broadcast_spot", self, self.ChangeBroadcastSpot)
    EventSystem.RemoveEvent("training_camera_follow_when_shoot", self, self.OnFollowPlayerOnShoot)
    EventSystem.RemoveEvent("training_camera_defollow_when_shoot", self, self.OnDefollowPlayerOnShoot)
    EventSystem.RemoveEvent("training_ball_trail_start", self, self.OnShootTrailStart)
end

function TrainShootCamera:InLeftOneThirdView(position)
    local leftBoardPoint = self.destPos + RotateXZ(self.lookAt - self.destPos, self.horizontalFOV / 2)
    local rightBoardPoint = self.destPos + RotateXZ(self.lookAt - self.destPos, self.horizontalFOV / 6)
    
    local judge1 = GetJudgeXZ(position, self.destPos, leftBoardPoint)
    local judge2 = GetJudgeXZ(position, self.destPos, rightBoardPoint)
    
    return judge1 <= 0 and judge2 >= 0
end

function TrainShootCamera:InRightOneThirdView(position)
    local leftBoardPoint = self.destPos + RotateXZ(self.lookAt - self.destPos, -self.horizontalFOV / 6)
    local rightBoardPoint = self.destPos + RotateXZ(self.lookAt - self.destPos, -self.horizontalFOV / 2)
    
    local judge1 = GetJudgeXZ(position, self.destPos, leftBoardPoint)
    local judge2 = GetJudgeXZ(position, self.destPos, rightBoardPoint)
    
    return judge1 <= 0 and judge2 >= 0
end

function TrainShootCamera:InCentralVerticalPos(position)
    local downBoardPoint = self.destPos + RotateYZ(self.lookAt - self.destPos, FOV / 6)
    local upBoardPoint = self.destPos + RotateYZ(self.lookAt - self.destPos, -FOV / 6)
    
    local judge1 = GetJudgeYZ(position, self.destPos, downBoardPoint)
    local judge2 = GetJudgeYZ(position, self.destPos, upBoardPoint)
    
    return judge1 <= 0 and judge2 >= 0
end

function TrainShootCamera:OnShootTrailStart()
    self.ball:GetComponent(TrailRenderer).time = 5
end

function TrainShootCamera:OnNewBallActionStarted(action)
    if action.time > 0.1 then -- && manager.broadcastSpot != BroadcastSpot.Special && manager.broadcastSpot != BroadcastSpot.BaseLineSpot then
        local cameraXToChange = math.abs(action.destination.x - self.cameraCtrl.transform.position.x) > TrainConst.MAIN_BROADCAST_SPOT_RESP0NSE_Y_OFFSET
        local cameraZToChange = math.abs(action.destination.z - self.cameraCtrl.transform.position.z) > TrainConst.MAIN_BROADCAST_SPOT_STANDARD_Z_DISTANCE + TrainConst.MAIN_BROADCAST_SPOT_Z_DISTANCE_TOLERANCE or math.abs(action.destination.z - self.cameraCtrl.transform.position.z) < TrainConst.MAIN_BROADCAST_SPOT_STANDARD_Z_DISTANCE - TrainConst.MAIN_BROADCAST_SPOT_Z_DISTANCE_TOLERANCE
        -- if (manager.broadcastSpot == BroadcastSpot.MainSpot && (cameraXToChange || cameraZToChange)) then
        if cameraXToChange or cameraZToChange then
            self.originPos = self.cameraCtrl.transform.position
            
            local destX = self.cameraCtrl.transform.position.x
            if (cameraXToChange) then
                destX = math.min(math.max(action.destination.x, -TrainConst.MAIN_BROADCAST_SPOT_MAX_X_OFFSET), TrainConst.MAIN_BROADCAST_SPOT_MAX_X_OFFSET)
            end
            
            local destZ = self.cameraCtrl.transform.position.z
            if cameraZToChange then
                destZ = math.max(TrainConst.MAIN_BROADCAST_SPOT_MIN_Z_VALUE, action.destination.z - TrainConst.MAIN_BROADCAST_SPOT_STANDARD_Z_DISTANCE)
            end
            
            self.destPos = Vector3(destX, self.cameraCtrl.transform.position.y, destZ) 
            
            self.startTime = Time.time
        end
        
        if self.isFromLeftToRight then
            if not self:InLeftOneThirdView(action.destination) or not self:InCentralVerticalPos(action.destination) then
                self.originLookAtPos = self.lookAt
                
                self.destLookAtPos = self.destPos + RotateXZ(action.destination - self.destPos, -self.horizontalFOV / 4)
                self.startTime = Time.time
            end
        else
            if not self:InRightOneThirdView(action.destination) or not self:InCentralVerticalPos(action.destination) then
                self.originLookAtPos = self.lookAt
                
                self.destLookAtPos = self.destPos + RotateXZ(action.destination - self.destPos, self.horizontalFOV / 4)
                self.startTime = Time.time
            end
        end
    end
end

function TrainShootCamera:OnBallActionCompleted()
    -- ball = manager.Ball
    self.ball:GetComponent(TrailRenderer).time = 0
end

function TrainShootCamera:ChangeBroadcastSpot(cameraPosition, ballAction)
    if cameraPosition == TrainConst.MAIN_BROADCAST_SPOT then
        self.originPos = Vector3(math.min(math.max(self.ball.transform.position.x, -TrainConst.MAIN_BROADCAST_SPOT_MAX_X_OFFSET), TrainConst.MAIN_BROADCAST_SPOT_MAX_X_OFFSET),
                                    cameraPosition.y, math.max(TrainConst.MAIN_BROADCAST_SPOT_MIN_Z_VALUE, self.ball.transform.position.z - TrainConst.MAIN_BROADCAST_SPOT_STANDARD_Z_DISTANCE))
        self.destPos = Vector3(math.min(math.max(ballAction.destination.x, -TrainConst.MAIN_BROADCAST_SPOT_MAX_X_OFFSET),TrainConst.MAIN_BROADCAST_SPOT_MAX_X_OFFSET),
                                  cameraPosition.y, math.max(TrainConst.MAIN_BROADCAST_SPOT_MIN_Z_VALUE, ballAction.destination.z - TrainConst.MAIN_BROADCAST_SPOT_STANDARD_Z_DISTANCE))
    else
        self.cameraCtrl.transform.position = cameraPosition
        self.originPos = self.cameraCtrl.transform.position
        self.destPos = self.cameraCtrl.transform.position
    end

    if self.isFromLeftToRight then
        self.originLookAtPos = self.originPos + RotateXZ(self.ball.position - self.originPos, -self.horizontalFOV / 4)
        self.destLookAtPos = self.destPos + RotateXZ(ballAction.destination - self.destPos, -self.horizontalFOV / 4)
    else
        self.originLookAtPos = self.originPos + RotateXZ(self.ball.position - self.originPos, self.horizontalFOV / 4)
        self.destLookAtPos = self.destPos + RotateXZ(ballAction.destination - self.destPos, self.horizontalFOV / 4)
    end
    
    self.startTime = Time.time
    self.time = ballAction.time + ballAction.startTime - self.startTime
    
    dump(self.originLookAtPos)
    self.lookAt = self.originLookAtPos
    self.cameraCtrl.transform:LookAt(self.lookAt)
    
    -- manager.broadcastSpotLastTime = 0.0
end

function TrainShootCamera:OnFollowPlayerOnShoot(player, playerDestination, shootPosition, moveTime)
    local tmpAngle = 150
    self.shootTargetGate = self.isFromLeftToRight and TrainConst.GATE1 or TrainConst.GATE2
    -- manager.bro adcastSpot = BroadcastSpot.Special
    self.originPos = self.cameraCtrl.transform.position

    local tmpLookAt = Vector3(self.shootTargetGate.x, 0, self.shootTargetGate.z)
    local tmpPlayerDest = Vector3(shootPosition.x, 0, shootPosition.z)

    local sideAngleProportion = 1 / 8
    local centralAngleProportion = 0.5 - sideAngleProportion
    local shootDistance = Vector2.Distance(Vector2(playerDestination.x, playerDestination.z), Vector2(self.shootTargetGate.x, self.shootTargetGate.z))
    local gamma = math.rad(tmpAngle + 0.3 * shootDistance)

    local a = math.atan((2.44 - shootPosition.y) / shootDistance)
    local beta = gamma - a
    local alpha = math.pi - gamma
    local distanceBehind = Vector3.Distance(shootPosition, Vector3(self.shootTargetGate.x, 2.44, 0)) * math.sin(math.pi / 2 - alpha) * math.sin(math.pi - beta - 2 * centralAngleProportion * math.rad(self.FOV)) / math.sin(2 * centralAngleProportion * math.rad(self.FOV))
    local distanceHeightBehind = shootPosition.y + distanceBehind / math.tan(math.pi / 2 - alpha)
    local lookAtDistanceFoward = distanceBehind * math.sin(centralAngleProportion * math.rad(self.FOV)) / math.sin(math.pi - beta - centralAngleProportion * math.rad(self.FOV)) / math.sin(math.pi / 2 - alpha)
    
    local one = (tmpPlayerDest - tmpLookAt).normalized
    self.destPos = tmpPlayerDest + one * distanceBehind
    self.destPos.y = distanceHeightBehind
    
    self.originLookAtPos = self.lookAt
    self.destLookAtPos = shootPosition + (Vector3(self.shootTargetGate.x, 2.44, 0) - shootPosition).normalized * lookAtDistanceFoward

    self.cameraCtrl.transform.position = self.destPos
    self.cameraCtrl.transform:LookAt (self.destLookAtPos)

    self.startTime = Time.time
    self.time = 5 - self.startTime
end

function TrainShootCamera:OnDefollowPlayerOnShoot()
    local tmpLookAt = Vector3(self.shootTargetGate.x, 0, self.shootTargetGate.z)
    local tmpCameraPos = Vector3(self.cameraCtrl.transform.position.x, 0, self.cameraCtrl.transform.position.z)
    local one = (tmpCameraPos - tmpLookAt).normalized
    self.destPos = tmpCameraPos + one * TrainConst.CAMERA_DEFOLLOW_DISTANCE_BEHIND
    self.destPos.y = TrainConst.CAMERA_DEFOLLOW_HEIGHT_BEHIND
    self.originPos = self.cameraCtrl.transform.position
    self.originLookAtPos = self.lookAt
    self.destLookAtPos = self.shootTargetGate

    self.startTime = Time.time
end

return TrainShootCamera

local TrainBall = class(unity.base)

local EventSystem = require("EventSystem")

local TrainConst = require("training.TrainConst")

local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local Mathf = UnityEngine.Mathf
local Time = UnityEngine.Time
local SphereCollider = UnityEngine.SphereCollider
local Quaternion = UnityEngine.Quaternion
local Rigidbody = UnityEngine.Rigidbody

local Tweening = clr.DG.Tweening
local DOTween = Tweening.DOTween
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease
local LoopType = Tweening.LoopType

local BallStatus = {
    idle = 1,
    pass = 2,
    dribble = 3,
    shoot = 4,
    special_effect = 5
}

local BallActionStatus = {
    running = 1,
    suspend = 2,
    stop = 3
}

local UNIFORMLY_RETARDED_ACCELERATION = 0.5
local WIND_DRAG_COEFFICIENT = -1.25
local GRAVITY = 58
local E = 2.718

local function easeUniformlyRetardedMotion(s, e, value)
    local v0 = 2 * (e - s) / (1 + UNIFORMLY_RETARDED_ACCELERATION)
    local a = v0 * (1 - UNIFORMLY_RETARDED_ACCELERATION)
    return v0 * value - 0.5 * a * value * value + s
end

local function easeWindDragMove(s, e, value)
    local v0 = (e - s) * WIND_DRAG_COEFFICIENT / (math.pow(E, WIND_DRAG_COEFFICIENT) - 1)
    return v0 * (math.pow(E, WIND_DRAG_COEFFICIENT * value) - 1) / WIND_DRAG_COEFFICIENT + s
end

local function easeVerticalUpwardProjectileSmall(s, e, value)
    local accelerate = GRAVITY * 0.15
    local v0 = e - s + accelerate
    return v0 * value - accelerate * value * value + s
end

local function RandomRangeInt(min, max)
    return math.random(min, max)
end

local function RandomRangeFloat(min, max)
    return min + math.random() * (max - min)
end

local function GetProjectOnGround(vec) 
    return Vector3(vec.x, 0, vec.z)
end

function TrainBall:ctor()
    self.goalLowerLeftCorner = self.___ex.goalLowerLeftCorner

    self.isRotate = false
    self.actions = {}
    self.currentAction = nil
    self.runningStatus = BallActionStatus.stop
    self.ballStatus = BallStatus.idle
end

function TrainBall:update()

    self:ApplyBallAction()
    self:JudgeGoal()
end

function TrainBall:ShootBall(point, t, isJudgeOvertime)
    local selfTrans = self.gameObject.transform
    local v = Vector3((point.x - selfTrans.position.x) / t, (point.y - selfTrans.position.y) / t + 10 * t / 2, (point.z - selfTrans.position.z) / t)
    
    self.gameObject:GetComponent(Rigidbody).isKinematic = false
    self.gameObject:GetComponent(Rigidbody).velocity = v

    if isJudgeOvertime then
        self:coroutine(function()
            local startTime = Time.time
            while true do
                coroutine.yield(clr.UnityEngine.WaitForSeconds(0.1))
                if self.isRoundOver then
                    self.isRoundOver = false
                    break
                end
                if Time.time - startTime > 5 then
                    EventSystem.SendEvent("training_try_success")
                    break
                end
            end
        end)
    end
end

function TrainBall:StartRotate()
    self.isRotate = true
end

function TrainBall:EndRotate()
    self.isRotate = false
end

function TrainBall:AddBallAction(action)
    if type(action) == "table" then
        table.insert(self.actions, action)
        -- self:UpdateBallPossesser(action) -- unuseful
    end
end

function TrainBall:SkipCurrentAction()
    if self.runningStatus == BallActionStatus.running and #self.actions > 0 then
        self.currentAction = table.remove(self.actions)
        self.runningStatus = BallActionStatus.suspend
    end
end

function TrainBall:ClearApplyMove()
    self.applyMove = nil
end

function TrainBall:ApplyBallAction()
    if self.runningStatus == BallActionStatus.stop then
        if #self.actions > 0 then
            self.currentAction = table.remove(self.actions)
            self.runningStatus = BallActionStatus.suspend
        end
    end
    if self.runningStatus == BallActionStatus.suspend then
        if self.currentAction and Time.time > self.currentAction.startTime then
            self:StartBallAction(self.currentAction)
        end
    end
    if self.runningStatus == BallActionStatus.running then
        self:ApplyBallActionOnRunning()
        -- if (manager.changeBroadcastSpot != null && (manager.broadcastSpotLastTime >= ConfigConstants.LEAST_BROADCAST_LAST_TIME
        --     && manager.broadcastSpot != BroadcastSpot.Special))
        -- {
        --     if (manager.broadcastSpot != BroadcastSpot.BaseLineSpot)
        --     {
        --         CheckBallPosition()
        --     }
        --     else if (manager.broadcastSpotLastTime >= mainCamera:GetComponent<CameraCtl6>().goalKeeperKickOffLastTime)
        --     {
        --         CheckBallPosition()
        --     }
            
        -- }
        self:CheckBallActionExecution()
    end
end

function TrainBall:ApplyBallActionOnRunning()
    if self.ballStatus == BallStatus.dribble then
        if type(self.applyMove) == "function" then
            self:applyMove()
        end
    else
        self:UpdatePercent()
        if type(self.applyMove) == "function" then
            self:applyMove()
        end
    end
end

function TrainBall:CheckBallActionExecution()
    if Time.time - self.currentAction.startTime >= self.currentAction.time then
        self:OnBallActionCompleted(self.currentAction)
        EventSystem.SendEvent("training_ball_action_complete", self.currentAction)
    end
end

function TrainBall:StartBallAction(action)
    self:GenerateMove(action)
    self.runningStatus = BallActionStatus.running
    EventSystem.SendEvent("training_ball_action_start", self.currentAction)
end

function TrainBall:OnBallActionCompleted(action)
    self.runningStatus = BallActionStatus.stop
    -- if action.type == "BallShoot" then
        EventSystem.SendEvent("training_camera_defollow_when_shoot")
    -- end
end

function TrainBall:UpdatePercent()
    if Time.time - self.moveStartTime >= self.moveTime then
        self.percent = 1
    elseif Time.time <= self.moveStartTime then
        self.percent = 0
    else
        self.percent = (Time.time - self.moveStartTime) / self.moveTime
    end
end

function TrainBall:GenerateMove(action)
    if action.type == "BallPass" then
        self.moveOrigin = self.transform.position
        self.moveDestination = action.destination
        self.moveTime = action.time
        self.moveStartTime = action.startTime

        self.originProjectOnGround = GetProjectOnGround(self.moveOrigin)
        self.destinationProjectOnGround = GetProjectOnGround(self.moveDestination)

        self.rotateAxis = Vector3.Cross(Vector3.up, (self.destinationProjectOnGround - self.originProjectOnGround))

        if action.passType == 1 then
            self.applyMove = function()
                local pos = self.transform.position
                pos.x = easeUniformlyRetardedMotion(self.moveOrigin.x, self.moveDestination.x, self.percent)
                pos.y = TrainConst.BALL_RADIUS
                pos.z = easeUniformlyRetardedMotion(self.moveOrigin.z, self.moveDestination.z, self.percent)
                self.transform.position = pos
                self.transform.rotation = Quaternion.AngleAxis(TrainConst.DEFAULT_BALL_ROTATE_ANGLE_PER_FRAME * Time.timeScale * self.percent, self.rotateAxis) * self.transform.rotation
            end
        elseif action.passType == 2 then
            self.applyMove = function()
                local pos = self.transform.position

                pos.x = easeWindDragMove(self.moveOrigin.x, self.moveDestination.x, self.percent)
                pos.y = easeVerticalUpwardProjectileSmall(self.moveOrigin.y, self.moveDestination.y, self.percent)
                pos.z = easeWindDragMove(self.moveOrigin.z, self.moveDestination.z, self.percent)

                self.transform.position = pos

                self.transform.rotation = Quaternion.AngleAxis(TrainConst.DEFAULT_BALL_ROTATE_ANGLE_PER_FRAME * 0.2 * Time.timeScale, -self.rotateAxis) * self.transform.rotation
            end
        end

        self.ballStatus = BallStatus.pass
    elseif action.type == "BallShoot" then
        self.moveOrigin = self.transform.position
        self.moveDestination = action.destination
        self.moveProjectedOrigin = action.projectedOrigin
        self.moveProjectedControl = action.projectedControl
        self.moveProjectedDestination = action.projectedDestination
        self.moveTime = action.time
        self.moveStartTime = Time.time

        self.originProjectOnGround = GetProjectOnGround(self.moveOrigin)
        self.destinationProjectOnGround = GetProjectOnGround(self.moveDestination)

        self.rotateAxis = Vector3.Cross(Vector3.up, (self.destinationProjectOnGround - self.originProjectOnGround))

        -- case BallShoot.ShootType.finger_shoot:
        local v = Vector3(0, (self.moveDestination.y - self.moveOrigin.y) / self.moveTime + 10 * self.moveTime / 2, 0)

        self:GetComponent(Rigidbody).isKinematic = false
        self:GetComponent(Rigidbody).velocity = v

        self.gameObject:GetComponent(SphereCollider).radius = 0.11

        self.lastPosition = self:GetComponent(Rigidbody).position

        self.applyMove = function()
            local u = self.percent
            local v = 1 - u

            -- //set velocity
            if (self.percent < 1 - 1e-6) then
                -- //set position
                local position = Vector3(
                    (v * v * self.moveProjectedOrigin.x) + (2 * v * u * self.moveProjectedControl.x) + (u * u * self.moveProjectedDestination.x),
                    self:GetComponent(Rigidbody).position.y,
                    (v * v * self.moveProjectedOrigin.z) + (2 * v * u * self.moveProjectedControl.z) + (u * u * self.moveProjectedDestination.z)
                )

                self:GetComponent(Rigidbody).position = position

                local velocity = (position - self.lastPosition) / Time.deltaTime
                velocity.y = 0

                if (velocity.sqrMagnitude >= 1e-6) then
                    self:GetComponent(Rigidbody).velocity = Vector3(velocity.x, self:GetComponent(Rigidbody).velocity.y, velocity.z)
                end

                -- //store state
                self.lastPosition = position
            end
        end

        self.ballStatus = BallStatus.shoot
    elseif action.type == "BallSpecialEffect" then
        self.moveOrigin = self.transform.position
        self.moveDestination = action.destination
        self.moveTime = action.time
        self.moveStartTime = action.startTime
        self.applyMove = function()
            local pos = self.transform.position

            pos.x = math.lerp(self.moveOrigin.x, self.moveDestination.x, self.percent)
            pos.y = math.lerp(self.moveOrigin.y, self.moveDestination.y, self.percent)
            pos.z = math.lerp(self.moveOrigin.z, self.moveDestination.z, self.percent)

            self.transform.position = pos
        end

        self.ballStatus = BallStatus.special_effect
    end
end


function TrainBall:StartShoot()
    self.hasStartedShoot = true
    self.shootStartTime = Time.time
end

function TrainBall:EndShoot()
    self.hasStartedShoot = false
    self.isShooted = false
end

function TrainBall:JudgeBallOverBaseLine()
    return self.transform.position.x >= TrainConst.PIT_LENGTH_HALF or self.transform.position.x <= -TrainConst.PIT_LENGTH_HALF
end

function TrainBall:JudgeBallWithInGate()
    return self.transform.position.y < TrainConst.GOAL_CROSSBAR_HEIGHT and self.transform.position.z < TrainConst.GOAL_POST_DISTANCE_HALF and self.transform.position.z > -TrainConst.GOAL_POST_DISTANCE_HALF
end

function TrainBall:JudgeGoal()
    if self.hasStartedShoot and not self.isShooted then
        if self:JudgeBallOverBaseLine() then
            self.isShooted = true
            if self:JudgeBallWithInGate() then
                EventSystem.SendEvent("training_try_success")
            else
                EventSystem.SendEvent("training_try_failed")
            end
        elseif Time.time > self.shootStartTime + 5 then
            self.isShooted = true
            EventSystem.SendEvent("training_try_failed")
        end
    end
end

function TrainBall:NotifyGoal(isGoal)
    if isGoal then
        EventSystem.SendEvent("training_try_success")
    else
        EventSystem.SendEvent("training_try_failed")
    end
    EventSystem.SendEvent("training_ball_action_complete")
end

local leftPoint = Vector3(52, 0.1, 20)
local rightPoint = Vector3(52, 0.1, -20)

function TrainBall:OnTriggerEnter(selfObj, otherObj)
    local isGoal = false
    if self.hasStartedShoot and not self.isShooted then
        local otherName = clr.unwrap(otherObj.name)
        if string.find(otherName, "body") == 1 or string.find(otherName, "gloves") == 1 or string.find(otherName, "Wall") == 1 then
            self.isShooted = true
            self:GetComponent(Rigidbody).isKinematic = true

            local adjustedLowerLeftCorner = Vector3(self.goalLowerLeftCorner.position.x, 0, self.goalLowerLeftCorner.position.z + 10)
            local flyVector = adjustedLowerLeftCorner - self.transform.position
            local target = self.transform.position

            local isTrainGoal = false
            if type(self.getGoal) == "function" then
                isTrainGoal = tobool(self.getGoal())
            end
            if isTrainGoal == true and (string.find(otherName, "body") == 1 or string.find(otherName, "gloves") == 1) then
                flyVector = Vector3(57, 1, RandomRangeFloat(-2, 2)) - self.transform.position
                isGoal = true
            end

            if self.transform.position.z < 0 then
                flyVector.z = -flyVector.z
            end
            flyVector = 2 * flyVector
            target = self.transform.position + flyVector
            target.y = 0.1
            target.x = target.x - 1

            -- local target
            -- if math.random(2) == 1 then
            --     target = leftPoint
            -- else
            --     target = rightPoint
            -- end

            local flyOut = {
                ["type"] = "BallSpecialEffect",
                origin = otherObj.transform.position,
                destination = target,
                startTime = Time.time,
                time = 0.5
            }

            -- GameManager.GetInstance():submitNewBallActionFunc(flyOut)  --Lua assist checked flag
            self:AddBallAction(flyOut)
            -- GameManager.GetInstance():skipCurrentBallActionFunc()  --Lua assist checked flag
            self:SkipCurrentAction()
            -- GameManager.GetInstance():startCameraDefollowPlayerOnShoot()  --Lua assist checked flag
            EventSystem.SendEvent("training_camera_defollow_when_shoot")

            self:NotifyGoal(isGoal)
        end
    end
end

return TrainBall

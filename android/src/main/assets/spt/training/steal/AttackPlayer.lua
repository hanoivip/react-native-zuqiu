local AttackPlayer = class(unity.base)

local StealEventType = require("training.steal.StealEventType")

local UnityEngine = clr.UnityEngine
local Quaternion = UnityEngine.Quaternion
local Vector3 = UnityEngine.Vector3
local CapsUnityLuaBehav = clr.CapsUnityLuaBehav
local Time = UnityEngine.Time

local IdleState = "Idle"
local RunState = "Run"
local RunState1 = "Run1"
local StopState = "StopBall"
local HoldingBall = "HoldingBall"
local HoldingBall1 = "HoldingBall1"
local ShootState = "Shoot"
local ActionName1 = "001_1"
local ActionName2 = "001_2"
local ActionName3 = "C_S004"

-- 001_1#(0.0, 0.0, 6.4)#1.073789#(0.0, 0.0, 0.0, 1.0)
-- 001_2#(0.0, 0.0, 6.6)#0.9727898#(0.0, 0.0, 0.0, 1.0)#(0.1, 0.1, 2.0)#0.2097368#(0.0, 0.0, 1.6)#(0.1, 0.1, 5.2)#0.6965017
-- C_S004#(-0.8, 0.0, 3.4)#1.886796#(0.0, 0.0, 0.0, 1.0)#(0.4, 0.1, 1.7)#0.412363#(-0.2, 0.0, 1.2)#(0.4, 0.1, 1.7)#0.412363
local actionLoader = {
    ["001_1"] = {
        Vector3(0.0, 0.0, 6.4),
        1.073789,
        Vector3(0.0, 0.0, 0.0)
    },
    ["001_2"] = {
        Vector3(0.0, 0.0, 6.6),
        0.9727898,
        Vector3(0.0, 0.0, 0.0),
        Vector3(0.1, 0.1, 2.0),
        0.2097368,
        Vector3(0.0, 0.0, 1.6),
        Vector3(0.1, 0.1, 5.2),
        0.6965017
    },
    ["C_S004"] = {
        Vector3(-0.8, 0.0, 3.4),
        1.886796,
        Vector3(0.0, 0.0, 0.0),
        Vector3(0.4, 0.1, 1.7),
        0.412363,
        Vector3(-0.2, 0.0, 1.2),
        Vector3(0.4, 0.1, 1.7),
        0.412363
    },
}

local function CalculateNextCatchBallAttributeIgnoreCurrent(current, next, originPos, originRotate, startTime)
    local position = originPos
    local rotation = originRotate

    local time = startTime

    position = position + rotation * current.offset
    rotation = current.rotation * rotation
    time = time + current.time

    local pos = position + rotation * next.firstTouchBallOffset
    local catchTime = time + next.firstTouchBallTime
    local d4 = {
        position = pos,
        timePoint = catchTime,
    }
    return d4
end

function AttackPlayer:ctor()
    self.animator = self.___ex.animator
    self.dummy_root = self.___ex.dummy_root
    self.bone_ball = self.___ex.bone_ball
    self.startPosition = nil
    self.endPosition = nil
    self.lookatPosition = nil
    self.doOver = nil
    self.ballObj = nil
    self.offsetDelta = nil
    self.runningTime = nil
    self.useTime = 0
    self.runOffset = nil
    self.runDuration = nil
    self.time = nil
    self.loader = nil
    self.stateName = nil
    self.lastTimeByHoldingBallState  = nil
    self.firstTimeByHoldingBallState = nil
    self.lastTimeByShootState = nil
    self.firstTimeByShootState = nil
    self.currentStateName = nil
    self.currentActionName = nil
    self.shootTransf = nil
end

function AttackPlayer:start()
    -- loader = ActionAttributeLoader.GetLoader()
    self.runOffset = actionLoader[ActionName1][1] -- loader.GetClipOffset(ActionName1)
    self.runDuration = actionLoader[ActionName1][2] --loader.GetClipDuration(ActionName1)
    self.lastTimeByHoldingBallState = actionLoader[ActionName2][8] / actionLoader[ActionName2][2] --loader.GetLastTouchNormalizedTime(ActionName2)
    self.firstTimeByHoldingBallState = actionLoader[ActionName2][5] / actionLoader[ActionName2][2] -- loader.GetFirstTouchNormalizedTime(ActionName2)
    self.lastTimeByShootState = actionLoader[ActionName3][5] / actionLoader[ActionName3][2]
    self.firstTimeByShootState = actionLoader[ActionName3][8] / actionLoader[ActionName3][2]
    self.time = 0
end

function AttackPlayer:UpdateAnimation(stealEventType) 
    if stealEventType == StealEventType.StealAnimationType2 then
        local stateInfo = self.animator:GetCurrentAnimatorStateInfo(0)   --// ����û����λ�ƣ�ֻ�ܿ�ʱ�����ж�λ��
        if (self.time >= 3 and stateInfo.normalizedTime >= 0.65) then
            self:SetActionStateType(2)
            self:EndCallBack(stealEventType)
        elseif (stateInfo:IsName(RunState)) then
            if (self.stateName ~= RunState) then
                self.time = self.time + 1
                self.stateName = RunState
            end
        elseif (stateInfo:IsName(RunState1)) then
            if (self.stateName ~= RunState1) then
                self.time = self.time + 1
                self.stateName = RunState1
            end
        end
        self.transform:LookAt(self.endPosition)
    elseif stealEventType == StealEventType.StealStartType then
        local stateInfo = self.animator:GetCurrentAnimatorStateInfo(0)
        if (Vector3.Distance(self.transform.position, self.endPosition) < 0.25) then
            self.animator:SetInteger("type", 3)
            self:EndCallBack(stealEventType)
        elseif (stateInfo:IsName(HoldingBall)) then
            self:SetDummyRoot(HoldingBall)
            self:SetActionState(HoldingBall)
            if (stateInfo.normalizedTime > self.firstTimeByHoldingBallState and stateInfo.normalizedTime < self.lastTimeByHoldingBallState) then
                self.ballObj.transform.position = self.bone_ball.position
                self.ballObj.transform.rotation = self.bone_ball.rotation
            end
        elseif (stateInfo:IsName(HoldingBall1)) then
            self:SetDummyRoot(HoldingBall1)
            self:SetActionState(HoldingBall1)
            if (stateInfo.normalizedTime > self.firstTimeByHoldingBallState and stateInfo.normalizedTime < self.lastTimeByHoldingBallState) then
                self.ballObj.transform.position = self.bone_ball.position
                self.ballObj.transform.rotation = self.bone_ball.rotation
            end
        end
        self.transform:LookAt(self.endPosition)
    elseif stealEventType == StealEventType.StealActionType then
        local stateInfo = self.animator:GetCurrentAnimatorStateInfo(0)
        if (stateInfo:IsName(ShootState)) then
            self:SetDummyRoot(ShootState)
            if (stateInfo.normalizedTime > self.firstTimeByShootState and stateInfo.normalizedTime < self.lastTimeByShootState) then
                self.ballObj.transform.position = self.bone_ball.position
                self.ballObj.transform.rotation = self.bone_ball.rotation
            elseif (stateInfo.normalizedTime >= self.lastTimeByShootState) then
                -- self.ballObj:GetComponent(BallCtl).enabled = false
                local randomZ = math.randomInRange(-3.5, 2.5) 
                local randomY = math.randomInRange(0, 2)
                local temp = self.shootTransf.position + Vector3(0, randomY, randomZ)
                self.ballObj:GetComponent(CapsUnityLuaBehav):StartRotate()
                self.ballObj:GetComponent(CapsUnityLuaBehav):ShootBall(temp, 1)

                self:EndCallBack(stealEventType)
            end
            self.transform:LookAt(self.shootTransf.position)
        end
    end
end

function AttackPlayer:SetBlockState(isReset) 
    if (isReset) then
        self.animator:SetInteger("blockState", 0)
    else 
        local blockState = math.random(1, 3)
        self.animator:SetInteger("blockState", blockState)
    end
end

function AttackPlayer:SetShootTransform(transf)
    self.shootTransf = transf
end

function AttackPlayer:SetActionState(state) 
    if (self.currentActionName ~= state)  then
        self.currentActionName = state
        -- local action = new PlayerAction(ActionName2)
        local actionData = actionLoader[tostring(ActionName2)]
        local action = {
            name = ActionName2,
            offset = actionData[1],
            time = actionData[2],
            rotation = Quaternion.Euler(actionData[3]),
            firstTouchBallOffset = actionData[4],
            firstTouchBallTime = actionData[5],
            firstTouchBallNormalizedTime = actionData[5] / actionData[2],
            firstTouchBallPlayerOffset = actionData[6],
            lastTouchBallOffset = actionData[7],
            lastTouchBallTime = actionData[8],
            lastTouchBallNormalizedTime = actionData[8] / actionData[2],
        }

        local originActionPos = self.transform.position
        local originActionRotate = self.transform.rotation
        local originActionTime = Time.time
        local d4 = CalculateNextCatchBallAttributeIgnoreCurrent(action, action,
                originActionPos, originActionRotate, originActionTime)
        local origin = originActionPos + originActionRotate * action.lastTouchBallOffset
        local destination = d4.position
        local startTime = originActionTime + action.lastTouchBallTime
        local moveTime = action.firstTouchBallTime + (action.time - action.lastTouchBallTime)

        if (moveTime < 0.1) then
            return
        end

        -- BallPass pass = new BallPass(origin, destination, startTime, moveTime, transform, transform)
        local pass = {
            type = "BallPass",
            origin = origin,
            destination = destination,
            startTime = startTime,
            time = moveTime,
            passer = self.transform,
            catcher = self.transform,
            passType = 1,
        }
        self.ballObj:GetComponent(CapsUnityLuaBehav):AddBallAction(pass)
    end
end

function AttackPlayer:SetDummyRoot(state)
    if (self.currentStateName ~= state) then
        self.dummy_root.position = self.transform.position
        self.currentStateName = state
    end
end

function AttackPlayer:ResetState() 
    self.animator:Play(IdleState)
    self.animator.speed = 1
    self.time = 0
    self.stateName = ""
    self.currentStateName = ""
    self.currentActionName = ""
    self:SetActionStateType(0)
    self:SetBlockState(true)
end

function AttackPlayer:SetActionStateType(num) 
    self.animator:SetInteger("type", num)
end

function AttackPlayer:EndCallBack(type)
    if (self.doOver ~= null) then
        self.doOver(type)
    end
end

function AttackPlayer:Init(startPos, endPos, ball)
    self.startPosition = startPos
    self.endPosition = endPos
    self.transform.position = startPos
    self.transform:LookAt(endPos)
    self.ballObj = ball
    self.runningTime = 0
end

return AttackPlayer

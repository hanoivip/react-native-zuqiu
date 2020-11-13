local DefensePlayer = class(unity.base)

local StealEventType = require("training.steal.StealEventType")

local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local CapsUnityLuaBehav = clr.CapsUnityLuaBehav
local Time = UnityEngine.Time

local IdleState = "Idle"
local StealState = "Steal"
local ActionName = "001_4"

-- 001_4#(-0.6, 0.0, 6.9)#2.848129#(0.0, 0.0, 0.0, 1.0)#(-0.4, 0.1, 3.7)#0.4324131#(-0.4, 0.0, 2.6)#(-0.4, 0.1, 3.7)#0.4324131
local actionLoader = {
    ["001_4"] = {0.4324131/2.848129, 0.4324131/2.848129}
}

function DefensePlayer:ctor()
    self.animator = self.___ex.animator
    self.dummy_root = self.___ex.dummy_root
    self.bone_ball = self.___ex.bone_ball
    self.startPosition = nil
    self.endPosition = nil
    self.lookatPosition = nil
    self.ballObj = nil
    self.currentStateName = nil
    self.doOver = nil
    self.lastTime = nil
    self.firstTime = nil
end

function DefensePlayer:start()
    self.firstTime = actionLoader[ActionName][1]
    self.lastTime = actionLoader[ActionName][2]
end

function DefensePlayer:UpdateAnimation(stealEventType)
    if stealEventType == StealEventType.StealAnimationType2 then
        self.transform:LookAt(self.endPosition)
    elseif stealEventType == StealEventType.StealActionType then
        local stateInfo = self.animator:GetCurrentAnimatorStateInfo(0)
        if (stateInfo:IsName(IdleState)) then
            if (self.doOver ~= nil) then
                self.doOver(stealEventType)
            end
        elseif (stateInfo:IsName(StealState)) then
            self:SetDummyRoot(StealState)
            if (stateInfo.normalizedTime > self.firstTime and stateInfo.normalizedTime < self.lastTime) then
                self.ballObj.transform.position = self.bone_ball.position
                self.ballObj.transform.rotation = self.bone_ball.rotation
                self.transform:LookAt(self.ballObj.transform.position)
            end
        end
    elseif stealEventType == StealEventType.StealOverType then
        local stateInfo = self.animator:GetCurrentAnimatorStateInfo(0)
        if (stateInfo:IsName(IdleState)) then
            if (self.doOver ~= nil) then
                self.doOver(stealEventType)
            end
        elseif (stateInfo:IsName(StealState)) then
            self:SetDummyRoot(StealState)
            if (stateInfo.normalizedTime > self.firstTime and stateInfo.normalizedTime < self.lastTime) then
                self.ballObj.transform.position = self.bone_ball.position
                self.ballObj.transform.rotation = self.bone_ball.rotation
            end
            self.transform:LookAt(self.ballObj.transform.position)
        end
    end
end

function DefensePlayer:SetDummyRoot(state)
    if (self.currentStateName ~= state) then
        self.dummy_root.position = self.transform.position
        self.currentStateName = state
    end
end

function DefensePlayer:SetSpeed(speed)
    self.animator.speed = 1 + speed
end

function DefensePlayer:SetActionStateType(num)
    self.animator:SetInteger("type", num)
end

function DefensePlayer:ResetState()
    self.animator:Play(IdleState)
    self.currentStateName = ""
    self.animator.speed = 1
    self:SetActionStateType(0)
end

function DefensePlayer:SetBall(ball)
    self.ballObj = ball
end

function DefensePlayer:Init(startPos, endPos, lookat)
    self.startPosition = startPos
    self.endPosition = endPos
    self.lookatPosition = lookat
    self.transform.position = startPos
    self.transform:LookAt(endPos)
end

return DefensePlayer

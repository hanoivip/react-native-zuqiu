local PassPlayer = class(unity.base)

local StealEventType = require("training.steal.StealEventType")

local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3

local IdleState = "Idle"
local PassState = "Pass"
local ActionName = { "C_J002","C_C014" }

-- C_J002#(1.1, 0.0, 1.9)#1.41293#(0.0, 0.0, 0.0, 1.0)#(0.4, 0.1, 0.7)#0.381591#(0.0, 0.0, 0.2)#(1.5, 0.1, 1.5)#1.114729
-- C_C014#(-1.0, 0.0, 1.7)#2.454045#(0.0, -0.5, 0.0, 0.9)#(-0.2, 0.1, 2.2)#1.145278#(-0.4, 0.0, 1.7)#(-0.2, 0.1, 2.2)#1.145278
local actionLoader = {
    C_J002 = {0.381591/1.41293, 1.114729/1.41293, Vector3(0.0, 0.0, 0.2)},
    C_C014 = {1.145278/2.454045, 1.145278/2.454045, Vector3(-0.4, 0.0, 1.7)},
}

function PassPlayer:ctor()
    self.animator = self.___ex.animator
    self.dummy_root = self.___ex.dummy_root
    self.bone_ball = self.___ex.bone_ball
    self.currentActionName = nil
    self.currentStateName = nil
    self.ballObj = nil
    -- self.loader = nil
    self.lastTime = nil
    self.firstTime = nil
end

function PassPlayer:start()
end

function PassPlayer:UpdateAnimation(stealEventType)
    if stealEventType == StealEventType.StealAnimationType then
        local stateInfo = self.animator:GetCurrentAnimatorStateInfo(0)
        if (not stateInfo:IsName(IdleState)) then
            self:SetDummyRoot(self.currentActionName)
            if (stateInfo.normalizedTime > self.firstTime and stateInfo.normalizedTime < self.lastTime) then
                self.ballObj.transform.position = self.bone_ball.position
                self.ballObj.transform.rotation = self.bone_ball.rotation
            elseif (stateInfo.normalizedTime >= self.lastTime) then
                if (self.doOver ~= nil) then
                    self.doOver(stealEventType)
                end
            end
            self.animator:SetInteger("type", 0)
        end
    end
end

function PassPlayer:ResetState()
    self.animator:Play(IdleState)
    self.animator.speed = 1
    self.currentActionName = ""
    self.currentStateName = ""
    self:SetActionStateType(0)
end

function PassPlayer:SetActionStateType(num)
    self.animator:SetInteger("type", num)
end

function PassPlayer:SetDummyRoot(state)
    if (self.currentStateName ~= state) then
        self.dummy_root.position = self.transform.position
        self.currentStateName = state
        self.firstTime = actionLoader[tostring(self.currentActionName)][1]
        self.lastTime = actionLoader[tostring(self.currentActionName)][2]
    end
end

function PassPlayer:SetBall(ball)
    self.ballObj = ball
    -- loader = ActionAttributeLoader.GetLoader()
    local passState = math.random(1, 2)
    self.currentActionName = ActionName[passState]
    self.animator:SetInteger("type", passState)
    local offset = actionLoader[tostring(self.currentActionName)][3]
    local originActionRotate = self.transform.rotation
    local value = originActionRotate * offset
    self.dummy_root.position = self.transform.position
    self.ballObj.transform.position = self.bone_ball.position + value
end

function PassPlayer:Init(start, lookat)
    self.transform.position = start
    self.transform:LookAt(lookat)
end

return PassPlayer

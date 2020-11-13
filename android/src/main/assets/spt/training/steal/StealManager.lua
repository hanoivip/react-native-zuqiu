local StealManager = class(unity.base)

local StealEventType = require("training.steal.StealEventType")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local PlayerReplacer = require("coregame.PlayerReplacer")
local PlayerModelConstructer = require("coregame.PlayerModelConstructer")
local BaseTexGenerator = require("cloth.BaseTexGenerator") 
local ClothUtils = require("cloth.ClothUtils")
local TeamUniformModel  = require("ui.models.common.TeamUniformModel")

local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local CapsUnityLuaBehav = clr.CapsUnityLuaBehav
local Time = UnityEngine.Time
local Object = UnityEngine.Object
local TrailRenderer = UnityEngine.TrailRenderer
local GameObject = UnityEngine.GameObject
local Camera = UnityEngine.Camera

local PREFAB_TRAIN_DEFENSE = "Assets/CapstonesRes/Game/Models/TrainPlayers/StealDefense.prefab"
local PREFAB_TRAIN_PASS = "Assets/CapstonesRes/Game/Models/TrainPlayers/StealCross.prefab"
local PREFAB_TRAIN_ATTACK = "Assets/CapstonesRes/Game/Models/TrainPlayers/StealAttack.prefab"

local spaceByPlayers = 1
local distanceByPlayers = 5

local PlayerBuilder = clr.PlayerBuilder

function StealManager:ctor()
    self.startPositonTransform = self.___ex.startPositonTransform --table
    self.endPositonTransform = self.___ex.endPositonTransform --table
    self.cameraTransform = self.___ex.cameraTransform --table
    self.lookAtTransform = self.___ex.lookAtTransform --table
    self.CameraCtl = self.___ex.CameraCtl
    self.stealCamera = self.___ex.stealCamera
    self.stealEventType = nil
    self.ownPlayer = nil
    self.PlayerCtl = nil
    self.positonOffset1  = nil
    self.positonOffset2 = nil
    self.positonOffset3 = nil
    self.lookOffset1 = nil
    self.lookOffset2 = nil
    self.lookOffset3 = nil
    self.playerByPassBall = nil
    self.playerByAttack = nil
    self.playerByPassBallCtl = nil
    self.playerByAttackCtl = nil
    self.playerByDefenseStartVec3 = nil
    self.playerByDefenseEndVec3 = nil
    self.ballObj = nil
    self.isSuccess = false
end

function StealManager:SetStealGameControl(gameControl, trainManager)
    self.stealGameControl = gameControl
    self.trainManager = trainManager
    self.ballObj = trainManager.ball
end

function StealManager:start()
    self.stealEventType = StealEventType.StealDiveInType

    self.positonOffset1 = Vector3(-5, 5, -5)
    self.lookOffset1 = Vector3(-4, 0, 2)
    self.positonOffset2= Vector3(-3, 3, -3)
    self.lookOffset2 = Vector3(-1, 0, 2)
    self.positonOffset3 = Vector3(-5, 5, 4)
    self.lookOffset3 = Vector3(0, 2, 0)

    self.stealGameControl:InitView()
    self:CalculateDefensePlayerPosition()
end

function StealManager:CalculateDefensePlayerPosition() 
    self.startPositonTransform["t" .. tostring(2)]:LookAt(self.endPositonTransform["t" .. tostring(2)].position)
    self.playerByDefenseStartVec3 = self.startPositonTransform["t" .. tostring(2)].position + self.startPositonTransform["t" .. tostring(2)].right * spaceByPlayers - self.startPositonTransform["t" .. tostring(2)].forward * distanceByPlayers
    self.endPositonTransform["t" .. tostring(2)]:LookAt(self.startPositonTransform["t" .. tostring(2)].position)
    self.playerByDefenseEndVec3 = self.endPositonTransform["t" .. tostring(2)].position - self.endPositonTransform["t" .. tostring(2)].right * spaceByPlayers - self.endPositonTransform["t" .. tostring(2)].forward * distanceByPlayers
end

function StealManager:update()
    if self.stealEventType == StealEventType.StealDiveInType then
        self:SkipAnimationByStart()
    elseif self.stealEventType == StealEventType.StealAnimationType then
        self.playerByPassBallCtl:UpdateAnimation(self.stealEventType)
    elseif self.stealEventType == StealEventType.StealAnimationType2 then
        self.playerByAttackCtl:UpdateAnimation(self.stealEventType)
        self.PlayerCtl:UpdateAnimation(self.stealEventType)
        self.PlayerCtl:SetSpeed(self.stealGameControl.addSpeed)
    elseif self.stealEventType == StealEventType.StealStartType then
        self.playerByAttackCtl:UpdateAnimation(self.stealEventType)
        self.PlayerCtl:UpdateAnimation(self.stealEventType)
        self.PlayerCtl:SetSpeed(self.stealGameControl.addSpeed)
        self:JudgeDistance()
    elseif self.stealEventType == StealEventType.StealActionType then
        self.playerByAttackCtl:UpdateAnimation(self.stealEventType)
        self.PlayerCtl:UpdateAnimation(self.stealEventType)
    elseif self.stealEventType == StealEventType.StealOverType then
        self.PlayerCtl:UpdateAnimation(self.stealEventType)
    end
end

function StealManager:JudgeDistance() 
    local v1 = self.playerByAttack.transform.forward
    local v2 = self.ownPlayer.transform.position - self.playerByAttack.transform.position
    local distance = Vector3.Distance(self.playerByAttack.transform.position, self.ownPlayer.transform.position)
    local value = Vector3.Dot(v1, v2)
    if (value >= 0) then
        self.PlayerCtl:SetActionStateType(3)
        self.PlayerCtl.animator.speed = 1
        self.PlayerCtl:SetBall(self.ballObj)
        self.playerByAttackCtl:SetBlockState(false)
        self.stealEventType = StealEventType.StealActionType
        self.isSuccess = true
        self.stealGameControl:SetGameOver(true)
    end
end

function StealManager:SkipAnimationByStart() 
    if (self.stealEventType == StealEventType.StealDiveInType) then
        self.stealEventType = StealEventType.StealAnimationType
        self.isSuccess = false
        if (self.ownPlayer) then
            Object.Destroy(self.ownPlayer)
            self.ownPlayer = nil
        end
        self.ownPlayer = res.Instantiate(PREFAB_TRAIN_DEFENSE)
        self.trainManager:BuildPlayer(self.ownPlayer:GetComponent(PlayerBuilder), self.trainManager.playerModelID, TeamUniformModel.UniformType.Home)
        
        self.PlayerCtl = self.ownPlayer:GetComponent(CapsUnityLuaBehav)
        self.PlayerCtl.doOver = function(eventType) self:DoOver(eventType) end

        if (self.playerByPassBall) then
            Object.Destroy(self.playerByPassBall) 
            self.playerByPassBall = nil
        end
        self.playerByPassBall = res.Instantiate(PREFAB_TRAIN_PASS)
        self.trainManager:BuildPlayer(self.playerByPassBall:GetComponent(PlayerBuilder), nil, TeamUniformModel.UniformType.Away)

        self.playerByPassBallCtl = self.playerByPassBall:GetComponent(CapsUnityLuaBehav)
        self.playerByPassBallCtl.doOver = function(eventType) self:DoOver(eventType) end

        if (self.playerByAttack) then
            Object.Destroy(self.playerByAttack)
            self.playerByAttack = nil
        end
        self.playerByAttack = res.Instantiate(PREFAB_TRAIN_ATTACK)
        self.trainManager:BuildPlayer(self.playerByAttack:GetComponent(PlayerBuilder), nil, TeamUniformModel.UniformType.Away)
        
        self.playerByAttackCtl = self.playerByAttack:GetComponent(CapsUnityLuaBehav)
        self.playerByAttackCtl.doOver = function(eventType) self:DoOver(eventType) end

        self.ballObj:GetComponent(TrailRenderer).enabled = false
                
        self.PlayerCtl:ResetState()
        self.playerByAttackCtl:ResetState()
        self.playerByPassBallCtl:ResetState()
        self.playerByAttackCtl:Init(self.startPositonTransform["t" .. tostring(2)].position, self.endPositonTransform["t" .. tostring(2)].position, self.ballObj)
        self.playerByPassBallCtl:Init(self.startPositonTransform["t" .. tostring(1)].position, self.playerByAttack.transform.position + self.playerByAttack.transform.forward * 50)
        self.playerByPassBallCtl:SetBall(self.ballObj)
        self.PlayerCtl:Init(self.playerByDefenseStartVec3, self.playerByDefenseEndVec3, self.playerByDefenseEndVec3)
        self.CameraCtl:Init(self.cameraTransform["t" .. tostring(0)].position, self.cameraTransform["t" .. tostring(0)].rotation)   
    end
end

function StealManager:DoOver(eventType)
    if eventType == StealEventType.StealAnimationType then
        self.stealEventType = StealEventType.StealAnimationType2
        self.ballObj:GetComponent(TrailRenderer).enabled = true
        -- BallPass action = new BallPass(self.ballObj.transform.position, playerByAttack.transform.position + playerByAttack.transform.forward * (playerByAttackCtl.Runoffset.z / playerByAttackCtl.RunDuration * 3f), Time.time, 3f, playerByPassBall.transform, playerByAttack.transform, BallPass.PassType.airball_rainbow)
        local pass = {
            type = "BallPass",
            origin = self.ballObj.transform.position,
            destination = self.playerByAttack.transform.position + self.playerByAttack.transform.forward * (self.playerByAttackCtl.runOffset.z / self.playerByAttackCtl.runDuration * 3),
            startTime = Time.time,
            time = 3,
            passer = self.playerByPassBall.transform,
            catcher = self.playerByAttack.transform,
            passType = 2,
        }

        self.ballObj:GetComponent(CapsUnityLuaBehav):AddBallAction(pass)
        self.playerByAttackCtl:SetActionStateType(1)
        self.PlayerCtl:SetActionStateType(2)
        self.CameraCtl:InitByTransform(self.stealCamera.gameObject, self.cameraTransform["t" .. tostring(1)], self.playerByAttack , Vector3(0,2,0), 200)
        -- gamePanel:SetActive(true)
        self.stealGameControl:StartToSteal()
        self.stealGameControl:InitState(self.playerByAttack, self.ownPlayer, spaceByPlayers, 3)
    elseif eventType == StealEventType.StealAnimationType2 then
        self.stealEventType = StealEventType.StealStartType
        self.CameraCtl:InitByTarget(self.ownPlayer, self.positonOffset3, self.ownPlayer, self.lookOffset3)
    elseif eventType == StealEventType.StealStartType then
        self.stealEventType = StealEventType.StealActionType
        self.PlayerCtl:SetActionStateType(4)
        self.playerByAttackCtl:SetShootTransform(self.endPositonTransform["t" .. tostring(1)])
        self.stealGameControl:SetGameOver(true)
    elseif eventType == StealEventType.StealActionType then
        self.stealEventType = StealEventType.StealOverType
    elseif eventType == StealEventType.StealOverType then
        self.stealEventType = StealEventType.StealDefaultType
        Object.Destroy(self.ownPlayer)
        Object.Destroy(self.playerByPassBall)
        Object.Destroy(self.playerByAttack)
        -- gamePanel:SetActive(false)
        self.stealGameControl:InitView()
        -- self.ballObj:GetComponent<BallCtl>().enabled = true 
        if (self.isSuccess) then
            self.trainManager:TrySuccessCount(self.stealGameControl.result)
        else
            self.trainManager:TryFailed(1)
        end
    end
end

return StealManager

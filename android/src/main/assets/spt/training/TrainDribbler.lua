local TrainDribbler = class(unity.base)

local EventSystem = require("EventSystem")
local TrainConst = require("training.TrainConst")

local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local Object = UnityEngine.Object
local GameObject = UnityEngine.GameObject
local Input = UnityEngine.Input
local TouchPhase = UnityEngine.TouchPhase
local Camera = UnityEngine.Camera
local CapsUnityLuaBehav = clr.CapsUnityLuaBehav
local Time = UnityEngine.Time

local motionDict = {
    -- // head
    {"A_D07", "A_D07_1"},
    -- // left shoulder
    {"A_D05", "A_D05_1"},
    -- // right shoulder
    {"A_D06", "A_D06_1"},
    -- // left knee
    {"A_D03"},
    -- // right knee
    {"A_D04_1"},
    -- // left foot
    {"A_D01", "A_D01_2"},
    -- // right foot
    {"A_D02", "A_D02_2"},
    -- // failure
    {"A_D08", "A_D08_1"},
}

local actionLoader = {
    A_D00 = {0.04998779/1.624146, 1.08606/1.624146},
    A_D01 = {0.435791/0.8755493, 0.435791/0.8755493},
    A_D01_1 = {0.432373/0.9703979, 0.432373/0.9703979},
    A_D01_2 = {0.5321045/1.020874, 0.5321045/1.020874},
    A_D02 = {0.5457153/0.9761963, 0.5457153/0.9761963},
    A_D02_1 = {0.5330811/0.9737549, 0.5330811/0.9737549},
    A_D02_2 = {0.758667/1.137329, 0.758667/1.137329},
    A_D03 = {0.4349976/0.8761597, 0.4349976/0.8761597},
    A_D03_1 = {0.4345093/0.9230347, 0.4345093/0.9230347},
    A_D04 = {0.3223267/0.8103027, 0.3223267/0.8103027},
    A_D04_1 = {0.4206543/0.9716187, 0.4206543/0.9716187},
    A_D05 = {0.4332886/0.9234009, 0.4332886/0.9234009},
    A_D05_1 = {0.6447144/1.182617, 0.6447144/1.182617},
    A_D06 = {0.583252/1.135376, 0.583252/1.135376},
    A_D06_1 = {0.6468506/1.088684, 0.6468506/1.088684},
    A_D07 = {0.6459351/1.086182, 0.6459351/1.086182},
    A_D07_1 = {0.5344238/0.975647, 0.5344238/0.975647},
    A_D08 = {0.4346924/2.33374, 2.056335/2.33374},
    A_D08_1 = {0.4848022/2.057922, 2.057922/2.057922},
}

function TrainDribbler:ctor()
    self.boneBall = self.___ex.boneBall
    self.animator = self.___ex.animator
    self.touchPoints = {}
    for i = 1, table.nums(self.___ex.touchPoints) do
        table.insert(self.touchPoints, self.___ex.touchPoints["t" .. tostring(i)])
    end

    self.currentTouchPoint = 6
    self.currentMotion = "A_D00"
    self.preMotion = "A_D00"
    self.startMotion = "A_D00"
    self.isStart = false
    self.isEnd = false
    self.motionEnd = false
    self.firstTouchBall = false
    self.lastTouchBall = false
    self.firstTouchBallTime = 0
    self.lastTouchBallTime = 0
    self.playbackDuration = 0
 
    self.isPlayingBack = false
    self.newBallPos = Vector3.zero
    self.recordEnd = false
    self.recordStart = false
    self.recordDuration = 0
    self.playbackStart = 0
    self.touchSuccess = true
    self.terminate = false
    self.endTime = 0
    self.oriSpeed = 0
    self.maxSpeed = 0
    self.interval = 0
    self.accelerate = 0
    self.playSpeed = 0
end

function TrainDribbler:InitData(trainData, ball, trainManager)
    self.trainData = trainData
    self.ball = ball
    self.trainManager = trainManager
end

function TrainDribbler:start()
    self.oriSpeed = self.trainData:GetTrainExInfo("dribble_min_speed")
    self.maxSpeed = self.trainData:GetTrainExInfo("dribble_max_speed")
    self.interval = self.trainData:GetTrainExInfo("dribble_speed_interval")
    self.accelerate = self.trainData:GetTrainExInfo("dribble_accelerate")
    self.ball.transform:Translate(self.ball.transform.up * 0.11)
    self.uiManager = self.trainManager.trainMenuCtrl.trainMenuView
    self:MoveDribbleButton(self.recordDuration, true)
    self.playSpeed = self.oriSpeed
end

function TrainDribbler:update()
    if self.isEnd then
        self.animator:SetBool(self.preMotion, false)
        self.animator:SetBool(self.currentMotion, true)
        self.animator:SetBool("duplicate", false)
        if self.animator:GetCurrentAnimatorStateInfo(0).IsName("Base Layer." .. self.currentMotion) then
            self.ball.transform.position = self.boneBall.transform.position
        end
        if not self.terminate and Time.time - self.endTime > 1 then
            if (self.trainManager.score < TrainConst.TRAIN_DRIBBLE_MAX_CLICK) then
                EventSystem.SendEvent("training_try_failed")
                self.playSpeed = self.oriSpeed + math.floor(self.trainManager.score / self.interval) * self.accelerate
                self.terminate = true
            end
        end
    end
    if not self.isStart then
        if Input.GetMouseButton(0) then
            self.isStart = true
            self.animator:SetBool(self.currentMotion, true)
            self.isPlayingBack = false
        elseif Input.touchCount > 0 and Input.GetTouch(0).phase == TouchPhase.Began then
            self.isStart = true
            self.animator:SetBool(self.currentMotion, true)
            self.isPlayingBack = false
        end
    else
        if self.isPlayingBack then
            if not self.touchSuccess then
                if Input.GetMouseButton(0) then
                    self.touchSuccess = self.uiManager:CheckPoint(Input.mousePosition)
                    if self.touchSuccess then
                        self.playSpeed = self.oriSpeed + math.floor(self.trainManager.score / self.interval) * self.accelerate
                        if self.playSpeed > self.maxSpeed then
                            self.playSpeed = self.maxSpeed
                        end
                    end
                elseif Input.touchCount > 0 and (Input.GetTouch(0).phase == TouchPhase.Began) then
                    self.touchSuccess = self.uiManager:CheckPoint(Input.GetTouch(0).position)
                    if self.touchSuccess then
                        self.playSpeed = self.oriSpeed + math.floor(self.trainManager.score / self.interval) * self.accelerate
                        if self.playSpeed > self.maxSpeed then
                            self.playSpeed = self.maxSpeed
                        end
                    end
                end
            end
            Camera.main.transform.position = self.transform.position + self.transform.forward * 6.48 + self.transform.up * 1
            Camera.main.transform:LookAt (self.transform.position + self.transform.up * 1)
            self.playbackDuration = self.playbackDuration + Time.deltaTime * self.playSpeed
            local playtime = self.animator.playbackTime + Time.deltaTime * self.playSpeed
            if playtime >= self.animator.recorderStopTime then
                self.playbackStart = playtime - self.animator.recorderStopTime
                playtime = self.animator.recorderStopTime
                self.animator.playbackTime = playtime
                self.animator:StopPlayback()
                self.isPlayingBack = false
            else
                self.animator.playbackTime = playtime
            end

            if self.playbackDuration > Time.deltaTime * 3 and self.playbackDuration < self.lastTouchBallTime then
                self.ball.transform.position = self.boneBall.transform.position
            end
            if self.lastTouchBall == true and self.playbackDuration >= self.lastTouchBallTime then
                self.lastTouchBall = false
                self.ball:GetComponent(CapsUnityLuaBehav):StartRotate()
                self.ball:GetComponent(CapsUnityLuaBehav):ShootBall(self.newBallPos, (self.recordDuration - self.lastTouchBallTime) / self.playSpeed * 0.98)
            end

        end
        if not self.isPlayingBack and not self.isEnd then
            self:RecordToNextMotion()
        end
    end    
end

function TrainDribbler:RecordToNextMotion()
    self.animator:StartRecording(0)
    self.firstTouchBall = false
    self.lastTouchBall = false
    self.firstTouchBallTime = 0
    self.lastTouchBallTime = 0
    self.recordDuration = 0
    self.recordStart = true
    while self.ballPos == nil and not self.isEnd do
        self:ForceUpdate()
    end
    self.newBallPos = self.ballPos or self.newBallPos
    self.animator:StopRecording()
    self.touchSuccess = false
    self.animator:StartPlayback()
    self.animator.playbackTime = self.animator.recorderStartTime + self.playbackStart
    self.isPlayingBack = true
    self.playbackDuration = 0
    self.ballPos = nil
end

function TrainDribbler:ForceUpdate()
    if not self.isStart then return end

    local delta = 0.033
    self.animator:Update(delta)
    self.recordDuration = self.recordDuration + delta
    if ((self.currentMotion == self.startMotion or self.currentTouchPoint == 8) and not self.lastTouchBall) then
        self.lastTouchBallTime = self.lastTouchBallTime + delta
    end
    if ((self.currentMotion == self.startMotion or self.currentTouchPoint == 8) and not self.firstTouchBall) then
        self.firstTouchBallTime = self.firstTouchBallTime + delta
    end
    local state = self.animator:GetCurrentAnimatorStateInfo(0)
    if (state:IsName("Base Layer." .. self.currentMotion)) then
        if (state.normalizedTime >= 0 and state.normalizedTime < actionLoader[self.currentMotion][2]) then
            self.motionEnd = false
            self.recordEnd = false
        end
        if (self.currentMotion ~= self.startMotion) then
            if (not self.recordEnd and state.normalizedTime >= actionLoader[self.currentMotion][1]) then
                self.ballPos = self.boneBall.transform.position
                self.recordEnd = true
                self.uiManager:SetScale(self.recordDuration * 0.5)
            end
        end
        if (state.normalizedTime >= actionLoader[self.currentMotion][1]) then
            self.firstTouchBall = false
        end

        if (state.normalizedTime >= actionLoader[self.currentMotion][1] and
            state.normalizedTime <= actionLoader[self.currentMotion][2]) then
            self.ball.transform.position = self.boneBall.transform.position
        elseif (state.normalizedTime >= actionLoader[self.currentMotion][2]) then
            if (not self.motionEnd and (not self.recordEnd or self.recordStart)) then
                self.lastTouchBall = true -- // start to fly
                self.motionEnd = true
                self.recordStart = false
                self:GenerateTouchPoint()
            end
        end
    end
end

function TrainDribbler:GenerateTouchPoint()
    self.preMotion = self.currentMotion
    self.animator:SetBool(self.preMotion, false)

    local tmp = 1
    if (self.touchSuccess) then
        -- SoundCtl.GetInstance():PlaySound("TouchLight", false)  --Lua assist checked flag
        tmp = math.random(1, 6)
        self.currentTouchPoint = tmp
        local total = table.nums(motionDict[self.currentTouchPoint])
        self.currentMotion = motionDict[self.currentTouchPoint][math.random(1, total)]
        self.animator:SetBool(self.currentMotion, true)
        self:MoveDribbleButton(self.recordDuration)
    else
        tmp = 8
        self.currentTouchPoint = tmp
        local total = table.nums(motionDict[self.currentTouchPoint])
        self.currentMotion = motionDict[self.currentTouchPoint][math.random(1, total)]
        self.isEnd = true
        self.endTime = Time.time
        if self.uiManager.gameObject and self.uiManager.gameObject ~= clr.null then
            self.uiManager:disappear()
        end
    end
end

function TrainDribbler:MoveDribbleButton(t, isStart)
    if self.currentTouchPoint >= 0 and self.currentTouchPoint < #self.touchPoints then
        local screenPos = Camera.main:WorldToScreenPoint(self.touchPoints[self.currentTouchPoint].transform.position)
        if isStart then
            self.uiManager:Init()
        end
        if (self.trainManager.score >= TrainConst.TRAIN_DRIBBLE_MAX_CLICK) then
            self.uiManager.gameObject:SetActive(false)
            return
        end
        self.uiManager:InitScreenPos(screenPos, isStart, self)
    end
end

function TrainDribbler:JudgeGameOver()
    if (self.trainManager.score >= TrainConst.TRAIN_DRIBBLE_MAX_CLICK) then
        self.trainManager:GameOver()
        self:GetComponent(clr.CapsUnityLuaBehavUpdate).enabled = false
    else
        self.trainManager:SimpleTrySuccess()
        if (self.trainManager.score >= TrainConst.TRAIN_DRIBBLE_MAX_CLICK) then
            self.trainManager:GameOver()
            self:GetComponent(clr.CapsUnityLuaBehavUpdate).enabled = false
        end
    end
end

return TrainDribbler

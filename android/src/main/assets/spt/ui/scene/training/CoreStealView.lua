local BaseCoreTrainView = require("ui.scene.training.BaseCoreTrainView")

local EventSystem = require("EventSystem")

local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local CapsUnityLuaBehav = clr.CapsUnityLuaBehav
local Time = UnityEngine.Time
local Object = UnityEngine.Object
local WaitForSeconds = UnityEngine.WaitForSeconds

local ButtonClickState = {
    LeftClickState = 1,
    RightClickState = 2,
    DefaultClickState = 3
}

local intervalTime = 1
local fixSpeed = 6

-- Refactoring from StealGameControl
local CoreStealView = class(BaseCoreTrainView)

function CoreStealView:ctor()
    CoreStealView.super.ctor(self)
    self.timer = self.___ex.timer
    self.stealPanel = self.___ex.stealPanel
    self.btnLeft = self.___ex.btnLeft
    self.leftButton = self.___ex.leftButton
    self.btnRight = self.___ex.btnRight
    self.rightButton = self.___ex.rightButton
    self.clickNum = self.___ex.clickNum
    self.progressBarMiddle = self.___ex.progressBarMiddle
    self.GO = self.___ex.GO

    self.countdownView = self.___ex.countdownView

    self.countDown = 3
    self.clickTimeTable = {}
    self.nextCount = 0
    self.totalCount = 0
    self.addSpeed = 0
    self.tempTime = 0
    self.beginTime = 0
end

function CoreStealView:InitView()
    self.stealPanel:SetActive(false)
    self.timer.text = "00:00"
    self.isRun = false
end

function CoreStealView:start()
    self.btnLeft:regOnButtonClick(function()
        if (self.buttonState == ButtonClickState.LeftClickState) then
            -- SoundCtl.GetInstance():PlaySound(ManagerConstants.SOUND_TRAIN_DEFEND_CLICK, false)  --Lua assist checked flag
            self.leftButton.interactable = false
            self.rightButton.interactable = true
            self.buttonState = ButtonClickState.RightClickState
            -- clickTimeTable.Add(Time.time - beginTime)  --Lua assist checked flag
            table.insert(self.clickTimeTable, Time.time - self.beginTime)
            self.totalCount = self.totalCount + 1
            self.clickNum.text = tostring(self.totalCount)
        end
    end)
    self.btnRight:regOnButtonClick(function()
        if (self.buttonState == ButtonClickState.RightClickState) then
            -- SoundCtl.GetInstance():PlaySound(ManagerConstants.SOUND_TRAIN_DEFEND_CLICK, false)  --Lua assist checked flag
            self.leftButton.interactable = true
            self.rightButton.interactable = false

            self.buttonState = ButtonClickState.LeftClickState
            -- clickTimeTable.Add(Time.time - beginTime)  --Lua assist checked flag
            table.insert(self.clickTimeTable, Time.time - self.beginTime)
            self.totalCount = self.totalCount + 1
            self.clickNum.text = tostring(self.totalCount)
        end
    end)

    EventSystem.AddEvent("training_steal_start", self, self.StartToSteal)
    EventSystem.AddEvent("training_steal_start_timer", self, self.StartToStealTimer)
end

function CoreStealView:StartToSteal()
    self.stealPanel:SetActive(true)
    self.isRun = true
end

function CoreStealView:StartToStealTimer()
end

function CoreStealView:onDestroy()
    EventSystem.RemoveEvent("training_steal_start", self, self.StartToSteal)
    EventSystem.RemoveEvent("training_steal_start_timer", self, self.StartToStealTimer)
end

function CoreStealView:InitState(attackObj, defendObj, offestSpace, time)
    -- SoundCtl.GetInstance():PlaySound(ManagerConstants.SOUND_TRAIN_DEFEND_COUNTER, false)  --Lua assist checked flag
    self.nextCount = 0
    self.totalCount = 0
    self.addSpeed = 0
    self.tempTime = 0
    self.countDown = time
    self.gameOver = false
    self.spaceByPlayer = offestSpace
    self.buttonState = ButtonClickState.DefaultClickState
    self.attackPlayer = attackObj
    self.defendPlayer = defendObj
    self.leftButton.interactable = true
    self.rightButton.interactable = false
    self.clickTimeTable = {}

    self.stealPanel:SetActive(false)

    self.countdownView:ShowCountdown()
    
    -- 这个数值可以控制回追的难度
    self.needClickCount = 35
end

function CoreStealView:update()
    if not self.isRun then return end

    if self.gameOver then return end

    if self.countDown ~= 0 then
        self.tempTime = self.tempTime + Time.deltaTime
        if self.tempTime >= 1 then
            self.countDown = self.countDown - 1
            self:SetCountDown(self.countDown)
            self.tempTime = 0
        end
    else
        self:SetHeadPoint()
        self:UpdateProgressBar()
        self:SetUseTime(Time.time - self.beginTime)
        local clickCountByArea = #self.clickTimeTable - self.nextCount
        local matchTime = Time.time - self.beginTime
        local deltaTime = (matchTime > intervalTime) and intervalTime or matchTime 
        self.addSpeed = clickCountByArea == 0 and clickCountByArea or clickCountByArea / deltaTime * self.ratio 
        self.addSpeed = self.addSpeed / fixSpeed
    end
end

function CoreStealView:SetHeadPoint()
    while (self.nextCount < #self.clickTimeTable and self.clickTimeTable[self.nextCount + 1] < (Time.time - self.beginTime - intervalTime)) do
        self.nextCount = self.nextCount + 1
    end
end

function CoreStealView:UpdateProgressBar()
    local currentDistance = Vector3.Distance(self.attackPlayer.transform.position, self.defendPlayer.transform.position)
    if (currentDistance <= self.spaceByPlayer) then
        currentDistance = 0
    else 
        currentDistance = math.sqrt(currentDistance * currentDistance - self.spaceByPlayer * self.spaceByPlayer)
    end

    local percent = (self.distance - currentDistance) / self.distance
    self.progressBarMiddle.fillAmount = percent
    -- progressControlRect.sizeDelta = new Vector2(percent, progressControlRect.sizeDelta.y)
end

function CoreStealView:SetUseTime(time)
    local sec = string.format("%02d", math.floor(time))
    local msec = string.format("%02d", (time - math.floor(time)) * 100)
    self.timer.text = sec .. ":" .. msec
end

function CoreStealView:SetCountDown(time) 
    self.countdownView:SetCountdownTime(time)
    self.distance = Vector3.Distance(self.attackPlayer.transform.position, self.defendPlayer.transform.position)
    self.distance = math.sqrt(self.distance * self.distance - self.spaceByPlayer * self.spaceByPlayer)

    self.ratio = self.distance / self.needClickCount

    self.beginTime = Time.time
    if (self.countDown == 0) then
        self.buttonState = ButtonClickState.LeftClickState
        self.stealPanel:SetActive(true)
        self.countdownView:HideCountdown()
        self.countdownView:SetCountdownTime(3)
        -- showGoCtl.ShowAlpha()
        clr.coroutine(function()
            self.GO:SetActive(true)
            coroutine.yield(WaitForSeconds(1))
            self.GO:SetActive(false)
        end)
    end
end

function CoreStealView:SetGameOver(isOver) 
    self.gameOver = isOver
    self.result = Time.time - self.beginTime
end

return CoreStealView

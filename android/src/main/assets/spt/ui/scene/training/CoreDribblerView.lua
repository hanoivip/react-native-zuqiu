local BaseCoreTrainView = require("ui.scene.training.BaseCoreTrainView")
local UISoundManager = require("ui.control.manager.UISoundManager")

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
local WaitForSeconds = UnityEngine.WaitForSeconds

local Tweening = clr.DG.Tweening
local DOTween = Tweening.DOTween
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease
local LoopType = Tweening.LoopType

local CoreDribblerView = class(BaseCoreTrainView)

function CoreDribblerView:ctor()
    CoreDribblerView.super.ctor(self)
    self.button = self.___ex.button
    self.missButton = self.___ex.missButton
    self.bigCycle = self.___ex.bigCycle
    self.smallCycle = self.___ex.smallCycle
    self.goalPanel = self.___ex.goalPanel
    self.buttonGroup = self.___ex.buttonGroup
    self.successShining = self.___ex.successShining
    self.tmpPos = Vector3.zero
    self.isEnd = false
end

function CoreDribblerView:Init()
    self.buttonGroup:SetActive(true)
    self.button:SetActive(true)
    self.missButton:SetActive(false)    
end

function CoreDribblerView:InitScreenPos(pos, isStart, trainDribbler)
    self.trainDribbler = trainDribbler
    self:Init()
    self.isEnd = false
    self.buttonGroup.transform.position = pos
    self.button.transform.localScale = Vector3.one
end

function CoreDribblerView:SetScale(t)

end

function CoreDribblerView:CheckPoint(touchPoint)
    local btnPoint = self.buttonGroup.transform.position
    local dis = math.sqrt((touchPoint.x - btnPoint.x) * (touchPoint.x - btnPoint.x) + (touchPoint.y - btnPoint.y) * (touchPoint.y - btnPoint.y))
    if (dis <= 140) then
        self.tmpPos = self.buttonGroup.transform.position + Vector3(160, 40, 0)
        self:InvokeClick()
        return true
    end
    return false
end

function CoreDribblerView:InvokeClick()
    self.isEnd = true
    UISoundManager.play('Training/trainingDribblerKick', 1)
    self.successShining:SetActive(true)
    self:coroutine(function()
        coroutine.yield(WaitForSeconds(0.3))
        self.successShining:SetActive(false)
        self:InitGoal(1, self.tmpPos)
        if (self.isEnd) then
            self.button.transform.localScale = Vector3.zero
        end
    end)
end

function CoreDribblerView:InitGoal(score, pos)
    self:InitGoalPanel(score, pos)

    self.trainDribbler:JudgeGameOver()
end

function CoreDribblerView:InitGoalPanel(score, pos)
end

function CoreDribblerView:disappear()
    self.button:SetActive(false)
    self.missButton:SetActive(true)
    self:coroutine(function()
        coroutine.yield(WaitForSeconds(0.75))
        self.missButton:SetActive(false)
    end)
end

return CoreDribblerView

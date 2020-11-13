local UISoundManager = require("ui.control.manager.UISoundManager")

local BaseCoreTrainView = class(unity.base)

local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds

function BaseCoreTrainView:ctor()
    self.distance = self.___ex.distance
    self.score = self.___ex.score
    self.chanceGroup = self.___ex.chanceGroup -- table
    self.goalPanel = self.___ex.goalPanel
    self.missPanel = self.___ex.missPanel
end

function BaseCoreTrainView:start()
    self.goalPanel:SetActive(false)
    self.missPanel:SetActive(false)
end

function BaseCoreTrainView:SetDistance(distance)
    self.distance.text = tostring(distance) .. "m"
end

function BaseCoreTrainView:SetScore(score)
    self.score.text = tostring(score)
end

function BaseCoreTrainView:SetChance(chanceNum)
    for k, v in pairs(self.chanceGroup) do
        v:SetActive(false)
    end
    if chanceNum >= 1 then
        for i = 1, chanceNum do
            self.chanceGroup["obj" .. tostring(i)]:SetActive(true)
        end
    end
end

function BaseCoreTrainView:InitGoalPanel(score)
    self:coroutine(function()
        self.goalPanel:SetActive(true)
        coroutine.yield(WaitForSeconds(2))
        self.goalPanel:SetActive(false)
    end)
end

function BaseCoreTrainView:InitMissPanel()
    self:coroutine(function()
        UISoundManager.play('Training/trainingStealFailed', 1)
        self.missPanel:SetActive(true)
        coroutine.yield(WaitForSeconds(0.8))
        self.missPanel:SetActive(false)        
    end)
end

function BaseCoreTrainView:InitGameOverPanel(exp, currentExp, totalExp, chance)
end

return BaseCoreTrainView

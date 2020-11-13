local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local WaitForSeconds = UnityEngine.WaitForSeconds
local EventSystems = UnityEngine.EventSystems
local Timer = require("ui.common.Timer")
local DialogManager = require("ui.control.manager.DialogManager")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local QuestionsStartDialog = class(unity.base)

function QuestionsStartDialog:ctor()
--------Start_Auto_Generate--------
    self.titleTxt = self.___ex.titleTxt
    self.questionTitleTxt = self.___ex.questionTitleTxt
    self.questionCountTxt = self.___ex.questionCountTxt
    self.optionTrans = self.___ex.optionTrans
    self.timeCountTrans = self.___ex.timeCountTrans
    self.page1Trans = self.___ex.page1Trans
    self.selectImgTrans = self.___ex.selectImgTrans
    self.page2Trans = self.___ex.page2Trans
    self.timeSliderGo = self.___ex.timeSliderGo
    self.timeRemainTxt = self.___ex.timeRemainTxt
    self.sliderBGTrans = self.___ex.sliderBGTrans
    self.sliderTrans = self.___ex.sliderTrans
    self.closeBtnSpt = self.___ex.closeBtnSpt
    self.rewardTrans = self.___ex.rewardTrans
--------End_Auto_Generate----------
    self.optionPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/Questions/QuestionsOption.prefab"
    self.currentEventSystem = EventSystems.EventSystem.current
end

function QuestionsStartDialog:start()
	DialogAnimation.Appear(self.transform)
    self.closeBtnSpt:regOnButtonClick(function()
        self:Close()
    end)
    self.sliderMaxWith = self.sliderBGTrans.sizeDelta.x
    self.sliderHeight = self.sliderTrans.sizeDelta.y
end

function QuestionsStartDialog:Close()
    DialogAnimation.Disappear(self.transform, nil, self.closeDialog)
end

function QuestionsStartDialog:InitView(eventModel)
    self.eventModel = eventModel
    self.titleTxt.text = eventModel:GetEventName()
    local questionData = eventModel:GetQuestionData()
    self:ShowQuestion(questionData)
    self:RefreshTimer()
    self:InitRewardArea()
end

function QuestionsStartDialog:RefreshTimer()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
    self.sliderTrans.sizeDelta = Vector2(self.sliderMaxWith, self.sliderHeight)
    local questionTime = self.eventModel:GetQuestionTime()
    self.residualTimer = Timer.new(questionTime, function(time)
        local floorTime = self:KeepDecimalInt(time)
        if floorTime <= 0 then
            self.closeDialog()
            DialogManager.ShowAlertPopByLang("tips", "adventure_question_timeout")
        end
        self.timeRemainTxt.text = floorTime .. "s"
        local with = (floorTime / questionTime) * self.sliderMaxWith
        self.sliderTrans.sizeDelta = Vector2(with, self.sliderHeight)
    end)
end

function QuestionsStartDialog:RunOutOfTime()
    local currIndex = self.eventModel:GetCurrentQuestionIndex()
    local nextIndex = currIndex + 1
    self.eventModel:SetCurrentQuestionIndex(nextIndex)
    local questionData = self.eventModel:GetQuestionData()
    if questionData then
        self:ShowQuestion(questionData)
        self:RefreshTimer()
    else
        if self.answerReward then
            self.answerReward()
        end
    end
end

function QuestionsStartDialog:ShowQuestion(questionData)
    if questionData then
        res.ClearChildren(self.optionTrans)
        local optionRes = res.LoadRes(self.optionPath)
        for i, v in pairs(questionData.optionList) do
            local optionGo = Object.Instantiate(optionRes)
            optionGo.transform:SetParent(self.optionTrans, false)
            local optionSpt = optionGo:GetComponent("CapsUnityLuaBehav")
            optionSpt:InitView(v)
            local optionData = v
            optionSpt.onOptionClick = function()
                self:ClickOption(optionSpt, optionData)
            end
        end
        self.questionTitleTxt.text = questionData.questionTitle
    end
    local currIndex = self.eventModel:GetCurrentQuestionIndex()
    local pageIndexName = "page" .. currIndex .. "Trans"
    self.selectImgTrans:SetParent(self[pageIndexName], false)
end

function QuestionsStartDialog:ClickOption(optionSpt, optionData)
    self:coroutine(function()
        local isCorrect = self.eventModel:IsCorrect(optionData)
        optionSpt:ChangeOptionState(isCorrect)
        self.currentEventSystem.enabled = false
        if self.residualTimer ~= nil then
            self.residualTimer:Destroy()
        end
        coroutine.yield(WaitForSeconds(1))
        if isCorrect then
            self:RunOutOfTime()
        else
            self.closeDialog()
            DialogManager.ShowAlertPopByLang("tips", "adventure_question_fail")
        end
        self.currentEventSystem.enabled = true
    end)
end

-- 四舍五入
function QuestionsStartDialog:KeepDecimalInt(floatNum)
    local a , b = math.modf(floatNum);
    if b > 0.5 then
        a = a + 1
    end
    if a == 0 then
        a = 0
    end
    return a
end

function QuestionsStartDialog:onDestroy()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
end

function QuestionsStartDialog:InitRewardArea()
    local rewardData = self.eventModel:GetRewardData()
    res.ClearChildren(self.rewardTrans)
    for i, v in ipairs(rewardData) do
        local rewardParams = {
            parentObj = self.rewardTrans,
            rewardData = v.contents,
            isShowName = false,
            isReceive = false,
            isShowBaseReward = true,
            isShowCardReward = true,
            isShowDetail = true,
        }
        RewardDataCtrl.new(rewardParams)
    end
end

return QuestionsStartDialog

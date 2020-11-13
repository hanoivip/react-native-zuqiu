local GeneralEventModel = require("ui.models.greensward.event.GeneralEventModel")
local AdventureRewardBase = require("data.AdventureRewardBase")
local QuestionsEventModel = class(GeneralEventModel, "QuestionsEventModel")

function QuestionsEventModel:ctor()
    QuestionsEventModel.super.ctor(self)
end

function QuestionsEventModel:InitWithProtocolReward(rewardData)
    self.rewardData = {}
    for i, v in ipairs(rewardData) do
        local r = AdventureRewardBase[tostring(v)]
        if r then
            table.insert(self.rewardData, r)
        end
    end
end

function QuestionsEventModel:InitWithProtocolQuestion(questionsData)
    local result = {}
    result.questionList = {}
    for i, v in ipairs(questionsData) do
        local t = {}
        t.questionTitle = v.question
        t.answer = v.answer
        t.optionList = v.distracter
        table.insert(t.optionList, v.answer)
        table.sort(t.optionList)
        table.insert(result.questionList, t)
    end
    result.questionTime = 10
    self.questionsData = result
end

function QuestionsEventModel:GetRewardData()
    return self.rewardData or {}
end

function QuestionsEventModel:GetCurrentQuestionIndex()
    return self.currentIndex or 1
end

function QuestionsEventModel:SetCurrentQuestionIndex(index)
    self.currentIndex = index
end

function QuestionsEventModel:GetQuestionCount()
    return #self.questionsData.questionList
end

function QuestionsEventModel:GetQuestionData()
    local currIndex = self:GetCurrentQuestionIndex()
    return self.questionsData.questionList[currIndex]
end

function QuestionsEventModel:IsCorrect(optionData)
    local currIndex = self:GetCurrentQuestionIndex()
    local list = self.questionsData.questionList[currIndex]
    return list.answer == optionData
end

function QuestionsEventModel:GetQuestionTime()
    return self.questionsData.questionTime
end

function QuestionsEventModel:HasTweenExtension()
    return true
end

return QuestionsEventModel

local Model = require("ui.models.Model")

local BrainTrainingModel = class(Model, "BrainTrainingModel")

function BrainTrainingModel:ctor()
    BrainTrainingModel.super.ctor(self)
end

function BrainTrainingModel:Init()
end

function BrainTrainingModel:InitWithProtocol(data)
    assert(type(data) == "table")
end

function BrainTrainingModel:InitQuestionData(data)
    self.questionList = clone(data.qlist)
    self.quesIndex = 1
end

function BrainTrainingModel:GetCurrentQuestionData()
    return self.questionList[self.quesIndex]
end

function BrainTrainingModel:SetCurrentQuestionIndex(index)
    self.quesIndex = index
end

function BrainTrainingModel:InitBrainRankData(data)
    self.rankInfo = {}
    self.rankInfo.count = data.correctCnt
    self.rankInfo.useTime = data.useTime
    self.rankInfo.rankList = data.rank.rankTop
end

function BrainTrainingModel:GetRankInfo()
    return self.rankInfo
end

function BrainTrainingModel:GetRankList()
    return self.rankInfo.rankList
end

return BrainTrainingModel
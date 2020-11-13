local Model = require("ui.models.Model")

local TrainModel = class(Model, "TrainModel")

function TrainModel:ctor()
    TrainModel.super.ctor(self)
end

function TrainModel:InitWithProtocol(data)
    assert(type(data) == "table")
    self.data = data
end

function TrainModel:GetMaxTimes()
    return self.data.maxTimes
end

function TrainModel:SetMaxTimes(maxTimes)
    self.data.maxTimes = maxTimes
end

function TrainModel:GetTimes()
    return self.data.times
end

function TrainModel:SetTimes(times)
    self.data.times = times
end

-- 剩余次数
function TrainModel:GetRemainingTimes()
    return self.data.maxTimes - self.data.times
end

function TrainModel:SetRemaingTimes(remaingTime)
    self.data.times = self.data.maxTimes - remaingTime
end

function TrainModel:GetQuestionOpenState()
    return self.data.question.isOpen
end

function TrainModel:GetQuestionRemainTimes()
    return self.data.question.totalCnt - self.data.question.f_cnt
end

function TrainModel:SetQuestionUsedTimes()
    self.data.question.f_cnt = self.data.question.f_cnt + 1
end

function TrainModel:GetQuestionTotalTimes()
    return self.data.question.totalCnt
end

return TrainModel

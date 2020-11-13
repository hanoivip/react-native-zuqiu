local Model = require("ui.models.Model")

local TrainRankModel = class(Model, "TrainRankModel")

function TrainRankModel:ctor()
    TrainRankModel.super.ctor(self)
    self.rankData = nil
end

function TrainRankModel:InitWithProtocol(data)
    assert(type(data) == "table")
    if data ~= nil then
        self.rankData = data
    end
end

function TrainRankModel:SetIsOpenBrain(isOpen)
    self.isOpenBrain = isOpen
end

function TrainRankModel:IsOpenBrain()
    return self.isOpenBrain
end

function TrainRankModel:SetTrainType(type)
    self.currentTrainType = type
end

function TrainRankModel:GetTrainType()
    return self.currentTrainType
end

function TrainRankModel:GetSelfRank()
    return self.rankData.selfRank
end

function TrainRankModel:GetSelfInfo()
    return self.rankData.selfInfo
end

function TrainRankModel:GetCurrentGameRankList()
    return self.rankData.rankTop
end

function TrainRankModel:GetRefreshTime()
    return self.rankData.refreshTime
end

return TrainRankModel

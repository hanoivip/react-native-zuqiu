local PasterSupporterModel = require("ui.models.cardDetail.supporter.PasterSupporterModel")
local TrainingSupporterModel = require("ui.models.cardDetail.supporter.TrainingSupporterModel")
local LegendRoadSupporterModel = require("ui.models.cardDetail.supporter.LegendRoadSupporterModel")
local Model = require("ui.models.Model")

local SupporterModel = class(Model, "SupporterModel")

function SupporterModel:ctor(playerCardModel)
    SupporterModel.super.ctor(self)
    self.playerCardModel = playerCardModel
    self.pasterSupporterModel = PasterSupporterModel.new(self)
    self.trainingSupporterModel = TrainingSupporterModel.new(self)
    self.legendRoadSupporterModel = LegendRoadSupporterModel.new(self)
end

function SupporterModel:SetTrainingData(supportTraining, selfTraining)
    self.trainingSupporterModel:InitWithProtocol(supportTraining, selfTraining)
end

function SupporterModel:SetPasterSupporterModel(pasterSupporterModel)
    self.pasterSupporterModel = pasterSupporterModel
end

function SupporterModel:GetPasterSupporterModel()
    return self.pasterSupporterModel
end

function SupporterModel:GetTrainingSupporterModel()
    return self.trainingSupporterModel
end

function SupporterModel:GetLegendRoadSupporterModel()
    return self.legendRoadSupporterModel
end

function SupporterModel:GetCardModel()
    return self.playerCardModel
end

function SupporterModel:SetSupportCardModel(supportPlayerCardModel)
    self.supportPlayerCardModel = supportPlayerCardModel
end

function SupporterModel:GetSupportCardModel()
    if not self.supportPlayerCardModel then
       local spcid = self.playerCardModel:GetSpcid()
       if spcid ~= 0 then
           local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")
           local playerCardModel = PlayerCardModel.new(spcid)
           self:SetSupportCardModel(playerCardModel)
           self:InitInfo(true)
       end
    end
    return self.supportPlayerCardModel
end

--获取当前选择达到的特训进度 {chapter = 4, stage = 5,}
function SupporterModel:GetCurTrainingInfo()
    local trainingSupporterModel = self:GetTrainingSupporterModel()
    local minTraining = trainingSupporterModel:GetCurTrainingInfo()
    return minTraining
end

-- 特训选择的本卡/助阵卡
function SupporterModel:GetSelectTrainingType()
    local trainingSupporterModel = self:GetTrainingSupporterModel()
    local trainingType = trainingSupporterModel:GetSelectTrainingType()
    return trainingType
end

function SupporterModel:GetSelectLegendRoadType()
    local legendRoadSupporterModel = self:GetLegendRoadSupporterModel()
    return legendRoadSupporterModel:GetSelectLegendRoadType()
end

function SupporterModel:InitInfo(bCardChange)
    local supportPlayerCardModel = self:GetSupportCardModel()
    supportPlayerCardModel:InitPasterModel()
    supportPlayerCardModel:InitEquipsAndSkills()

    if bCardChange then
        local trainingSupporterModel = self:GetTrainingSupporterModel()
        local legendRoadSupporterModel = self:GetLegendRoadSupporterModel()
        local playerCardModel = self:GetCardModel()
        if playerCardModel:IsHasSupportCard() then
            trainingSupporterModel:SetSelectTrainingType(playerCardModel:GetStType())
            legendRoadSupporterModel:SetSelectLegendRoadType(playerCardModel:GetSlrType())
        else
            trainingSupporterModel:SetSelectTrainingType(nil)
            legendRoadSupporterModel:SetSelectLegendRoadType(nil)
        end
    end
end

return SupporterModel

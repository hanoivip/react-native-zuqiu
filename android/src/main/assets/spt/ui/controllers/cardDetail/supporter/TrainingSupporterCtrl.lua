local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local SubBaseSupporterCtrl = require("ui.controllers.cardDetail.supporter.SubBaseSupporterCtrl")
local TrainingSupporterCtrl = class(SubBaseSupporterCtrl, "TrainingSupporterCtrl")

local prefabPath = "Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/Supporter/TrainingSupportBoard.prefab"

function TrainingSupporterCtrl:ctor(trainingSupporterModel, parentTrans)
    TrainingSupporterCtrl.super.ctor(self, trainingSupporterModel, parentTrans, prefabPath)
end

function TrainingSupporterCtrl:Init()

end

function TrainingSupporterCtrl:OnConsumeCard(consumeData)
    clr.coroutine(function()
        local response = req.cardUnlockTrainingBase(consumeData.pcid, consumeData.trainId, consumeData.subId, consumeData.pcids)
        if api.success(response) then
            local data = response.val
            local supporterModel = self.model:GetSupportModel()
            local supportTraining = self.model:GetSupportTraining()
            local selfTraining = data.trainingInfo.training
            self.playerCardsMapModel = PlayerCardsMapModel:new()
            self.playerCardsMapModel:ResetCardData(data.card.pcid, data.card)
            self.playerCardsMapModel:RemoveCardData(data.cost)
            supporterModel:SetTrainingData(supportTraining, selfTraining)
            EventSystem.SendEvent("Supporter_Select")
        end
    end)
end

function TrainingSupporterCtrl:OnEnterScene()
    TrainingSupporterCtrl.super.OnEnterScene(self)
    EventSystem.AddEvent("TrainingSupporter_ConsumeCard", self, self.OnConsumeCard)
end

function TrainingSupporterCtrl:OnExitScene()
    TrainingSupporterCtrl.super.OnExitScene(self)
    EventSystem.RemoveEvent("TrainingSupporter_ConsumeCard", self, self.OnConsumeCard)
end

return TrainingSupporterCtrl

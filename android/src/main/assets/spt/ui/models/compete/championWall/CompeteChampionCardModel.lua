local OtherCardModel = require("ui.models.cardDetail.OtherCardModel")
local TrainingCard = require("data.TrainingCard")

local CompeteChampionCardModel = class(OtherCardModel, "CompeteChampionCardModel")

-- 针对争霸赛冠军墙而做的精简信息的CardModel
function CompeteChampionCardModel:ctor(pcid, otherPlayerCardsMapModel, otherTeamsModel)
    CompeteChampionCardModel.super.ctor(self, pcid, otherPlayerCardsMapModel, otherTeamsModel)
end

function CompeteChampionCardModel:HasPaster()
    return self.cacheData.pType ~= nil
end

function CompeteChampionCardModel:GetPasterMainType()
    return self.cacheData.pType or -1
end

function CompeteChampionCardModel:GetTrainingLevel()
    local result = nil
    if self.cacheData.training ~= nil and self.cacheData.training.chapter > 0 then
        result = TrainingCard[tostring(self.cacheData.training.chapter)].pictureID
    end
    return result
end

return CompeteChampionCardModel

local DreamLeagueCardModel = require("ui.models.dreamLeague.DreamLeagueCardModel")
local PlayerDreamCardsMapModel = require("ui.models.dreamLeague.PlayerDreamCardsMapModel")
local Model = require("ui.models.Model")
local CongratulationsDreamCardPageModel = class(Model, "CongratulationsDreamCardPageModel")

function CongratulationsDreamCardPageModel:ctor(rewardData)
    self.rewardData = rewardData
    self.models = {}
    self.playerDreamCardsMapModel = PlayerDreamCardsMapModel.new()
    for k,v in pairs(self.rewardData.dreamCard) do
        self.playerDreamCardsMapModel:AddCardData(v.dcid, v)
        local model = DreamLeagueCardModel.new(v.dcid)
        table.insert(self.models, model)
    end
    self.selectCards = {}
end

function CongratulationsDreamCardPageModel:GetAllCards()
    return self.models
end

function CongratulationsDreamCardPageModel:AddSelectCards(dcid)
    for k,v in pairs(self.selectCards) do
        if v == dcid then
            return
        end
    end
    table.insert(self.selectCards, dcid)
end

function CongratulationsDreamCardPageModel:RemoveSelectCards(dcid)
    for k, v in pairs(self.selectCards) do
        if v == dcid then
            self.selectCards[k] = nil
            return
        end
    end
end

function CongratulationsDreamCardPageModel:GetAllSelectCards()
    local selectDcids = {}
    for i,v in pairs(self.selectCards) do
        local dcid = tostring(v)
        table.insert(selectDcids, dcid)
    end
    return selectDcids
end

function CongratulationsDreamCardPageModel:SellCardsCallBack(soldDcids)
    self.selectCards = {}
    local tempModels = {}
    for k,v in pairs(self.models) do
        local isContain = self:CheckContainsDcids(v, soldDcids)
        if not isContain then
            table.insert(tempModels, v)
        end
    end
    self.models = tempModels
end

function CongratulationsDreamCardPageModel:CheckContainsDcids(model, dcids)
    local mDcid = tostring(model:GetDcid())
    for k,v in pairs(dcids) do
        if tostring(v) == mDcid then
            return true
        end
    end
    return false
end

return CongratulationsDreamCardPageModel

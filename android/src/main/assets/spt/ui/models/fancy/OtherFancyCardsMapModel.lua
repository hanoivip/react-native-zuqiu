local FancyCardsMapModel = require("ui.models.fancy.FancyCardsMapModel")
local OtherFancyCardModel = require("ui.models.fancy.OtherFancyCardModel")
local OtherFancyCardsMapModel = class(FancyCardsMapModel, "OtherFancyCardsMapModel")

function OtherFancyCardsMapModel:ctor()
    OtherFancyCardsMapModel.super.ctor(self)
end

function OtherFancyCardsMapModel:InitWithProtocol(data)
    self.data = {}
    self.data.fancyCard = data and data or {}
end

function OtherFancyCardsMapModel:IsMe()
    return false
end

function OtherFancyCardsMapModel:GetCardModel()
    return OtherFancyCardModel
end

function OtherFancyCardsMapModel:IsNewTip(cardId)
    return false
end

function OtherFancyCardsMapModel:SetNewTip(cardId, bNew)
    return
end

return OtherFancyCardsMapModel

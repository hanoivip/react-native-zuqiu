local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local CardOpenFromType = require("ui.controllers.cardDetail.CardOpenFromType")
local ChemicalCardView = require("ui.scene.cardDetail.ChemicalCardView")

local CollaborateCardView = class(ChemicalCardView)

function CollaborateCardView:ctor()
    self.super.ctor(self)
end

function CollaborateCardView:InitView(cardId, isExist, cardRes)
    self.cardId = cardId
    local cardModel = StaticCardModel.new(cardId)
    cardModel:SetOpenFromPageType(CardOpenFromType.COLLABORATE)
    if not self.cardView then
        local cardObject = Object.Instantiate(cardRes)
        self.cardView = res.GetLuaScript(cardObject)
        cardObject.transform:SetParent(self.cardArea, false)
    end
    self.cardView:InitView(cardModel, isExist)
end

function CollaborateCardView:ExtraAttribute(addValue)
    self.cardView:ExtraAttribute(addValue)
end

function CollaborateCardView:OnCardClick()
    if self.cardClick then 
        self.cardClick(self.cardId)
    end
end

return CollaborateCardView

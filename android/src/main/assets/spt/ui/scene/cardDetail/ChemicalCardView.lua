local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local ChemicalCardView = class(unity.base)

function ChemicalCardView:ctor()
    self.cardArea = self.___ex.cardArea
    self.btnCard = self.___ex.btnCard
    self.btnCard:regOnButtonClick(function()
        self:OnCardClick()
    end)
end

function ChemicalCardView:InitView(cardId, isExist, cardRes)
    self.cardId = cardId
    local cardModel = StaticCardModel.new(cardId)
    if not self.cardView then
        local cardObject = Object.Instantiate(cardRes)
        self.cardView = res.GetLuaScript(cardObject)
        cardObject.transform:SetParent(self.cardArea, false)
    end
    self.cardView:InitView(cardModel, isExist)
end

function ChemicalCardView:ExtraAttribute(addValue)
    self.cardView:ExtraAttribute(addValue)
end

function ChemicalCardView:OnCardClick()
    if self.cardClick then 
        self.cardClick(self.cardId)
    end
end

return ChemicalCardView

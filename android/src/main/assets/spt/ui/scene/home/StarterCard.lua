local LuaButton = require("ui.control.button.LuaButton")
local StarterCard = class(LuaButton)

function StarterCard:ctor()
    StarterCard.super.ctor(self)
    self.cardParent = self.___ex.cardParent
    self.starterCard, self.starterCardView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/CircleCard.prefab")
    self.starterCard.transform:SetParent(self.cardParent.transform, false)
end

function StarterCard:GetStarterCardView()
    return self.starterCardView
end

function StarterCard:InitView(cardModel)
    self.starterCardView:InitView(cardModel)
end

function StarterCard:start()
    self:regOnButtonClick(function()
        self:OnCardClick()
    end)
end

function StarterCard:OnCardClick()
    if self.clickCard then
        self.clickCard()
    end
end

return StarterCard

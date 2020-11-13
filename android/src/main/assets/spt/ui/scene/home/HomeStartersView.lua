local HomeStartersView = class(unity.base)

function HomeStartersView:ctor()
    self.card, self.starterScript = self:GetStartersRes(self.transform)
end

function HomeStartersView:GetStartersRes(cardParent)
    if not self.starterScript then 
        self.card, self.starterScript = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
        self.card.transform:SetParent(cardParent, false)
    end
    
    return self.card, self.starterScript
end

function HomeStartersView:InitCardView(cardModel, cardResourceCache)
    self.starterScript:SetCardResourceCache(cardResourceCache)
    self.starterScript:InitView(cardModel)
end

return HomeStartersView

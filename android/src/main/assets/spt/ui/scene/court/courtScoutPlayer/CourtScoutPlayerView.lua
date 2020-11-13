local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local CourtScoutPlayerView = class(unity.base)

function CourtScoutPlayerView:ctor()
    self.cardParent = self.___ex.cardParent
    self.btnCard = self.___ex.btnCard
end

function CourtScoutPlayerView:start()
    self.btnCard:regOnButtonClick(function()
        self:OnBtnCard()
    end)
end

function CourtScoutPlayerView:OnBtnCard()
    if self.clickCard then 
        self.clickCard(self.cid, self.sortIndex)
    end
end

function CourtScoutPlayerView:InitView(model, cardRes, cardResourceCache, sortIndex)
    self.sortIndex = sortIndex
    self.cid = model:GetCid()
    if not self.cardView then
        local cardObject = Object.Instantiate(cardRes)
        self.cardView = res.GetLuaScript(cardObject)
        cardObject.transform:SetParent(self.cardParent.transform, false)
    end
    self.cardView:SetCardResourceCache(cardResourceCache)
    self.cardView:InitView(model)
end

return CourtScoutPlayerView

local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local ItemDetailPlayerView = class(unity.base)

function ItemDetailPlayerView:ctor()
    self.cardArea = self.___ex.cardArea
    self.btnCard = self.___ex.btnCard
    self.playerName = self.___ex.playerName
end

function ItemDetailPlayerView:start()
    self.btnCard:regOnButtonClick(function()
        if self.onClickCard then
            self.onClickCard()
        end
    end)
end

function ItemDetailPlayerView:InitView(playerCardModel)
    self.playerName.text = tostring(playerCardModel:GetName())
end

function ItemDetailPlayerView:ClearPlayerObject()
    local count = self.cardArea.childCount
    for i = 0, count - 1 do
        Object.Destroy(self.cardArea:GetChild(i).gameObject)
    end
end

function ItemDetailPlayerView:AddPlayerCard(playerCardObject)
    playerCardObject.transform:SetParent(self.cardArea, false)
end

return ItemDetailPlayerView

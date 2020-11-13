local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CardMoreInfoCorrelationView = class(unity.base)

local correlationPath = "Assets/CapstonesRes/Game/UI/Scene/CardMoreInfo/CorrelationItem.prefab"

function CardMoreInfoCorrelationView:ctor()
    self.contentRect = self.___ex.contentRect
    self.playerNameTxt = self.___ex.playerNameTxt
    self.none = self.___ex.none
end

function CardMoreInfoCorrelationView:InitView(cardModel)
    local mySelfCid = cardModel:GetCid()
    local correlationCards = cardModel:GetJoinedCorrelationList()
    local maxCorrelationItem = 0
    for k, cid in pairs(correlationCards) do
        local obj, spt = res.Instantiate(correlationPath)
        obj.transform:SetParent(self.contentRect, false)
        spt:InitView(cid, mySelfCid, self:GetCardRes())
        maxCorrelationItem = maxCorrelationItem + 1
    end
    GameObjectHelper.FastSetActive(self.playerNameTxt.transform.parent.gameObject, maxCorrelationItem ~= 0)

    self.playerNameTxt.text = lang.trans("correlation_invoved", cardModel:GetName())
  
    GameObjectHelper.FastSetActive(self.none, maxCorrelationItem == 0)
end

function CardMoreInfoCorrelationView:GetCardRes()
    if not self.cardRes then
        self.cardRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/CardDetail/ChimicalCard.prefab")
    end
    return self.cardRes
end

return CardMoreInfoCorrelationView

local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local CardMoreInfoBestParterItemView = class(unity.base)


function CardMoreInfoBestParterItemView:ctor()
    self.contentRect = self.___ex.contentRect
end

function CardMoreInfoBestParterItemView:InitView(cidList, cardModel)
    local cardsMap = cardModel:GetCardsMap()
    if type(cidList) == "table" then
        for k, v in pairs(cidList) do
            local model = StaticCardModel.new(v)
            local isExist = self:IsExist(v, cardsMap)
            local player = Object.Instantiate(self:GetCardRes())
            spt = res.GetLuaScript(player)
            spt:InitView(model, isExist)
            player.transform:SetParent(self.contentRect, false)
            player.transform.localScale = Vector3(0.6, 0.6, 1)
        end
    end
end

function CardMoreInfoBestParterItemView:GetCardRes()
    if not self.cardRes then
        self.cardRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/CardDetail/ChimicalCard.prefab")
    end
    return self.cardRes
end

function CardMoreInfoBestParterItemView:IsExist(needcid, cardsMap)
    local isExist = false
    for k, v in pairs(cardsMap) do
        local cid = v.cid
        if cid == needcid then
            isExist = true
            break
        end
    end
    return isExist
end

return CardMoreInfoBestParterItemView

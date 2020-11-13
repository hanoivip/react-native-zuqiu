local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")
local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local Object = UnityEngine.Object
local CardMoreInfoChemicalItemView = class(unity.base)


function CardMoreInfoChemicalItemView:ctor()
    self.chemicalPlayerArea = self.___ex.chemicalPlayerArea
    self.cards = self.___ex.cards
    self.plusValue = self.___ex.plusValue
    self.chemicalName = self.___ex.chemicalName
    self.bg = self.___ex.bg
    self.add = self.___ex.add
    self.addValue = self.___ex.addValue
    self.leftBg = self.___ex.leftBg
    self.rightBg = self.___ex.rightBg
end

function CardMoreInfoChemicalItemView:InitView(cidAndchemicalData, mySelfCid, cardRes)
    local mapModel = PlayerCardsMapModel.new()
    local cardsMap = mapModel:GetCardCidMaps()
    local pcid = mapModel:GetPcidByCid(cidAndchemicalData.cid)
    if pcid then
        self.cardModel = PlayerCardModel.new(pcid)
    else
        self.cardModel = StaticCardModel.new(cidAndchemicalData.cid)
    end
    local cardObject = Object.Instantiate(cardRes)
    cardSpt = res.GetLuaScript(cardObject)
    cardObject.transform:SetParent(self.chemicalPlayerArea, false)
    local isExist = self:IsExist(cidAndchemicalData.cid, cardsMap)
    cardSpt:InitView(self.cardModel, isExist)

    -- 化学反应球员部分
    local chemicalData = self.cardModel:GetChemicalData()
    local cids = {}
    self.chemicalName.text = cidAndchemicalData.chemicalData.chemicalName
    self.plusValue.text = lang.trans("allAttribute_moreInfo", cidAndchemicalData.chemicalData.chemicalBonus)
    cids = cidAndchemicalData.chemicalData.cids

    local isActivateCardCount = 0
    local totalPlayersNum = 0
    self.useCardsMap = {}
    for k, v in pairs(self.cards) do
        local index = string.sub(k, 2)
        local needPlayerCid = cids[tonumber(index)]
        if needPlayerCid and needPlayerCid ~= "" then
            local isExist = self:IsExist(needPlayerCid, cardsMap)
            v:InitView(needPlayerCid, isExist, cardRes)
            self.useCardsMap[tostring(needPlayerCid)] = v
            GameObjectHelper.FastSetActive(v.gameObject, true)
            if isExist then 
                isActivateCardCount = isActivateCardCount + 1
            end
            totalPlayersNum = totalPlayersNum + 1
        else
            GameObjectHelper.FastSetActive(v.gameObject, false)
        end
    end

    self:ActivateChemicalAction(tobool(isActivateCardCount >= totalPlayersNum))
end 

function CardMoreInfoChemicalItemView:ActivateChemicalAction(isActive)
    if isActive then
        self.bg.color = Color(1, 1, 1)
        self.leftBg.color = Color(1, 1, 1)
        self.rightBg.color = Color(1, 1, 1)
        self.plusValue.color = Color(94/255, 70/255, 9/255)
        local extraTotalAttribute = 0
        for needPlayerCid, v in pairs(self.useCardsMap) do
            local addValue = self.cardModel:GetChemicalPlayersAddValue(needPlayerCid)
            v:ExtraAttribute(addValue)
            extraTotalAttribute = extraTotalAttribute + addValue
        end
        GameObjectHelper.FastSetActive(self.add, extraTotalAttribute > 0)
        self.addValue.text = lang.transstr("extra_value") .. extraTotalAttribute
    else
        self.bg.color = Color(0, 1, 1)
        self.leftBg.color = Color(0, 1, 1)
        self.rightBg.color = Color(0, 1, 1)
        self.plusValue.color = Color(53/255, 53/255, 53/255)
        GameObjectHelper.FastSetActive(self.add, false)
    end
end

function CardMoreInfoChemicalItemView:IsExist(needcid, cardsMap)
    local isExist = false
    for k, v in pairs(cardsMap) do
        if k == needcid then
            isExist = true
            break
        end
    end
    return isExist
end

return CardMoreInfoChemicalItemView

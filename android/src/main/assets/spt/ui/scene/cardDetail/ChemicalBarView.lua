local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local Card = require("data.Card")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ChemicalBarView = class(unity.base)

function ChemicalBarView:ctor()
    self.plusValue = self.___ex.plusValue
    self.chemicalName = self.___ex.chemicalName
    self.cards = self.___ex.cards
    self.bg = self.___ex.bg
    self.leftBg = self.___ex.leftBg
    self.rightBg = self.___ex.rightBg
    self.add = self.___ex.add
    self.addValue = self.___ex.addValue
    self.isActive = false
end

function ChemicalBarView:GetChimicalCardData(needPlayerCid, cardsMap)
    local isExist = false
    for k, v in pairs(cardsMap) do
        local cid = v.cid
        if cid == needPlayerCid then
            isExist = true
            break
        end
    end
    return isExist
end

function ChemicalBarView:InitView(index, itemData, cardModel, cardRes)
    self.index = index
    local chemicalBonus = itemData.chemicalBonus
    self.plusValue.text = "+" .. chemicalBonus .. lang.transstr("allAttribute")
    self.chemicalName.text = itemData.chemicalName
    local cardsMap = cardModel:GetCardsMap()
    local currentCid = cardModel:GetCid()
    local cids = {}
    for i, cid in ipairs(itemData.cids) do
        if cid ~= currentCid then 
            table.insert(cids, cid)
        end
    end
    local isActivateCardCount = 0
    local totalPlayersNum = 0
    self.useCardsMap = {}
    for k, v in pairs(self.cards) do
        local index = string.sub(k, 2)
        local needPlayerCid = cids[tonumber(index)]
        if needPlayerCid and needPlayerCid ~= "" then 
            local isExist = self:GetChimicalCardData(needPlayerCid, cardsMap)
            v.cardClick = function(cardId) self:OnCardClick(cardId) end
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

    self.isActive = tobool(isActivateCardCount >= totalPlayersNum)
    if self.isActive then
        self.bg.color = Color(1, 1, 1)
        self.leftBg.color = Color(1, 1, 1)
        self.rightBg.color = Color(1, 1, 1)
        self.plusValue.color = Color(94/255, 70/255, 9/255)
        local extraTotalAttribute = 0
        for needPlayerCid, v in pairs(self.useCardsMap) do
            local addValue = cardModel:GetChemicalPlayersAddValue(needPlayerCid)
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

function ChemicalBarView:OnCardClick(cardId)
    if self.cardClick then 
        self.cardClick(cardId, self.isActive, self.index)
    end
end

return ChemicalBarView

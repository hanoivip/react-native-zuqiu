-- local CardSymbolModel = require("ui.models.cardDetail.CardSymbolModel")
local PlayerLetterInsidePlayerModel = require("ui.models.playerLetter.PlayerLetterInsidePlayerModel")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local LetterCards = require("data.LetterCards")
local HeroHallMapModel = require("ui.models.heroHall.main.HeroHallMapModel")
local CardSymbolHelper = require("ui.models.cardDetail.CardSymbolHelper")
local Model = require("ui.models.Model")
local CardSymbolModel = class(Model)

function CardSymbolModel:ctor()
end

--isMaskExistCard 是否过滤掉已拥有的卡牌
function CardSymbolModel:InitAboutOtherFlag(isMaskExistCard, showChemical, showBestPartener, showPlayerLetter)
    self.isMaskExistCard = isMaskExistCard
    self.showChemical = showChemical
    self.showBestPartener = showBestPartener
    self.showPlayerLetter = showPlayerLetter
    self.playerCardsMapModel = isMaskExistCard and PlayerCardsMapModel.new()
    self.cCidList = showChemical and CardSymbolHelper.GetChemicalCidsInTeams()
    self.bCidList = showBestPartener and CardSymbolHelper.GetBestPartnerInTeams()
    self.playerLetterInsidePlayerModel = showPlayerLetter and PlayerLetterInsidePlayerModel.new()
    self.heroHallMapModel = isMaskExistCard and HeroHallMapModel.new()
end

function CardSymbolModel:GetShowSymbolData(cid, baseId, letterList)
    local flagData = {}
    if self.isMaskExistCard and self.playerCardsMapModel:IsExistCardID(cid) then
        return flagData
    end
    flagData.showChemical = self.cCidList[cid] and true or false
    flagData.showBestPartener = self.bCidList[cid] and true or false
    flagData.showPlayerLetter = self.showPlayerLetter and self.playerLetterInsidePlayerModel:IsBelongToLetterCard(cid) or false
    flagData.showPlayerLetter = flagData.showPlayerLetter and LetterCards[cid][1]
    if baseId then
        flagData.showHeroHall =  self.heroHallMapModel:CheckCardIsInside(baseId) and true or false
    end
    flagData.showActivityLetter = self:CheckActivityLetter(cid, letterList)
    return flagData
end

-- 是否为当期活动来信球员
function CardSymbolModel:CheckActivityLetter(cid, letterList)
    if not letterList then return false end
    for i, v in ipairs(letterList) do
        if v == cid then
            return true
        end
    end
    return false
end

return CardSymbolModel

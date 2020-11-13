local EventSystem = require ("EventSystem")
local FancyImproveModel = require("ui.models.fancy.FancyImproveModel")
local FancyCard = require("data.FancyCard")
local FancyCardModel = require("ui.models.fancy.FancyCardModel")
local Model = require("ui.models.Model")
local FancyCardsMapModel = class(Model, "FancyCardsMapModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")

function FancyCardsMapModel:ctor()
    FancyCardsMapModel.super.ctor(self)
end

function FancyCardsMapModel:Init(data)
    if not data then
        data = cache.GetFancyCardsMap() or {fancyCard = {}}
    end
    self.data = data
    self.fancyImproveModel = FancyImproveModel.new(self)
    local playerInfoModel = PlayerInfoModel.new()
    self.saveKey = playerInfoModel:GetID() .. "FancyNew"
end

function FancyCardsMapModel:InitWithProtocol(data)
    local fancyCardsMap = {}
    fancyCardsMap.fancyCard = data or {}
    cache.SetFancyCardsMap(fancyCardsMap)
    self:Init(fancyCardsMap)
    self.fancyImproveModel:InitData()
end

function FancyCardsMapModel:GetAllFancyCard()
    return self.data.fancyCard
end

function FancyCardsMapModel:UpdateCard(cardId, star, num)
    local cardData = {star = star, num = num}
    self:UpdateCardData(cardId, cardData)
end

function FancyCardsMapModel:UpdateCardData(cardId, cardData)
    local upState = self:CheckLightOrStar(cardId, cardData)
    self.data.fancyCard[cardId] = cardData
    if upState then
        self:ImproveFancyCard(cardId, cardData)
    end
    cache.SetFancyCardsMap(self.data)
end

function FancyCardsMapModel:GetNewData()
    return cache.GetFancyNew(self.saveKey) or {}
end

function FancyCardsMapModel:IsNewTip(cardId)
    local newData = self:GetNewData()
    return newData[cardId] and true or false
end

function FancyCardsMapModel:SetNewTip(cardId, bNew)
    local newData = clone(self:GetNewData())
    if bNew then
        newData[cardId] = 1
    elseif not newData[cardId] then
        return
    else
        newData[cardId] = nil
    end
    cache.SetFancyNew(self.saveKey, newData)
end

function FancyCardsMapModel:IsHaveNewCard()
    return next(self:GetNewData()) and true or false
end

function FancyCardsMapModel:GetFancyCardData(cardId)
	return self.data.fancyCard[cardId]
end

function FancyCardsMapModel:UpdateFromReward(rewardTable)
    assert(rewardTable and type(rewardTable) == "table")
    if not rewardTable.fancyCard then return end
    for i, v in ipairs(rewardTable.fancyCard) do
        local cardId = v.id
        local star = v.star
        local num = v.num
        self:UpdateCard(cardId, star, num)
    end

    EventSystem.SendEvent("FancyCardsMapModel_UpdateFromReward")
end

function FancyCardsMapModel:IsMe()
	return true
end

function FancyCardsMapModel:ImproveFancyCard(cardId, cardData)
    local groupId = FancyCard[cardId].groupID
    self.fancyImproveModel:RefreshGroupData(groupId)
end

function FancyCardsMapModel:CheckLightOrStar(cardId, cardData)
    if not self.data.fancyCard[cardId] then
        self:SetNewTip(cardId, true)
        return true
    end
    if self.data.fancyCard[cardId] then
        local oldStar = self.data.fancyCard[cardId].star
        local newStar = cardData.star
        if oldStar ~= newStar then
            return true
        end
    end
    return false
end

function FancyCardsMapModel:GetCardModel()
    return FancyCardModel
end

function FancyCardsMapModel:GetCardImprove(cid)
    local totalAttrs = self.fancyImproveModel:GetPlayerCardAttrs(cid)
    return totalAttrs
end

function FancyCardsMapModel:GetGroupsAttr()
    local attrs = self.fancyImproveModel:GetGroupsAttr()
    return attrs
end

return FancyCardsMapModel

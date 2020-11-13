local Model = require("ui.models.Model")
local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")
local InvalidCardModel = require("ui.models.cardDetail.InvalidCardModel")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local HeroHallMapModel = require("ui.models.heroHall.main.HeroHallMapModel")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local Card = require("data.Card")

local HeroHallStatueModel = class(Model, "HeroHallStatueModel")

function HeroHallStatueModel:ctor(hallData, heroHallDataModel)
    self.playerCardsMapModel = PlayerCardsMapModel.new()
    self.heroHallMapModel = HeroHallMapModel.new()

    self.hallId = hallData.id
    self.attributeType = hallData.attributeType
    self.hallData = hallData
    self.heroHallDataModel = heroHallDataModel
    self.statueList = {}
    self.cardModelList = {}

    self.count = 0          -- 雕像总数
    for baseId, statueData in pairs(hallData.list) do
        self.count = self.count + 1
        statueData.index = self.heroHallDataModel:GetStatueIndex(self.hallId, baseId)
        statueData.baseId = tostring(baseId)
        statueData.hallId = self.hallId
        local maxCid = nil
        local maxQuality = -1
        local cardModel = nil
        local maxValue = -1
        local maxCardPcid = -1
        local cidsMap = self.playerCardsMapModel:GetCidsMapByBaseID(statueData.baseId)
        if cidsMap then
            -- 循环获得最高品质
            for cid, pcids in pairs(cidsMap) do
                local fixQuality = CardHelper.GetCardFixQualityNum(Card[cid].quality, Card[cid].qualitySpecial)
                if fixQuality > maxQuality then
                    maxCid = cid
                    maxQuality = fixQuality
                end
            end
            -- 循环获得最高等级
            for pcid, isActivate in pairs(cidsMap[maxCid]) do
                local tempCardModel = PlayerCardModel.new(pcid)
                local cardValue = tempCardModel:GetValue()
                if cardValue > maxValue then
                    cardModel = tempCardModel
                    maxValue = cardValue
                    maxCardPcid = pcid
                end
            end
            statueData.hasCard = true
        else
            statueData.hasCard = false
        end
        statueData.cardValid = true
        if tonumber(maxCardPcid) < 0 or cardModel == nil then
            local cid = self.playerCardsMapModel:GetMaxQualityCidByBaseID(statueData.baseId, 1)
            if cid == nil then
                cid = self.playerCardsMapModel:GetMaxQualityCidByBaseID(statueData.baseId, 0)
                statueData.cardValid = false
                cardModel = InvalidCardModel.new(cid)
            else
                cardModel = StaticCardModel.new(cid)
            end
        end
        cardModel.index = statueData.index
        table.insert(self.cardModelList, cardModel)

        statueData.cardName = tostring(self.playerCardsMapModel:GetCardNameByBaseID(statueData.baseId))
        statueData.statueQualityDesc = tostring(self.heroHallDataModel:GetStatueQualityDescByLevel(statueData.level))
        statueData.improveDesc = self.heroHallDataModel:GetImproveDesc(statueData)
        statueData.hallPicRes = self.heroHallDataModel:GetStatueIconByLevel(statueData.level)
        statueData.hlvlCondition = self.heroHallDataModel:GetImproveSkillCondition(statueData.level)

        table.insert(self.statueList, statueData)
    end

    table.sort(self.statueList, function(a, b)
        return a.index < b.index
    end)
    table.sort(self.cardModelList, function(a, b)
        return a.index < b.index
    end)
    self.currStatueIndex = 1         -- 当前雕像序号

    self.isInUpgradeEfx = false
end

function HeroHallStatueModel:GetStatueList()
    return self.statueList
end

function HeroHallStatueModel:GetHallData()
    return self.hallData
end

function HeroHallStatueModel:GetHeroHallDataModel()
    return self.heroHallDataModel
end

-- 升级雕像后更新
function HeroHallStatueModel:UpdateAfterUpgrade(newStatueData)
    self.heroHallMapModel:UpdateCacheAfterUpgrade(self.hallId, self.statueList)
end

function HeroHallStatueModel:IsCurrStatueMaxLevel()
    return self.statueList[self.currStatueIndex].level == self.heroHallDataModel:GetStatueMaxLevel()
end

function HeroHallStatueModel:GetCurrStatueIndex()
    return self.currStatueIndex
end

function HeroHallStatueModel:GetCurrStatue()
    return self:GetStatueByIndex(self.currStatueIndex)
end

function HeroHallStatueModel:GetStatueByIndex(index)
    return self.statueList[index]
end

function HeroHallStatueModel:PreviousStatue()
    self.currStatueIndex = self.currStatueIndex - 1
    if self.currStatueIndex < 1 then
        self.currStatueIndex = self.count
    end
end

function HeroHallStatueModel:NextStatue()
    self.currStatueIndex = self.currStatueIndex + 1
    if self.currStatueIndex > self.count then
        self.currStatueIndex = 1
    end
end

function HeroHallStatueModel:GetIndexString()
    return tostring(self.currStatueIndex) .. "/" .. tostring(self.count)
end

function HeroHallStatueModel:GetCurrStatueBaseId()
    return self:GetStatusBaseIdByIndex(self.currStatueIndex)
end

function HeroHallStatueModel:GetStatusBaseIdByIndex(index)
    return self.statueList[index].baseId
end

function HeroHallStatueModel:GetHallId()
    return self.hallId
end

function HeroHallStatueModel:GetTitle()
    return tostring(self.heroHallDataModel:GetHallConfigDataById(self.hallId).name)
end

function HeroHallStatueModel:GetDesc()
    return tostring(self.heroHallDataModel:GetHallConfigDataById(self.hallId).desc)
end

function HeroHallStatueModel:GetCurrStatueImproveDesc()
    return self:GetStatueImproveDescByIndex(self.currStatueIndex)
end

function HeroHallStatueModel:GetStatueImproveDescByIndex(index)
    return self.statueList[index].improveDesc
end

function HeroHallStatueModel:GetCurrStatueAttributes()
    return self:GetStatueAttributesByIndex(self.currStatueIndex)
end

function HeroHallStatueModel:GetStatueAttributesByIndex(index)
    local attributes = {}
    local statue = self:GetStatueByIndex(index)
    for k, attributeName in pairs(self.attributeType) do
        attributes[attributeName] = statue.attributes[attributeName]
    end
    return attributes, statue.fixAttribute, statue.basicAttribute, statue.multiAttribute
end

function HeroHallStatueModel:GetCurrCardModel()
    return self:GetCardModelByIndex(self.currStatueIndex)
end

function HeroHallStatueModel:GetCardModelByIndex(index)
    return self.cardModelList[index]
end

function HeroHallStatueModel:GetPreLevel()
    return self:GetCurrStatueLevel() - 1
end

function HeroHallStatueModel:GetCurrLevel()
    return self:GetCurrStatueLevel()
end

function HeroHallStatueModel:GetNextLevel()
    return self:GetCurrStatueLevel() + 1
end

function HeroHallStatueModel:GetCurrStatueLevel()
    return self:GetStatueLevelByIndex(self.currStatueIndex)
end

function HeroHallStatueModel:GetStatueLevelByIndex(index)
    return self.statueList[index].level
end

function HeroHallStatueModel:GetPreLevelStatueIcon()
    return self:GetStatueIconByLevel(self:GetPreLevel())
end

function HeroHallStatueModel:GetCurrLevelStatueIcon()
    return self:GetStatueIconByLevel(self:GetCurrLevel())
end

function HeroHallStatueModel:GetNextLevelStatueIcon()
    return self:GetStatueIconByLevel(self:GetNextLevel())
end

function HeroHallStatueModel:GetStatueIconByLevel(level)
    return self.heroHallDataModel:GetStatueIconByLevel(level)
end

function HeroHallStatueModel:SetIsInEfx(flag)
    self.isInUpgradeEfx = flag
end

function HeroHallStatueModel:GetIsInEfx()
    return self.isInUpgradeEfx
end

return HeroHallStatueModel
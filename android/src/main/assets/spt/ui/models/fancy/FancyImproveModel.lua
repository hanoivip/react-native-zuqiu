local FancyCard = require("data.FancyCard")
local FancyGroup = require("data.FancyGroup")
local FancyStarUp = require("data.FancyStarUp")
local FancyUnlock = require("data.FancyUnlock")
local Card2FancyCard = require("data.Card2FancyCard")
local FancyStarRequire = require("data.FancyStarRequire")
local Model = require("ui.models.Model")
local FancyImproveModel = class(Model, "FancyImproveModel")
local floor = math.floor

function FancyImproveModel:ctor(fancyCardsMapModel)
    FancyImproveModel.super.ctor(self)
    local FancyCardsMapModel = require("ui.models.fancy.FancyCardsMapModel")
    self.fancyCardsMapModel = fancyCardsMapModel or FancyCardsMapModel.new()
    self.groupAttr = cache.GetFancyAttrs()
    self:InitFancyUnlock()
end

--self.groupAttr = {
--    [1] = { -- groupId
--        skill = 1, -- 技能等级加成
--        attr = {  -- 属性加成
--
--        },
--    },
--}
function FancyImproveModel:InitData()
    self:InitFancyUnlock()
    self.groupAttr = {}
    for i, v in pairs(FancyGroup) do
        self:RefreshGroupData(i)
    end
end

function FancyImproveModel:InitFancyUnlock()
    self.fancyUnlock = {}
    local maxParam = 0
    local unlockMap = {}
    for i, v in pairs(FancyUnlock) do
        if v.unlockParam > maxParam then
            maxParam = v.unlockParam
        end
        table.insert(unlockMap, {unlockParam = v.unlockParam, increase = v.totalAttributeNumIncrease})
    end
    table.sort(unlockMap, function(a, b) return a.unlockParam > b.unlockParam end)
    for i = 0, maxParam do
        local max = 0
        for index, unlockData in ipairs(unlockMap) do
            if unlockData.unlockParam <= i then
                max = unlockData.increase
                break
            end
        end
        self.fancyUnlock[i] = max
    end
end

function FancyImproveModel:GetRequireFancyStarsData(starRequireIDs)
    local fancyStars= {}
    for i, v in ipairs(starRequireIDs) do
        local rID = tostring(v)
        local rData = FancyStarRequire[rID]
        if not fancyStars[rData.starParam] then
            fancyStars[rData.starParam] = {}
        end
        table.insert(fancyStars[rData.starParam], {numParam = rData.numParam, rID = rID})
    end
    return fancyStars
end

function FancyImproveModel:RefreshGroupData(groupId)
    groupId = tostring(groupId)
    self.groupAttr = cache.GetFancyAttrs() or {}
    if not self.groupAttr[groupId] then
        self.groupAttr[groupId] = {}
        self.groupAttr[groupId].skill = 0
        self.groupAttr[groupId].attr = {}
    end
    local cardData, starUpData, star, lightCount, quality, skill
    local attr, attrRate, groupData, starMap, starRequireIDs
    groupData = FancyGroup[groupId]
    lightCount = 0
    skill = 0
    attr = 0
    attrRate = 0
    starMap = {}

    -- 升星带来的技能和全属性加成 FancyStarUp
    for index, fid in ipairs(groupData.fancyCard) do
        cardData = self.fancyCardsMapModel:GetFancyCardData(fid)
        if cardData then
            quality = tostring(FancyCard[fid].quality)
            star = cardData.star
            local starFix = star + 1
            lightCount = lightCount + 1
            starUpData = FancyStarUp[quality][starFix]
            attr = attr + starUpData.allAttributeNum
            skill = skill + starUpData.allSkills
            if not starMap[star] then
                starMap[star] = 0
            end
            starMap[star] = starMap[star] + 1
        end
    end

    -- 升星和解锁综合条件带来的技能和全属性百分比加成
    local allStarMap = {}
    for s, sn in pairs(starMap) do
        local all = 0
        for index, value in pairs(starMap) do
            if s <= index then
                all = all + value
            end
        end
        allStarMap[s] = all
    end

    starRequireIDs = groupData.starRequireID
    local fancyStars = self:GetRequireFancyStarsData(starRequireIDs)
    for rStarNum, rData in pairs(fancyStars) do
        for rDataIndex, rDataValue in ipairs(rData) do
            local isBreak = false
            for starNum, cardNum in pairs(allStarMap) do
                if starNum >= rStarNum and cardNum >= rDataValue.numParam then
                    local starRequireData = FancyStarRequire[rDataValue.rID]
                    skill = skill + starRequireData.allSkillsIncrease
                    attrRate = attrRate + starRequireData.allAttributePercentIncrease
                    isBreak = true
                    break
                end
            end
        end
    end

    -- 解锁单张带来的全属性加成 FancyUnlock
    attr = attr + (self.fancyUnlock[lightCount] or 0)

    self.groupAttr[groupId].skill = skill
    self.groupAttr[groupId].attr = attr or 0
    self.groupAttr[groupId].attrRate = attrRate or 0
    self.groupAttr[groupId].attrTotal = attr * (1 + attrRate/10000)
    self.groupAttr[groupId].lightCount = lightCount
    cache.SetFancyAttrs(self.groupAttr)
end

function FancyImproveModel:GetPlayerCardAttrs(cid)
    local c2fcData = Card2FancyCard[cid]
    local totalAttrs = {}
    totalAttrs.skill = 0
    totalAttrs.attr = 0
    totalAttrs.attrTotal = 0
    totalAttrs.lightCount = 0
    if not c2fcData then return totalAttrs end
    for i, v in pairs(c2fcData) do
        local groupId = tostring(v)
        for key, value in pairs(self.groupAttr[groupId]) do
            if totalAttrs[key] then
                totalAttrs[key] = totalAttrs[key] + value
            end
        end
    end
    totalAttrs.attrTotal = floor(totalAttrs.attrTotal)
    return totalAttrs
end

function FancyImproveModel:GetGroupsAttr()
    return self.groupAttr
end

return FancyImproveModel

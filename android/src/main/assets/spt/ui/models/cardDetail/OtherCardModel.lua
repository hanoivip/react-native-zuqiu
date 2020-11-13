local Card = require("data.Card")
local CoachGuidePrice = require("data.CoachGuidePrice")
local CardOwnershipType = require("ui.controllers.cardDetail.CardOwnershipType")
local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")
local OtherCardModel = class(PlayerCardModel, "OtherCardModel")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local OtherPlayerCardsMapModel = require("ui.models.OtherPlayerCardsMapModel")
local OtherPlayerTeamsModel = require("ui.models.OtherPlayerTeamsModel")
local OtherLegendCardsMapModel = require("ui.models.legendRoad.OtherLegendCardsMapModel")
local MemoryItemModel = require("ui.models.cardDetail.memory.MemoryItemModel")
local OtherSceneModel = require("ui.models.myscene.OtherSceneModel")
local CardMemoryImproveModel = require("ui.models.cardDetail.memory.CardMemoryImproveModel")

function OtherCardModel:ctor(pcid, otherPlayerCardsMapModel, otherTeamsModel, otherLegendCardsMapModel, otherCourtModel)
    local playerCardsMapModel = otherPlayerCardsMapModel or OtherPlayerCardsMapModel.new()
    local playerTeamsModel = otherTeamsModel or OtherPlayerTeamsModel.new(self.otherPlayerCardsMapModel)
    local legendCardsMapModel = otherLegendCardsMapModel or OtherLegendCardsMapModel.new()
    local courtModel = otherCourtModel or OtherSceneModel.new()
    OtherCardModel.super.ctor(self, pcid, playerTeamsModel, playerCardsMapModel, true, true, legendCardsMapModel, courtModel)
    self.ownershipType = CardOwnershipType.OTHER
    self.allCids = {}
    self.cardMemoryImproveModel = CardMemoryImproveModel.new(self.otherPlayerCardsMapModel)
end

function OtherCardModel:GetTeamModel()
    return self.teamsModel
end

function OtherCardModel:SetAllCardsCids(cids)
    self.allCids = cids or {}
    self.cardsMap = {}
    for cid, plus in pairs(self.allCids) do
        local cardData = {}
        cardData.cid = cid
        table.insert(self.cardsMap, cardData)
    end
end

function OtherCardModel:IsOperable()
    return false
end

function OtherCardModel:IsAllowChangeScene()
    return false
end

function OtherCardModel:HasPasterAvailable()
    return false
end

function OtherCardModel:HasPaster()
    local hasPaster = self.cacheData.paster and next(self.cacheData.paster)
    return hasPaster
end

function OtherCardModel:IsExistChemicalCardID(cid)
    return self.allCids[cid]
end

-- 化学反应中球员额外加成,服务器发送
function OtherCardModel:GetChemicalPlayersAddValue(cid)
    local maxPlus = self.allCids[cid] or 0
    return maxPlus
end

-- 缘分类技能是否生效
-- @param cardID2 配缘人的cid
function OtherCardModel:IsChemicalSkillValid(cardID1, cardID2, tid)
    assert(tostring(cardID1) == tostring(self:GetCid()))
    
    if self:IsPlayerInTeam() then 
        if self:IsChemicalPlayerInTeam(cardID2) then
            return true
        end
    end
    return false
end

function OtherCardModel:IsPlayerInStarter()
    if self.teamsModel:IsPlayerInInitTeam(self:GetPcid()) then
        return true
    end
    return false
end

-- 判断自己是否在这个阵容里面(根据pcid判断)
function OtherCardModel:IsPlayerInTeam()
    if self.teamsModel:IsPlayerInInitTeam(self:GetPcid()) or self.teamsModel:IsPlayerInReplaceTeam(self:GetPcid()) then
        return true
    end
    return false
end

-- 再判断配缘人是否存在这个阵容里面(根据cid判断)
function OtherCardModel:IsChemicalPlayerInTeam(cardID)
    if self.teamsModel:IsExistCardIDInInitTeam(cardID) or self.teamsModel:IsExistCardIDInReplaceTeam(cardID) then
        return true
    end
    return false
end

-- 获取球员特训技能数据
function OtherCardModel:GetCoachFeature()
    return self.cacheData.coachGuide or {}
end

-- 球员是否在特训栏
function OtherCardModel:HasCoachFeature()
    local coachGuideOpen = tonumber(self.cacheData.coachGuideOpen) or 1
    return coachGuideOpen > 0
end

-- 球员在特训栏的第几个栏位对应 CoachGuidePrice
function OtherCardModel:GetCoachGuideSlotId()
    local coachGuideOpen = tonumber(self.cacheData.coachGuideOpen) or 1
    if coachGuideOpen > 0 then
        return coachGuideOpen
    end
end

-- 球员在特训栏对应栏位下最多有几个技能 对应CoachGuidePrice.effectAmount
function OtherCardModel:GetCoachGuideEffectAmount()
    local coachGuideOpen = tonumber(self.cacheData.coachGuideOpen) or 0
    if coachGuideOpen > 0 then
        local effectAmount = CoachGuidePrice[tostring(coachGuideOpen)].effectAmount or 0
        return effectAmount
    end
    return 0
end

-- 球员装备
function OtherCardModel:GetEquips()
    return self.cacheData.equips
end

-- 球员技能
function OtherCardModel:GetSkills()
    return self.cacheData.skills
end

function OtherCardModel:GetActivatedSkillAmount()
    local ret = 0
    local skillsData = self:GetSkills()
    for i, skill in ipairs(skillsData) do
        if skill.isOpen then
            ret = ret + 1
        end
    end
    return ret
end

-- 基础属性
function OtherCardModel:GetBaseAbility(index)
    local staticNum = self.staticData[index]
    return staticNum
end

-- 方便对照属性变化（在计算中属性后可以获取单项属性值）
function OtherCardModel:GetCheckAbility()
    return self.abilityCheckMap
end

-- 球员额外装备加成（不算进阶过的装备）
function OtherCardModel:GetEquipPowerAttr()
    return self.cacheData.eqsAttr or {}
end

function OtherCardModel:GetEquipPowerByAbility(ability)
    local eqsAttr = self:GetEquipPowerAttr()
    return eqsAttr[ability] or 0
end

-- 球员进阶加成
function OtherCardModel:GetUpgradePowerAttr()
    return self.cacheData.upAttr or {}
end

function OtherCardModel:GetUpgradePowerByAbility(ability)
    local upAttr = self:GetUpgradePowerAttr()
    return upAttr[ability] or 0
end

-- 球员特训加成
function OtherCardModel:GetTrainingPowerAttr()
    return self.cacheData.trainingAttr or {}
end

function OtherCardModel:GetTrainingPowerByAbility(ability)
    local trainingAttr = self:GetTrainingPowerAttr()
    return trainingAttr[ability] or 0
end

-- 英雄殿堂加成
function OtherCardModel:GetHerohallPowerAttr()
    return self.cacheData.footballHallAttr or {}
end

function OtherCardModel:GetHerohallPowerByAbility(ability)
    local footballHallAttr = self:GetHerohallPowerAttr()
    return footballHallAttr[ability] or 0
end

function OtherCardModel:SetCoachMainModel(coachMainModel)
    self.coachMainModel = coachMainModel
end

-- 教练百分比属性加成
function OtherCardModel:GetCoachPowerRate()
    local coachRate = {}
    if self.cacheData.power then
        local mCoachAttr = self.cacheData.power.coachAttr or {}
        for k,v in pairs(mCoachAttr) do
            coachRate[k] = v[2] or 0
        end
    end
    return coachRate
end

-- 教练固定属性加成
function OtherCardModel:GetCoachPowerAttr()
    local coachAttr = {}
    if self.cacheData.power then
        local mCoachAttr = self.cacheData.power.coachAttr or {}
        for k,v in pairs(mCoachAttr) do
            coachAttr[k] = v[1] or 0
        end
        -- 助理教练属性
        local assistCoachAttr = self.cacheData.power.assistantCoachAttr or {}
        for attrName, attrVar in pairs(assistCoachAttr) do
            coachAttr[attrName] = (coachAttr[attrName] or 0) + attrVar
        end
    end
    return coachAttr
end

-- 教练百分比属性加成
function OtherCardModel:GetCoachPowerByAbility(ability)
    local trainingAttr = self:GetCoachPowerAttr()
    return trainingAttr[ability] or 0
end

-- 传奇记忆全属性加成
function OtherCardModel:GetMemoryPowerAttr()
    local memoryAttr = {}
    if self.cacheData.power then
        memoryAttr = self.cacheData.power.memoryAttr or {}
    end
    -- 功能为全属性加成，保留一个值即可，获得服务器计算值的最大值
    local max = 0
    for attrName, v in pairs(memoryAttr) do
        if tonumber(v) > max then
            max = v
        end
    end
    return max
end

-- 球员的缘分类技能是否激活
function OtherCardModel:IsChemicalSkillActivate(skillItemModel)
    assert(skillItemModel:IsChemicalSkill() == true)

    -- 判断球员列表里是否存在这两位球员
    local card1, card2 = skillItemModel:GetChemicalSkillCoupleID()

    return self:IsChemicalSkillValid(card1, card2, self.formationType)
end

function OtherCardModel:GetCoachMainModel()
    return self.coachMainModel
end

-- 传奇记忆功能是否开启
function OtherCardModel:IsMemoryOpen()
    return not table.isEmpty(self:GetMemoryData()) and self:CanMemory() and self:GetUpgrade() >= self:GetMaxUpgradeNum() -- 进阶满级开启传奇记忆功能且有相关低品质卡牌
end

function OtherCardModel:GetMemoryItemModels(needRefresh)
    if table.isEmpty(self.memoryModels) or (needRefresh or false) then
        self.memoryModels = {}
        local memory = self:GetMemoryData()
        local baseId = self:GetBaseID()
        local currQualityNum = self:GetCardFixQualityNum()
        for qualitySuffix, v in pairs(CardHelper.ConfigQuality) do
            local cid = baseId .. tostring(qualitySuffix)
            local cardConfig = Card[cid]
            if cardConfig and tonumber(cardConfig.valid) == 1 then -- 有相关卡牌且投放
                local qualityNum = CardHelper.GetCardFixQualityNum(cardConfig.quality, cardConfig.qualitySpecial)
                local qualityFixed = CardHelper.GetQualityFixed(cardConfig.quality, cardConfig.qualitySpecial)
                local qualityKey = CardHelper.GetQualityConfigFixed(cardConfig.quality, cardConfig.qualitySpecial)
                local cardData = memory[qualityKey] -- 当前槽位添加的卡牌
                -- 品质较低且考虑华为特殊卡品质
                if cardData and qualityNum < currQualityNum and (qualityFixed ~= CardHelper.HWSpecialFixedCardQuality or cache.getIsContainHWCard()) then
                    local filledCard = require("ui.models.cardDetail.UnsavedCardModel").new(cardData)
                    local memoryItemModel = MemoryItemModel.new(self, cardConfig.quality, cardConfig.qualitySpecial, filledCard, true)
                    table.insert(self.memoryModels, memoryItemModel)
                end
            end
        end
        table.sort(self.memoryModels, function(a, b)
            return tonumber(a:GetQualityFixedNum()) > tonumber(b:GetQualityFixedNum())
        end)
    end
    return self.memoryModels
end

function OtherCardModel:IsReachWearEquipCondition(slot)
    return false
end

--  梦幻11人属性
function OtherCardModel:GetFancyAbility()
    if self.cacheData.power and self.cacheData.power.fancyCardAttr then
        return self.cacheData.power.fancyCardAttr
    end
    return 0
end

-- 梦幻11人的全技能包括贴纸
function OtherCardModel:GetFancySkillLvl()
    if self.cacheData.power and self.cacheData.power.fancyCardLvl then
        return self.cacheData.power.fancyCardLvl
    end
    return 0
end

--  球员助力贴纸
function OtherCardModel:GetSupportAbility(index)
    if self.cacheData.power and self.cacheData.power.supporterCardAttr then
        return self.cacheData.power.supporterCardAttr[index] or 0
    end
    return 0
end

-- 球员助力贴纸全技能
function OtherCardModel:GetSupportSkillLvl()
    if self.cacheData.power and self.cacheData.power.supporterCardLvl then
        return self.cacheData.power.supporterCardLvl
    end
    return 0
end

-- 球员助力 屏蔽父类的初始化方法
function OtherCardModel:InitSupportPasterData()
end

return OtherCardModel

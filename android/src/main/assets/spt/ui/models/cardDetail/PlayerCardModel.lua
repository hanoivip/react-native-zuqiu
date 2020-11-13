local EventSystem = require ("EventSystem")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local EquipPieceMapModel = require("ui.models.EquipPieceMapModel")
local EquipsMapModel = require("ui.models.EquipsMapModel")
local CardAppendPasterModel = require("ui.models.cardDetail.CardAppendPasterModel")
local HeroHallMapModel = require("ui.models.heroHall.main.HeroHallMapModel")
local SkillConstants = require("ui.common.SkillConstants")
local CoachMainModel = require("ui.models.coach.CoachMainModel")
local CardMemoryImproveModel = require("ui.models.cardDetail.memory.CardMemoryImproveModel")
local LegendCardsMapModel = require("ui.models.legendRoad.LegendCardsMapModel")
local CardFeatureCurrentAdditionModel = require("ui.models.cardDetail.feature.CardFeatureCurrentAdditionModel")
local HomeCourtModel = require("ui.models.myscene.MySceneModel")
local FancyCardsMapModel = require("ui.models.fancy.FancyCardsMapModel")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
-- static data
local Equipment = require("data.Equipment")
local Card = require("data.Card")
local Skills = require("data.Skills")
local CardLevel = require("data.CardLevel")
local CoachGuidePrice = require("data.CoachGuidePrice")
local FormationType = require("ui.common.enum.FormationType")
local BaseCardModel = require("ui.models.cardDetail.BaseCardModel")
local CardOwnershipType = require("ui.controllers.cardDetail.CardOwnershipType")
local PasterMainType = require("ui.scene.paster.PasterMainType")
local CardSupporter = require("data.CardSupporter")

local PlayerCardModel = class(BaseCardModel, "PlayerCardModel")
local tostring = tostring

function PlayerCardModel:ctor(pcid, playerTeamsModel, playerCardsMapModel, equipPieceMapModel, equipsMapModel, legendCardsMapModel, homeCourtModel, fancyCardsMapModel)
    assert(pcid, "pcid does not exist!")
    PlayerCardModel.super.ctor(self)
    self.playerCardsMapModel = playerCardsMapModel or PlayerCardsMapModel.new()
    self.equipPieceMapModel = equipPieceMapModel or EquipPieceMapModel.new()
    self.equipsMapModel = equipsMapModel or EquipsMapModel.new()
    self.heroHallMapModel = HeroHallMapModel.new()
    self.teamsModel = playerTeamsModel or require("ui.models.PlayerTeamsModel").new()
    self.coachMainModel = CoachMainModel.new(self, self.teamsModel)
    self.cardMemoryImproveModel = CardMemoryImproveModel.new()
    self.legendCardsMapModel = legendCardsMapModel or LegendCardsMapModel.new()
    self.homeCourtModel = homeCourtModel or HomeCourtModel.new()
    self.cardFeatureCurrentAdditionModel = CardFeatureCurrentAdditionModel.new()
    self.fancyCardsMapModel = fancyCardsMapModel or FancyCardsMapModel.new()

    self.ownershipType = CardOwnershipType.SELF

    self.abilityCheckMap = {} -- 可以用于查看属性数据(记录的数据可以直接获取减少计算)
    self.legendSkillImprove = {}
    self.legendCardImprove = {}
    self.homeCourtImprove = {}
    self:InitCardsMap(self.playerCardsMapModel)
    self:InitWithCache(self.playerCardsMapModel:GetCardData(pcid))
end

function PlayerCardModel:InitCardsMap(playerCardsMapModel)
    self.cardsMap = playerCardsMapModel.data
end

function PlayerCardModel:InitWithCache(cache)
    assert(Card[tostring(cache.cid)], tostring(cache.cid) .. " does not exist!")
    self.cacheData = cache
    self.staticData = Card[tostring(self.cacheData.cid)]
    self.abilityCheckMap = {}
    self:InitMemoryData()
    self:InitLegendRoadImprove()
    self:InitHomeCourtImprove()
    self:InitFancyImprove()
    self:InitSupportPasterData()
end

-- 传奇之路技能对当前球员加成
function PlayerCardModel:InitLegendRoadImprove()
    self:InitLegendSkillImprove()
    self:InitLegendCardImprove()
end

-- 传奇之路技能对当前球员加成
function PlayerCardModel:InitLegendSkillImprove()
    self.legendSkillImprove = self:GetLegendSkillImprove()
end

-- 传奇之路章节对当前球员加成
function PlayerCardModel:InitLegendCardImprove()
    self.legendCardImprove = self:GetLegendCardImprove()
end

-- 主场天气和草皮对球员特性影响
function PlayerCardModel:InitHomeCourtImprove()
    self.homeCourtImprove = self:GetHomeCourtImprove()
end

function PlayerCardModel:IsOperable()
    return true
end

function PlayerCardModel:IsAllowChangeScene()
    return true
end

function PlayerCardModel:GetCardsMapModel()
    return self.playerCardsMapModel
end

-- 球员装备
function PlayerCardModel:GetEquips()
    return self.cacheData.equips
end

-- 球员技能
function PlayerCardModel:GetSkills()
    return self.cacheData.skills
end

-- 球员勋章
function PlayerCardModel:GetMedals()
    return self.cacheData.medals or {}
end

-- 球员是否受传奇之路ex月贴效果影响
function PlayerCardModel:HasLegendRoadExEffect()
    local legend = self.cacheData.legend or {}
    return tonumber(legend.expaster) > 0
end

-- 是否有球员勋章
function PlayerCardModel:HasMedal()
    local hasMedal = self.cacheData.medals and next(self.cacheData.medals)
    return hasMedal
end

-- 球员贴纸
function PlayerCardModel:HasPaster()
    local hasPaster = self.cacheData.paster and next(self.cacheData.paster)
    return hasPaster
end

function PlayerCardModel:HasPasterAvailableWithoutSame()
    local existPasterIds = self:GetPasterData()
    return self:HasPasterAvailable(existPasterIds)
end

function PlayerCardModel:GetPasterAppointModel(ptid)
    local pasterData = self:GetPasterData()
    local skills = self:GetSkills()
    local model
    for i, v in ipairs(pasterData) do
        if tostring(ptid) == tostring(v.ptid) then 
            local pasterSkillData
            model = CardAppendPasterModel.new(ptid)
            for slot, skillData in ipairs(skills) do
                if tostring(skillData.ptid) == tostring(ptid) then 
                    pasterSkillData = skillData
                    break
                end
            end
            model:InitWithCache(v, pasterSkillData)
            break
        end
    end
    return model
end

function PlayerCardModel:HasSamePaster(ptcid)
    local pasterData = self:GetPasterData()
    local hasSamePaster = false
    for i, v in ipairs(pasterData) do
        if tonumber(v.ptcid) == tonumber(ptcid) then
            hasSamePaster = true
            break
        end
    end
    return hasSamePaster
end

function PlayerCardModel:GetUsePasterId()
    local skills = self:GetSkills()
    local ptid
    -- 此循环查找球员身上月贴纸中生效的技能
    for i, v in ipairs(skills) do
        if v.ptid and v.pType == PasterMainType.Month and v.skillValid == 1 then
            ptid = v.ptid
            break
        end
    end
    return tostring(ptid)
end

function PlayerCardModel:HasMonthPaster()
    local skills = self:GetSkills()
    for i, v in ipairs(skills) do
        if v.ptid and v.pType == PasterMainType.Month then
            return true
        end
    end
    return false
end

-- 传奇之路潜力
function PlayerCardModel:GetLegendPotent()
    return self:GetLegendPotentImprove()
end

local Eps = 1e-6
-- 使用六个维度的属性相加
function PlayerCardModel:GetPower(medalCombine)
    local ret = 0
    local medalCombine = medalCombine or self:GetMedalCombine()
    local base, plus, train, totalAttr = self:GetAllAbility(medalCombine)
    ret = totalAttr
    -- 5维球员属性（非阵容）之和*技能百分比加成（EventSkill）
    return self:GetPowerByAttribute(ret, medalCombine)
end

function PlayerCardModel:GetPowerByAttribute(ret, medalCombine)
    self.abilityCheckMap.withoutMedalPercent = 0
    self.abilityCheckMap.skillPercent = 0
    local percent = 0
    for i, skill in ipairs(self.cacheData.skills) do
        local isSkillAtrAdd, skillTable = self:IsComputeSkillPercentAux(skill) -- defined in BaseCardModel
        if isSkillAtrAdd then
            local medalLvl = tonumber(skill.mlvl)
            local coachSkillLvl = self.coachMainModel:GetCoachSkillLvl(skill) -- 教练带来的技能等级提升
            local legendSkillLvl = self:GetLegendSkillLvl(i)
            local homeCourtSkillLvl = self:GetHomeCourtSkillLvl(i, skill.sid)
            local fancySkillLvl = self:GetFancySkillLvl(i)
            local supportSkillLvl = self:GetSupportSkillLvl(i)
            local skillLvl = medalLvl + tonumber(skill.lvl) + tonumber(skill.plvl) + tonumber(skill.tlvl)
                    + tonumber(skill.hlvl) + tonumber(coachSkillLvl) + tonumber(legendSkillLvl)
                    + tonumber(homeCourtSkillLvl) + tonumber(fancySkillLvl) + tonumber(supportSkillLvl)
            local fixSkillLevel = math.clamp(skillLvl, 1, SkillConstants.MaxLevel)
            local powerStr = "power" .. tostring(fixSkillLevel)
            local powerPercent = 0
            local baseSkillValue = skillTable["powerBase"]
            local skillValue = skillTable[powerStr]
            if baseSkillValue then --技能表优化
                local addPercent = tonumber(skillTable["powerImprove"]) * (fixSkillLevel - 1)
                powerPercent = tonumber(baseSkillValue) + tonumber(addPercent)
            elseif skillValue then 
                powerPercent = skillValue
            end
            percent = percent + powerPercent

            local withoutMedalLvl = fixSkillLevel - medalLvl
            local m_powerPercent = 0
            local m_powerStr = "power" .. tostring(withoutMedalLvl)
            local m_skillValue = skillTable[m_powerStr]
            if baseSkillValue then --技能表优化
                local addPercent = tonumber(skillTable["powerImprove"]) * (withoutMedalLvl - 1)
                m_powerPercent = tonumber(baseSkillValue) + tonumber(addPercent)
            elseif m_skillValue then 
                m_powerPercent = m_skillValue
            end
            self.abilityCheckMap.withoutMedalPercent = self.abilityCheckMap.withoutMedalPercent + m_powerPercent
        end
    end

    self.abilityCheckMap.skillPercent = percent
    self.abilityCheckMap.blessPercent = 0
    self.abilityCheckMap.totalPercent = 0

    for sid, data in pairs(medalCombine.bless) do
        local skillTable = Skills[tostring(sid)]
        if skillTable then
            local lvl = tonumber(data.lvl)
            local powerStr = "power" .. tostring(lvl)
            local blessPercent = skillTable[powerStr]
            local powerPercent = 0
            local baseSkillValue = skillTable["powerBase"]
            if baseSkillValue then --技能表优化
                local addPercent = tonumber(skillTable["powerImprove"]) * (lvl - 1)
                powerPercent = tonumber(baseSkillValue) + tonumber(addPercent)
            elseif blessPercent then
                powerPercent = blessPercent
            end

            percent = percent + powerPercent
            self.abilityCheckMap.blessPercent = self.abilityCheckMap.blessPercent + powerPercent
        end
    end
    local legendSkillPercent = self:GetLegendSkillPercent()
    self.abilityCheckMap.legendSkillPercent = legendSkillPercent
    percent = percent + legendSkillPercent

    percent = 1 + percent / 10000
    ret = math.floor(ret * percent + Eps)
    self.abilityCheckMap.totalPercent = percent
    --dump(self.abilityCheckMap, self:GetCid())
    return ret
end

-- 身价
function PlayerCardModel:GetValue()
    --[[
    球员身价=初始身价+养成提升的身价
    养成身价=进阶价格（每件装备有价格）+技能价格（每个技能每个等级有价格）
    +培养价格（每转化1点潜力，球员身价+1万）+转生价格（继承被转生球员的全部身价）
    --]]
    -- 初始身价
    local price = self.staticData.price
    -- 进阶价格
    local equips = self.cacheData.equips
    for i, equip in ipairs(equips) do
        price = price + tonumber(equip.priceUp)
    end
    -- 技能价格
    for i, skill in ipairs(self.cacheData.skills) do
        if skill.isOpen == true and skill.lvl >= 1 then
            local isSkillPriceAdd = (skill.ptid == nil) or (skill.skillValid == 1 and skill.skillConflict ~= 1)
            if isSkillPriceAdd then -- 荣耀贴纸没有sid
                local skillTable = Skills[tostring(skill.sid)] or {}
                local coachSkillLvl = self.coachMainModel:GetCoachSkillLvl(skill) -- 教练带来的技能等级提升
                local skillLvl = tonumber(skill.lvl) + tonumber(skill.plvl) + tonumber(skill.mlvl) + tonumber(skill.tlvl) + tonumber(skill.hlvl) + tonumber(coachSkillLvl)
                local fixSkillLevel = math.clamp(skillLvl, 1, SkillConstants.MaxLevel)
                local basePriceValue = skillTable["priceBase"] 
                local priceValue = skillTable["priceUp" .. tostring(fixSkillLevel)]

                if basePriceValue then --技能表优化
                    local addValue = tonumber(skillTable["priceImprove"]) * (fixSkillLevel - 1)
                    price = price + basePriceValue + addValue
                elseif priceValue then 
                    price = price + priceValue
                end
            end
        end
    end
    -- 培养价格
    price = price + self:GetConsumePotent() * 1
    -- 转生价格
    price = price + tonumber(self.cacheData.ascendPriceUp)

    return price
end

function PlayerCardModel:GetTeamModel()
    return self.teamsModel
end

function PlayerCardModel:SetTeamModel(teamsModel)
    if teamsModel then 
        self.teamsModel = teamsModel
        self.coachMainModel:SetTeamModel(teamsModel)
    end
end

-- 缘分类技能是否生效
-- @param cardID2 配缘人的cid
function PlayerCardModel:IsChemicalSkillValid(cardID1, cardID2, tid)
    assert(tostring(cardID1) == tostring(self:GetCid()))
    
    if self:IsPlayerInTeam(tid) then 
        if self:IsChemicalPlayerInTeam(cardID2, tid) then
            return true
        end
    end
    return false
end

-- 判断自己是否在这个阵容里面(根据pcid判断)
function PlayerCardModel:IsPlayerInTeam(tid)
    local tid = tid or self.teamsModel:GetNowTeamId()
    if self.teamsModel:IsPlayerInInitTeam(self:GetPcid(), tid) or self.teamsModel:IsPlayerInReplaceTeam(self:GetPcid(), tid) then
        return true
    end
    return false
end

-- 再判断配缘人是否存在这个阵容里面(根据cid判断)
function PlayerCardModel:IsChemicalPlayerInTeam(cardID, tid)
    local tid = tid or self.teamsModel:GetNowTeamId()
    if self.teamsModel:IsExistCardIDInInitTeam(cardID, tid) or self.teamsModel:IsExistCardIDInReplaceTeam(cardID, tid) then
        return true
    end
    return false
end

function PlayerCardModel:IsPlayerInStarter(tid)
    local tid = tid or self.teamsModel:GetNowTeamId()
    if self.teamsModel:IsPlayerInInitTeam(self:GetPcid(), tid) then
        return true
    end
    return false
end

-- 化学反应中球员额外加成
-- 额外数值加成(取养成度最高的计算)
-- 每进阶一次，全属性额外+3
-- 每转生一次，全属性额外+6
function PlayerCardModel:GetChemicalPlayersAddValue(cid)
    local sameCardList = self.playerCardsMapModel:GetSameCardList(cid)
    local maxPlus = 0
    local maxPcid = next(sameCardList)
    for pcid, v in pairs(sameCardList) do
        local tmpCardData = self.playerCardsMapModel:GetCardData(pcid)
        local thisCardPlus = tmpCardData.upgrade * 3 + tmpCardData.ascend * 6
        if thisCardPlus > maxPlus then
            maxPlus = thisCardPlus
            maxPcid = pcid
        end
    end
    return maxPlus, maxPcid
end

function PlayerCardModel:GetChemicalPlayersPcids(cid)
    local sameCardList = self.playerCardsMapModel:GetSameCardList(cid)
    return sameCardList
end

-- 方便对照属性变化（在计算中属性后可以获取单项属性值）
function PlayerCardModel:GetCheckAbility()
    return self.abilityCheckMap
end

-- 球员额外装备加成（不算进阶过的装备）
function PlayerCardModel:GetEquipPowerAttr()
    return self.cacheData.eqsAttr or {}
end

function PlayerCardModel:GetEquipPowerByAbility(ability)
    local eqsAttr = self:GetEquipPowerAttr()
    return eqsAttr[ability] or 0
end

-- 球员进阶加成
function PlayerCardModel:GetUpgradePowerAttr()
    return self.cacheData.upAttr or {}
end

function PlayerCardModel:GetUpgradePowerByAbility(ability)
    local upAttr = self:GetUpgradePowerAttr()
    return upAttr[ability] or 0
end

-- 球员特训加成
function PlayerCardModel:GetTrainingPowerAttr()
    return self.cacheData.trainingAttr or {}
end

function PlayerCardModel:GetTrainingPowerByAbility(ability)
    local trainingAttr = self:GetTrainingPowerAttr()
    return trainingAttr[ability] or 0
end

-- 英雄殿堂加成
function PlayerCardModel:GetHerohallPowerAttr()
    local cid = self:GetCid()
    local footballHallAttr = self.heroHallMapModel:GetHallAttrByCid(cid) or {}
    return footballHallAttr
end

function PlayerCardModel:GetHerohallPowerByAbility(ability)
    local footballHallAttr = self:GetHerohallPowerAttr()
    return footballHallAttr[ability] or 0
end

-- 教练百分比属性加成
function PlayerCardModel:GetCoachPowerRate()
    local coachRate = {}
    if self.teamsModel then
        coachRate = self.coachMainModel:GetTallenRate()
    end
    return coachRate
end

-- 教练固定属性加成
function PlayerCardModel:GetCoachPowerAttr()
    local coachAttr = {}
    local pcid = self:GetPcid()
    local tid = self.teamsModel:GetNowTeamId()
    if self.teamsModel and self.teamsModel:IsPlayerInInitTeam(pcid, tid) then
        coachAttr = self.coachMainModel:GetCoachAttr(self)
    end
    return coachAttr
end

-- 教练百分比属性加成
function PlayerCardModel:GetCoachPowerByAbility(ability)
    local trainingAttr = self:GetCoachPowerAttr()
    return trainingAttr[ability] or 0
end

-- 传奇记忆全属性加成
function PlayerCardModel:GetMemoryPowerAttr()
    local memory = self:GetMemoryData()
    local memoryAttr = 0
    for qualityKey, pcid in pairs(memory or {}) do
        local attrAdded = self.cardMemoryImproveModel:GetAttrImproveByPcid(pcid)
        memoryAttr = memoryAttr + attrAdded
    end
    return memoryAttr
end

-- 属性名字
function PlayerCardModel:GetAttrNameList()
    if self:IsGKPlayer() then
        return BaseCardModel.GoalKeeperAttribute
    else
        return BaseCardModel.NormalPlayerAttribute
    end
end

-- 优化大卡战力去掉多余计算
function PlayerCardModel:GetAllAbility(medalCombine)
    local baseNum = 0
    local plusNum = 0
    local trainNum = 0
    local attrList
    if self:IsGKPlayer() then
        attrList = BaseCardModel.GoalKeeperAttribute
    else
        attrList = BaseCardModel.NormalPlayerAttribute
    end

    local footballHallAttr = self:GetHerohallPowerAttr()
    -- 教练固定属性加成
    local coachAttr = self:GetCoachPowerAttr()

    -- 传奇记忆加成，全属性，单值
    local memoryNum = self:GetMemoryPowerAttr()

    -- 球员属性=基础属性 +升级属性 +装备属性 +培养属性（潜力属性+转生属性）+技能属性 +化学属性 +勋章属性 +特训属性 +英雄殿堂 +教练属性 +传奇记忆属性
    for i, attrName in ipairs(attrList) do
        self.abilityCheckMap[attrName] = {}
        if self.staticData[attrName] then
            local currentAttrBase = 0
            -- 基础属性
            local staticNum = self:GetBaseAbility(attrName)
            self.abilityCheckMap[attrName].staticNum = staticNum

            -- 升级属性
            local levelNum = self:GetLevelAbility(attrName)
            self.abilityCheckMap[attrName].levelNum = levelNum

            -- 培养属性
            local potentNum = self:GetAdvancePotential(attrName)
            self.abilityCheckMap[attrName].potentNum = potentNum

            -- 进阶属性
            local upgradeNum = self:GetUpgradePowerByAbility(attrName)
            self.abilityCheckMap[attrName].upgradeNum = upgradeNum

            -- 额外装备属性
            local equipNum = self:GetEquipPowerByAbility(attrName)
            self.abilityCheckMap[attrName].equipNum = equipNum

            -- 勋章属性
            local medalNum = medalCombine.baseAttribute[attrName] or 0
            self.abilityCheckMap[attrName].medalNum = medalNum

            -- 特训属性
            local trainingNum = self:GetTrainingPowerByAbility(attrName)
            self.abilityCheckMap[attrName].trainingNum = trainingNum

            -- 英雄殿堂
            local heroHallNum = footballHallAttr[attrName] or 0
            self.abilityCheckMap[attrName].heroHallNum = heroHallNum

            -- 教练
            local coachNum = coachAttr[attrName] or 0
            self.abilityCheckMap[attrName].coachNum = coachNum

            -- 传奇记忆
            self.abilityCheckMap[attrName].memoryNum = memoryNum

            -- 传奇之路
            local legendAttrNum = self:GetLegendAbility(attrName)
            self.abilityCheckMap[attrName].legendAttrNum = legendAttrNum

            -- 主场
            local homeCourtAttrNum = self:GetHomeCourtAbility(attrName)
            self.abilityCheckMap[attrName].homeCourtAttrNum = homeCourtAttrNum

            -- 梦幻11人
            local fancyAttrNum = self:GetFancyAbility(attrName)
            self.abilityCheckMap[attrName].fancyAttrNum = fancyAttrNum

            -- 球员助力贴纸
            local supportAttrNum = self:GetSupportAbility(attrName)
            self.abilityCheckMap[attrName].supportAttrNum = supportAttrNum

            self.abilityCheckMap[attrName].skillNum = 0
            self.abilityCheckMap[attrName].chemicalNum = 0
        end
    end

    -- 技能的属性加成
    for i, skill in ipairs(self.cacheData.skills) do
        local isComputeSkill, skillTable = self:IsComputeSkillAttrAux(skill) -- defined in BaseCardModel
        if isComputeSkill then
            local coachSkillLvl = self.coachMainModel:GetCoachSkillLvl(skill) -- 教练带来的技能等级提升
            local legendSkillLvl = self:GetLegendSkillLvl(i)
            local homeCourtSkillLvl = self:GetHomeCourtSkillLvl(i, skill.sid)
            local fancySkillLvl = self:GetFancySkillLvl(i)
            local supportSkillLvl = self:GetSupportSkillLvl(i)
            local skillLvl = tonumber(skill.lvl) + tonumber(skill.plvl) + tonumber(skill.mlvl) + tonumber(skill.tlvl)
                    + tonumber(skill.hlvl) + tonumber(coachSkillLvl) + tonumber(legendSkillLvl)
                    + tonumber(homeCourtSkillLvl) + tonumber(fancySkillLvl) + tonumber(supportSkillLvl)
            local fixSkillLevel = math.clamp(skillLvl, 1, SkillConstants.MaxLevel)
            local plusTable = skillTable["lvl" .. tostring(fixSkillLevel)] or {}
            local baseLevelTable = skillTable["lvlBase"] or {} --技能表优化
            for index, attrName in ipairs(attrList) do
                local plus = 0
                if baseLevelTable[attrName] then
                    plus = baseLevelTable[attrName] + skillTable["lvlImprove"][attrName] * (fixSkillLevel - 1)
                elseif plusTable[attrName] then
                    plus = plusTable[attrName]
                end
                self.abilityCheckMap[attrName].skillNum = self.abilityCheckMap[attrName].skillNum + plus
            end
        end
    end

    -- 化学反应的属性加成
    local chemicalBonus, maxPlus = 0, 0
    local chemicalData = self:GetChemicalData()
    local currentCid = self:GetCid()
    for i, v in ipairs(chemicalData) do
        local isChemicalActive = true
        for j, cid in ipairs(v.cids) do
            if cid and cid ~= "" and cid ~= currentCid and not self:IsExistChemicalCardID(cid) then
                isChemicalActive = false
                break
            end
        end

        if isChemicalActive then
            -- 基础数值加成
            chemicalBonus = chemicalBonus + tonumber(v.chemicalBonus)
            for j, cid in ipairs(v.cids) do
                if cid ~= currentCid then 
                    maxPlus = maxPlus + self:GetChemicalPlayersAddValue(cid)
                end
            end
        end
    end

    local totalAttr = 0

    -- 教练百分比属性加成
    local coachRate = self:GetCoachPowerRate()

    for index, attrName in ipairs(attrList) do
        local currentAttrBase = 0
        local singleAttrNum = 0
        local chemicalNum = chemicalBonus + maxPlus
        self.abilityCheckMap[attrName].chemicalNum = chemicalNum

        local staticNum = self.abilityCheckMap[attrName].staticNum
        local levelNum = self.abilityCheckMap[attrName].levelNum
        local potentNum = self.abilityCheckMap[attrName].potentNum
        local upgradeNum = self.abilityCheckMap[attrName].upgradeNum
        local skillNum = self.abilityCheckMap[attrName].skillNum
        local equipNum = self.abilityCheckMap[attrName].equipNum
        local medalNum = self.abilityCheckMap[attrName].medalNum
        local trainingNum = self.abilityCheckMap[attrName].trainingNum
        local heroHallNum = self.abilityCheckMap[attrName].heroHallNum
        local coachNum = self.abilityCheckMap[attrName].coachNum
        local memoryNum = self.abilityCheckMap[attrName].memoryNum
        local legendNum = self.abilityCheckMap[attrName].legendAttrNum
        local homeCourtNum = self.abilityCheckMap[attrName].homeCourtAttrNum
        local fancyAttrNum = self.abilityCheckMap[attrName].fancyAttrNum
        local supportAttrNum = self.abilityCheckMap[attrName].supportAttrNum

        currentAttrBase = staticNum + levelNum + upgradeNum + skillNum + chemicalNum + medalNum + trainingNum
                + heroHallNum + coachNum + memoryNum + legendNum + homeCourtNum + fancyAttrNum + supportAttrNum
        singleAttrNum = currentAttrBase + equipNum + potentNum
        local extraAttribute = medalCombine.extraAttribute[attrName] or 0
        local coachExtraAttribute = coachRate[attrName] or 0
        local legendExtraAttr = self:GetLegendAttrPercent(attrName)
        local homeCourtExtraAttr = self:GetHomeCourtAttrPercent(attrName)
        self.abilityCheckMap[attrName].extraAttribute = extraAttribute
        self.abilityCheckMap[attrName].coachExtraAttribute = coachExtraAttribute
        self.abilityCheckMap[attrName].legendExtraAttr = legendExtraAttr
        self.abilityCheckMap[attrName].homeCourtExtraAttr = homeCourtExtraAttr
        local totalRate = 1 + extraAttribute + coachExtraAttribute + legendExtraAttr + homeCourtExtraAttr
        if totalRate > 1 then
            currentAttrBase = currentAttrBase * totalRate
            equipNum = equipNum * totalRate
            potentNum = potentNum * totalRate
            singleAttrNum = math.floor(singleAttrNum * totalRate + Eps)
        end
        self.abilityCheckMap[attrName].singleAttrNum = singleAttrNum
        baseNum = baseNum + currentAttrBase
        trainNum = trainNum + potentNum
        plusNum = plusNum + equipNum
        totalAttr = totalAttr + singleAttrNum
    end
    return baseNum, plusNum, trainNum, totalAttr
end

-- 不计算勋章战斗力
function PlayerCardModel:GetPowerWithOutMedal()
    local ret = 0

    local base, plus, train = self:GetAllAbilityWithOutMedal()
    ret = base + plus + train
    
    -- 5维球员属性（非阵容）之和*技能百分比加成（EventSkill）
    return self:GetPowerByAttributeWithOutMedal(ret)
end

function PlayerCardModel:GetPowerByAttributeWithOutMedal(ret)
    local percent = self.abilityCheckMap.withoutMedalPercent

    percent = 1 + percent / 10000
    ret = math.floor(ret * percent + Eps)
    return ret
end

function PlayerCardModel:GetAllAbilityWithOutMedal()
    local baseNum = 0
    local plusNum = 0
    local trainNum = 0
    local attrList
    if self:IsGKPlayer() then
        attrList = BaseCardModel.GoalKeeperAttribute
    else
        attrList = BaseCardModel.NormalPlayerAttribute
    end

    -- 球员属性=基础属性 +升级属性 +装备属性 +培养属性（潜力属性+转生属性）+技能属性 +化学属性 +特训属性 +英雄殿堂 +教练属性

    for index, attrName in ipairs(attrList) do
        local chemicalNum = self.abilityCheckMap[attrName].chemicalNum
        local staticNum = self.abilityCheckMap[attrName].staticNum
        local levelNum = self.abilityCheckMap[attrName].levelNum
        local potentNum = self.abilityCheckMap[attrName].potentNum
        local upgradeNum = self.abilityCheckMap[attrName].upgradeNum
        local skillNum = self.abilityCheckMap[attrName].skillNum
        local equipNum = self.abilityCheckMap[attrName].equipNum
        local trainingNum = self.abilityCheckMap[attrName].trainingNum
        local heroHallNum = self.abilityCheckMap[attrName].heroHallNum
        local coachNum = self.abilityCheckMap[attrName].coachNum
        local memoryNum = self.abilityCheckMap[attrName].memoryNum
        local legendNum = self.abilityCheckMap[attrName].legendAttrNum
        local homeCourtNum = self.abilityCheckMap[attrName].homeCourtAttrNum

        local currentAttrBase = 0
        currentAttrBase = staticNum + levelNum + upgradeNum + skillNum + chemicalNum + trainingNum + heroHallNum + coachNum + memoryNum + legendNum + homeCourtNum
        baseNum = baseNum + currentAttrBase
        trainNum = trainNum + potentNum
        plusNum = plusNum + equipNum
    end

    return baseNum, plusNum, trainNum
end

-- 基础属性
function PlayerCardModel:GetBaseAbility(index)
    local staticNum = self.staticData[index]
    return staticNum
end

-- 升级属性
function PlayerCardModel:GetLevelAbility(index)
    local grouthType = self.staticData.grouthType
    local levelRatio = BaseCardModel.CardGrouthType[grouthType] and BaseCardModel.CardGrouthType[grouthType][index] or 0
    local levelNum = (self.cacheData.lvl - 1) * levelRatio
    return levelNum
end

function PlayerCardModel:IsExistChemicalCardID(cid)
    return self.playerCardsMapModel:IsExistCardID(cid)
end

--* 可能会存在不是自身想要的属性查看（例如守门员获取射门属性）
-- 球员在不同阵型中的战力不同（主要有缘分类技能影响）
function PlayerCardModel:GetAbility(index, medalCombine)
    if not self.formationType then
        self.formationType = FormationType.DEFAULT
    end
    medalCombine = medalCombine or self:GetMedalCombine()
    local baseNum = 0
    local plusNum = 0
    local trainNum = 0
    local totalNum = 0

    if not self.abilityCheckMap[index] then 
        self.abilityCheckMap[index] = {}
    end

    if not self.staticData[index] then
        return baseNum, plusNum
    end

    -- 球员属性=基础属性 +升级属性 +装备属性 +培养属性（潜力属性+转生属性）+技能属性 +化学属性 +勋章属性 +特训属性 +英雄殿堂 +教练属性
    local staticNum = self:GetBaseAbility(index)
    baseNum = staticNum

    -- 升级属性
    local levelNum = self:GetLevelAbility(index)
    baseNum = baseNum + levelNum

    -- 球员进阶的属性加成(进阶吃掉的装备属性加成)
    local upgradeNum = self:GetUpgradePowerByAbility(index)
    baseNum = baseNum + upgradeNum
    self.abilityCheckMap[index].upgradeNum = upgradeNum

    -- 球员特训的属性加成
    local trainingNum = self:GetTrainingPowerByAbility(index)
    baseNum = baseNum + trainingNum
    self.abilityCheckMap[index].trainingNum = trainingNum

    -- 英雄殿堂的属性加成
    local heroHallNum = self:GetHerohallPowerByAbility(index)
    baseNum = baseNum + heroHallNum
    self.abilityCheckMap[index].heroHallNum = heroHallNum

    -- 传奇之路的属性加成
    local legendAttrNum = self:GetLegendAbility(index)
    baseNum = baseNum + legendAttrNum
    self.abilityCheckMap[index].legendAttrNum = legendAttrNum

    -- 主场
    local homeCourtAttrNum = self:GetHomeCourtAbility(index)
    baseNum = baseNum + homeCourtAttrNum
    self.abilityCheckMap[index].homeCourtAttrNum = homeCourtAttrNum

    -- 梦幻11人的属性加成
    local fancyAttrNum = self:GetFancyAbility(index)
    baseNum = baseNum + fancyAttrNum
    self.abilityCheckMap[index].fancyAttrNum = fancyAttrNum

    -- 球员助力贴纸
    local supportAttrNum = self:GetSupportAbility(index)
    baseNum = baseNum + supportAttrNum
    self.abilityCheckMap[index].supportAttrNum = supportAttrNum

    self.abilityCheckMap[index].skillNum = 0
    -- 技能的属性加成
    for i, skill in ipairs(self.cacheData.skills) do
        local isComputeSkill, skillTable = self:IsComputeSkillAttrAux(skill) -- defined in BaseCardModel
        if isComputeSkill then
            local coachSkillLvl = self.coachMainModel:GetCoachSkillLvl(skill) -- 教练带来的技能等级提升
            local legendSkillLvl = self:GetLegendSkillLvl(i)
            local homeCourtSkillLvl = self:GetHomeCourtSkillLvl(i, skill.sid)
            local fancySkillLvl = self:GetFancySkillLvl(i)
            local supportSkillLvl = self:GetSupportSkillLvl(i)
            local skillLvl = tonumber(skill.lvl) + tonumber(skill.plvl) + tonumber(skill.mlvl)
                    + tonumber(skill.tlvl) + tonumber(skill.hlvl) + tonumber(coachSkillLvl)
                    + tonumber(legendSkillLvl) + tonumber(homeCourtSkillLvl) +  tonumber(fancySkillLvl) +  tonumber(supportSkillLvl)
            local fixSkillLevel = math.clamp(skillLvl, 1, SkillConstants.MaxLevel)
            local plusTable = skillTable["lvl" .. tostring(fixSkillLevel)] or {}
            local baseLevelTable = skillTable["lvlBase"] or {} -- 技能表优化

            local plus = 0
            if baseLevelTable[index] then
                plus = baseLevelTable[index] + skillTable["lvlImprove"][index] * (fixSkillLevel - 1)
            elseif plusTable[index] then
                plus = plusTable[index]
            end
            baseNum = baseNum + plus
            self.abilityCheckMap[index].skillNum = self.abilityCheckMap[index].skillNum + plus
        end
    end

    -- 培养属性加成
    trainNum = self:GetAdvancePotential(index)
    self.abilityCheckMap[index].trainNum = trainNum

    self.abilityCheckMap[index].chemicalNum = 0
    -- 化学反应的属性加成
    local chemicalData = self:GetChemicalData()
    local currentCid = self:GetCid()
    for i, v in ipairs(chemicalData) do
        local isChemicalActive = true
        for j, cid in ipairs(v.cids) do
            if cid and cid ~= "" and cid ~= currentCid and not self:IsExistChemicalCardID(cid) then
                isChemicalActive = false
                break
            end
        end

        if isChemicalActive then
            -- 基础数值加成
            local chemicalBonus = tonumber(v.chemicalBonus)
            baseNum = baseNum + chemicalBonus
            self.abilityCheckMap[index].chemicalNum = self.abilityCheckMap[index].chemicalNum + chemicalBonus
            for j, cid in ipairs(v.cids) do
                if cid ~= currentCid then 
                    local maxPlus = self:GetChemicalPlayersAddValue(cid)
                    baseNum = baseNum + maxPlus
                    self.abilityCheckMap[index].chemicalNum = self.abilityCheckMap[index].chemicalNum + maxPlus
                end
            end
        end
    end

    -- 勋章的属性加成
    local medalNum = medalCombine.baseAttribute[index] or 0
    baseNum = baseNum + medalNum
    self.abilityCheckMap[index].medalNum = medalNum

    -- 现有装备的属性加成(如果没有达到最大进阶数，得额外计算当前装备加成)
    if self:IsExistUpgradeNum() then 
        local equipNum = self:GetEquipPowerByAbility(index)
        plusNum = equipNum
    end
    self.abilityCheckMap[index].equipNum = plusNum

    -- 教练固定属性加成
    local coachNum = self:GetCoachPowerByAbility(index) or 0
    baseNum = baseNum + coachNum
    self.abilityCheckMap[index].coachNum = coachNum

    -- 教练百分比属性加成
    local coachRate = self:GetCoachPowerRate()

    -- 传奇记忆全属性加成
    local memoryNum = self:GetMemoryPowerAttr()
    baseNum = baseNum + memoryNum
    self.abilityCheckMap[index].memoryNum = memoryNum

    local extraAttribute = medalCombine.extraAttribute[index] or 0
    local coachExtraAttribute = coachRate[index] or 0
    local legendExtraAttr = self:GetLegendAttrPercent(index)
    local homeCourtExtraAttr = self:GetHomeCourtAttrPercent(index)

    self.abilityCheckMap[index].extraAttribute = extraAttribute
    self.abilityCheckMap[index].coachExtraAttribute = coachExtraAttribute
    self.abilityCheckMap[index].legendExtraAttr = legendExtraAttr
    self.abilityCheckMap[index].homeCourtExtraAttr = homeCourtExtraAttr

    local totalRate = 1 + extraAttribute + coachExtraAttribute + legendExtraAttr + homeCourtExtraAttr
    totalNum = baseNum + plusNum + trainNum
    if totalRate > 1 then
        baseNum = math.floor(baseNum * totalRate + Eps)
        plusNum = math.floor(plusNum * totalRate + Eps)
        trainNum = math.floor(trainNum * totalRate + Eps)
        totalNum = math.floor(totalNum * totalRate + Eps)
    end

    return baseNum, plusNum, trainNum, totalNum
end

-- 两个返回值，第二个表示装备给当前球员增加的属性
function PlayerCardModel:GetPass()
    local base, plus, train, total = self:GetAbility("pass")
    if self.cacheData.power then
        if total ~= self.cacheData.power.pass then
            print("pass : " .. tostring(base) .. "+" .. tostring(plus) .. " ~= " .. tostring(self.cacheData.power.pass))
        end
    end
    return base, plus, train, total
end
function PlayerCardModel:GetDribble()
    local base, plus, train, total = self:GetAbility("dribble")
    if self.cacheData.power then
        if total ~= self.cacheData.power.dribble then
            print("dribble : " .. tostring(base) .. "+" .. tostring(plus) .. " ~= " .. tostring(self.cacheData.power.dribble))
        end
    end
    return base, plus, train, total
end
function PlayerCardModel:GetShoot()
    local base, plus, train, total = self:GetAbility("shoot")
    if self.cacheData.power then
        if total ~= self.cacheData.power.shoot then
            print("shoot : " .. tostring(base) .. "+" .. tostring(plus) .. " ~= " .. tostring(self.cacheData.power.shoot))
        end
    end
    return base, plus, train, total
end
function PlayerCardModel:GetIntercept()
    local base, plus, train, total = self:GetAbility("intercept")
    if self.cacheData.power then
        if total ~= self.cacheData.power.intercept then
            print("intercept : " .. tostring(base) .. "+" .. tostring(plus) .. " ~= " .. tostring(self.cacheData.power.intercept))
        end
    end
    return base, plus, train, total
end
function PlayerCardModel:GetSteal()
    local base, plus, train, total = self:GetAbility("steal")
    if self.cacheData.power then
        if total ~= self.cacheData.power.steal then
            print("steal : " .. tostring(base) .. "+" .. tostring(plus) .. " ~= " .. tostring(self.cacheData.power.steal))
        end
    end
    return base, plus, train, total
end
function PlayerCardModel:GetSave()
    local base, plus, train, total = self:GetAbility("save")
    if self.cacheData.power then
        if total ~= self.cacheData.power.save then
            print("save : " .. tostring(base) .. "+" .. tostring(plus) .. " ~= " .. tostring(self.cacheData.power.save))
        end
    end
    return base, plus, train, total
end

-- 是否已经穿上某件装备
function PlayerCardModel:IsWearEquip(slot)
    for i, equip in ipairs(self.cacheData.equips) do
        if tostring(equip.slot) == tostring(slot) then
            return tobool(equip.isEquip)
        end
    end
    return false
end

-- 给球员穿上装备
function PlayerCardModel:WearEquip(slot)
    local equips = self.cacheData.equips
    for i, equip in ipairs(equips) do
        if tostring(equip.slot) == tostring(slot) then
            equip.isEquip = true
            EventSystem.SendEvent("PlayerCardModel_WearEquip", slot)
            return
        end
    end
end

-- 根据装备碎片和装备数量来判断是否满足装备条件
function PlayerCardModel:JudgeEquipCondition(equipID, equipsMapModel, equipPieceMapModel)
    local equipNum = equipsMapModel:GetEquipNum(equipID)
    if equipNum > 0 then
        return true
    else
        local currentPieceNum = equipPieceMapModel:GetEquipPieceNum(equipID)
        local compositePieceNum = Equipment[tostring(equipID)].pieceNum
        if currentPieceNum >= compositePieceNum then
            return true
        end
    end
    return false
end

-- 可用装备包括可用装备碎片达成合成数都会点亮装备
function PlayerCardModel:CanWearEquip(slot)
    local equipItemModel = self:GetEquipModel(slot)
    local equipID = equipItemModel:GetEquipID()
    if self:GetLevel() >= equipItemModel:GetNeedCardLevel() and not equipItemModel:IsEquip() then
        return self:JudgeEquipCondition(equipID, self.equipsMapModel, self.equipPieceMapModel)
    end

    return false
end

function PlayerCardModel:HasOneKeyEquip()
    local equips = self:GetEquips()
    for i, equip in ipairs(equips) do
        local slot = equip.slot
        local canWearEquip = self:CanWearEquip(slot)
        if canWearEquip then 
            return true
        end
    end
    return false
end

-- 是否可以回收球员
function PlayerCardModel:IsCanRecycle()
    return self:IsLevelMaxState()
end

function PlayerCardModel:GetAvailableEquipToSwear()
    local availableEquip = {}
    local availableEquipPiece = {}
    local equipsWearMap = {} -- 同样装备需要判断道具数量
    local equips = self:GetEquips()
    for i, equip in ipairs(equips) do
        local slot = equip.slot
        local equipItemModel = self:GetEquipModel(slot)
        local equipID = equipItemModel:GetEquipID()
        if not equipItemModel:IsEquip() then
            if equipsWearMap[equipID] then 
                equipsWearMap[equipID] = equipsWearMap[equipID] + 1 
            else   
                equipsWearMap[equipID] = 1  
            end
        end
        if self:GetLevel() >= equipItemModel:GetNeedCardLevel() and not equipItemModel:IsEquip() then
            local equipNum = self.equipsMapModel:GetEquipNum(equipID)
            local fixValue = equipNum - equipsWearMap[equipID]
            if fixValue >= 0 then
                table.insert(availableEquip, slot)
            else
                local currentPieceNum = self.equipPieceMapModel:GetEquipPieceNum(equipID)
                local compositePieceNum = Equipment[tostring(equipID)].pieceNum
                if currentPieceNum >= compositePieceNum * math.abs(fixValue) then
                    local pieceData = {slot = slot, eid = equipID}
                    table.insert(availableEquipPiece, pieceData)
                end
            end
        end
    end
    return availableEquip, availableEquipPiece
end

function PlayerCardModel:CanSkillLevelUp(slot)
    local skillItemModel = self:GetSkillModel(slot)
    if tonumber(self:GetSkillPoint()) > 0
        and skillItemModel:IsOpen()
        and tonumber(skillItemModel:GetLevel()) < tonumber(skillItemModel:GetSkillMaxLevel()) then
        return true
    end
    return false
end

-- 是否有技能达到升级条件
function PlayerCardModel:HasSkillSign()
    local skills = self:GetSkills()
    for slot, skill in ipairs(skills) do
        local isSkillLevel = self:CanSkillLevelUp(slot)
        if isSkillLevel then
            return true
        end
    end
    return false
end

function PlayerCardModel:HasSign()
    local isCourtAthlete = self:IsInPlayingLock()
    if not isCourtAthlete then 
        return false
    end
    local hasPasterAvailableWithoutSame = self:HasPasterAvailableWithoutSame()
    if hasPasterAvailableWithoutSame then
    -- 周贴纸及全员可用贴外直接显示红点
        if self:HasOtherPasterAvailable() then
            return true
        end
    -- 有可用周贴纸且已装备周贴纸没达到上限时显示标记
        local hasWeekAvailable = self:HasWeekPasterAvailable()
        local weekPasterNotFull = self:GetWeekPasterNum() < self:GetWeekPasterLimit()
        if hasWeekAvailable and weekPasterNotFull then
            return true
        end
    end
    local skillSign = self:HasSkillSign()
    if skillSign then 
        return true
    end
    local upgradeSign = self:HasUpgradeSign()
    if upgradeSign then 
        return true
    end 
    return false
end

-- 可用装备包括可用装备碎片达成合成数都会点亮装备红点（装备未达到，碎片达到也算满足, 不考虑等级即装备等级未达到也算满足。）
function PlayerCardModel:IsReachWearEquipCondition(slot)
    local equipItemModel = self:GetEquipModel(slot)
    local equipID = equipItemModel:GetEquipID()
    if not equipItemModel:IsEquip() then
        return self:JudgeEquipCondition(equipID, self.equipsMapModel, self.equipPieceMapModel)
    end

    return false
end

function PlayerCardModel:HasEquipFull()
    local equips = self:GetEquips()
    for i, equip in ipairs(equips) do
        if not equip.isEquip then
            return false
        end
    end
    return true
end

-- 是否达到进阶标记（进阶中有装备可穿戴）
function PlayerCardModel:HasUpgradeSign()
    local equips = self:GetEquips()
    for i, equip in ipairs(equips) do
        local isCanEquip = self:IsReachWearEquipCondition(equip.slot)
        if isCanEquip then
            return true
        end
    end
    return self:IsCanUpgrade()
end

-- 重置球员equips字段数据
function PlayerCardModel:ResetEquipsData(equips)
    assert(type(equips) == "table")
    self.cacheData.equips = equips
end


-- 球员的缘分类技能是否激活
function PlayerCardModel:IsChemicalSkillActivate(skillItemModel)
    assert(skillItemModel:IsChemicalSkill() == true)

    -- 判断球员列表里是否存在这两位球员
    local card1, card2 = skillItemModel:GetChemicalSkillCoupleID()

    return self:IsChemicalSkillValid(card1, card2, self.formationType)
end

-- 球员技能升级
-- @param pcid 
-- @param skillPoint 更新球员的技能点数
-- @param skillsData 更新球员的技能数据
function PlayerCardModel:UpdateSkillLevelUp(pcid, skillPoint, skillsData)
    assert(tostring(pcid) == tostring(self:GetPcid()))
    self.cacheData.skillPoint = skillPoint
    self.cacheData.skills = skillsData

    EventSystem.SendEvent("PlayerCardModel_UpdateSkillLevelUp", pcid)
end

-- 计算给球员增加经验可以达到的等级
function PlayerCardModel:GetIfAddExp(addExp)
    assert(addExp)
    local isExpOverflow
    local afterExp
    local afterLevel
    local maxLevel = self:GetLevelLimit()
    local maxLevelExp = self:GetExpLimitEx(maxLevel)

    if self:GetExp() >= maxLevelExp then
        return self:GetExp(), maxLevel
    else
        if self:GetExp() + addExp >= maxLevelExp then
            return maxLevelExp, maxLevel
        else
            return self:GetExp() + addExp, self:GetLevelWithExp(self:GetExp() + addExp)
        end
    end
end

-- 经验值对应的等级
function PlayerCardModel:GetLevelWithExp(exp)
    for i = 1, table.nums(CardLevel) do
        if not CardLevel[tostring(i + 1)] then
            return i
        end
        if exp >= CardLevel[tostring(i)].cumCardExp and exp < CardLevel[tostring(i + 1)].cumCardExp then
            return i
        end
    end
end

-- 是否出现在转会市场(需品质大于等于4， 进阶大于等于4)
function PlayerCardModel:IsTransferOpen()
    local quality = self:GetCardQuality()
    local upgrade = self:GetUpgrade()
    return tobool(quality >= 4 and upgrade >= 4)
end

function PlayerCardModel:IsSkillOpen()
    return true
end

-- 获得门将对应的五维属性计算的战力，一键上阵时排序使用
function PlayerCardModel:GetPowerWithGk()
    local ret = 0
    for i, attrName in ipairs(BaseCardModel.GoalKeeperAttribute) do
        local base, plus, train, total = self:GetAbility(attrName)
        ret = ret + total
    end
    return ret
end

-- 获得非门将对应的五维属性计算的战力，一键上阵时排序使用
function PlayerCardModel:GetPowerWithNotGk()
    local ret = 0
    for i, attrName in ipairs(BaseCardModel.NormalPlayerAttribute) do
        local base, plus, train, total = self:GetAbility(attrName)
        ret = ret + total
    end
    return ret
end

function PlayerCardModel:IsInOtherFormation()
    local teamsModel = require("ui.models.PlayerTeamsModel").new()
    for tid = 0, 2 do
        if teamsModel:IsPlayerInInitTeam(self:GetPcid(), tid) or teamsModel:IsPlayerInReplaceTeam(self:GetPcid(), tid) then
            return true
        end
    end
    return false
end

function PlayerCardModel:SetChemicalTab(chemicalTab)
    self.cacheData.chemicalTab = chemicalTab
    EventSystem.SendEvent("PlayerCardModel_ChangeChemical", chemicalTab)
end

function PlayerCardModel:IsCoachFeatureOpen()
    return self:HasCoachFeature()
end

-- 获取球员特性技能数据
function PlayerCardModel:GetCoachFeature()
    return self.cacheData.coachGuide or {}
end

-- 球员是否在特性栏
function PlayerCardModel:HasCoachFeature()
    local coachGuideOpen = tonumber(self.cacheData.coachGuideOpen) or 1
    return coachGuideOpen > 0
end

-- 球员在特性栏的第几个栏位对应 CoachGuidePrice
function PlayerCardModel:GetCoachGuideSlotId()
    local coachGuideOpen = tonumber(self.cacheData.coachGuideOpen) or 1
    if coachGuideOpen > 0 then
        return coachGuideOpen
    end
end

-- 球员在特性栏对应栏位下最多有几个技能 对应CoachGuidePrice.effectAmount
function PlayerCardModel:GetCoachGuideEffectAmount()
    local coachGuideOpen = tonumber(self.cacheData.coachGuideOpen) or 1
    if coachGuideOpen > 0 then
        local effectAmount = CoachGuidePrice[tostring(coachGuideOpen)].effectAmount or 0
        return effectAmount
    end
    return 5
end

-- 球员model数据刷新
function PlayerCardModel:RefreshCardData(pcid)
    self:InitWithCache(self.playerCardsMapModel:GetCardData(pcid))
end

function PlayerCardModel:SetTeamModelInCoachModel(teamsModel)
    self.coachMainModel:SetTeamModel(teamsModel)
end

function PlayerCardModel:GetCoachMainModel()
    return self.coachMainModel
end

--  <summary>
--  传奇之路属性
function PlayerCardModel:GetLegendAbility(index)
    local allAttr1 = self.legendCardImprove.allAttr
    local allAttr2 = self.legendSkillImprove.allAttr
    local singleAttr1 = self.legendCardImprove.attr and self.legendCardImprove.attr[index]
    local singleAttr2 = self.legendSkillImprove.attr and self.legendSkillImprove.attr[index]
    local staticNum = tonumber(allAttr1) + tonumber(allAttr2) + tonumber(singleAttr1) + tonumber(singleAttr2)
    return staticNum
end

--* 传奇之路的全技能不包括贴纸， 传奇之路的技能提升的全技能包括贴纸
function PlayerCardModel:GetLegendSkillLvl(slot)
    local allSkill2 = self.legendSkillImprove.allSkill
    local singleSkill1 = self.legendCardImprove.skill and self.legendCardImprove.skill[tostring(slot)]
    local singleSkill2 = self.legendSkillImprove.skill and self.legendSkillImprove.skill[tostring(slot)]
    local isBaseSkill = self:IsBaseSkill(slot)
    local baseSkill = isBaseSkill and self.legendSkillImprove.baseSkill
    local allSkill1 = isBaseSkill and self.legendCardImprove.allSkill or 0
    local staticNum = tonumber(allSkill1) + tonumber(allSkill2) + tonumber(singleSkill1) + tonumber(singleSkill2) + tonumber(baseSkill)
    return staticNum
end

-- 属性比是以万为单位
function PlayerCardModel:GetLegendAttrPercent(index)
    local attrPercent = self.legendSkillImprove.attrPercent and self.legendSkillImprove.attrPercent[index]
    local allAttrPercent = self.legendSkillImprove.allAttrPercent
    local staticNum = tonumber(attrPercent) + tonumber(allAttrPercent)
    return staticNum / 10000
end

-- 梦幻11人对当前球员加成
function PlayerCardModel:InitFancyImprove()
    local cid = self:GetCid()
    self.fancyImprove = self.fancyCardsMapModel:GetCardImprove(cid)
end

-- 梦幻11人属性
function PlayerCardModel:GetFancyAbility(index)
    return self.fancyImprove.attrTotal
end

-- 梦幻11人的全技能包括贴纸
function PlayerCardModel:GetFancySkillLvl(slot)
    return self.fancyImprove.skill
end

function PlayerCardModel:GetLegendSkillPercent()
    local skillPercent = self.legendSkillImprove.skillPercent
    local staticNum = tonumber(skillPercent)
    return staticNum
end

function PlayerCardModel:GetLegendPotentImprove()
    local potent = self.legendCardImprove.potent
    local staticNum = tonumber(potent)
    return staticNum
end

function PlayerCardModel:HasPasterSKillExAvailable()
    local changeExSkill = self.legendCardImprove.changeExSkill
    local exEffect = self:HasLegendRoadExEffect()
    return not exEffect and tonumber(changeExSkill) > 0 and self:IsMaxAscend()
end

-- 传奇之路数据
function PlayerCardModel:GetLegendSkillImprove()
    local cardImprove = {}
    if self:IsPlayerInStarter() then
        cardImprove = self.legendCardsMapModel:GetLegendSkillImprove(self)
    end
    return cardImprove
end

function PlayerCardModel:GetLegendCardImprove()
    local cardImprove = {}
    if self:IsPlayerInStarter() and self:IsMaxAscend() then
        cardImprove = self.legendCardsMapModel:GetLegendCardImprove(self:GetPcid())
    end
    return cardImprove
end
--  </summary>

--  <summary>
--  主场属性加成
function PlayerCardModel:GetHomeCourtAbility(index)
    local singleAttr = self.homeCourtImprove.attr and self.homeCourtImprove.attr[index]
    local staticNum = tonumber(singleAttr)
    return staticNum
end

--  主场属性百分比加成
function PlayerCardModel:GetHomeCourtAttrPercent(index)
    local attrPercent = self.homeCourtImprove.attrPercent and self.homeCourtImprove.attrPercent[index]
    local staticNum = tonumber(attrPercent)
    return staticNum / 100
end

-- 主场技能等级加成
function PlayerCardModel:GetHomeCourtSkillLvl(slot, sid)
    local sidLvl = self.homeCourtImprove.skillIdMap and self.homeCourtImprove.skillIdMap[sid]
    local allSkill = self.homeCourtImprove.allSkill
    local singleSkill = self.homeCourtImprove.skill and self.homeCourtImprove.skill[tostring(slot)]
    local isBaseSkill = self:IsBaseSkill(slot)
    local baseSkill = isBaseSkill and self.homeCourtImprove.baseSkill
    local staticNum = tonumber(sidLvl) + tonumber(allSkill) + tonumber(singleSkill) + tonumber(baseSkill)
    return staticNum
end

function PlayerCardModel:GetHomeCourtImprove()
    local homeCourtImprove = {}
    if self.teamsModel:IsHomeCourt() and self:HasCoachFeature() and self:IsPlayerInStarter() then
        self.cardFeatureCurrentAdditionModel:InitFeatureSkills(self:GetCoachFeature())
        self.cardFeatureCurrentAdditionModel:AllotAdditionContents(self.homeCourtModel:GetHome(), self.homeCourtModel:GetWeather(), self.homeCourtModel:GetGrass(), self.homeCourtModel:GetStartersCategory())
        homeCourtImprove.skillIdMap = self.cardFeatureCurrentAdditionModel:GetSkillMap()
        homeCourtImprove.attr = self.cardFeatureCurrentAdditionModel:GetAttrMap()
        homeCourtImprove.attrPercent = self.cardFeatureCurrentAdditionModel:GePercentMap()
        homeCourtImprove.skill = self.cardFeatureCurrentAdditionModel:GetSlotMap()
        homeCourtImprove.baseSkill = self.cardFeatureCurrentAdditionModel:GetSkillsWithoutPasterLevel()
        homeCourtImprove.allSkill = self.cardFeatureCurrentAdditionModel:GetSkillsAllLevel()
    end
    return homeCourtImprove
end

-- 球员助力 是否开启
local SupporterQualityCondition = 6 -- 传奇之路要求ss以上才开启
function PlayerCardModel:CanUseSupporter()
    ------------------------------------------
    -- 海外版暂时屏蔽助阵入口
    -- local quality = self:GetCardQuality()
    -- local IsLevelMax = self:IsLevelMaxState()
    -- if quality >= SupporterQualityCondition and IsLevelMax then
    --     return true
    -- end
    ------------------------------------------
    return false
end

-- 球员助力 贴纸带来的加成 包括 （五维属性 全技能等级）
function PlayerCardModel:InitSupportPasterData()
    if self:IsHasSupportCard() then
        if not self.supportCardModel then
            local spcid = self:GetSpcid()
            self.supportCardModel = PlayerCardModel.new(spcid)
            self.supportCardModel:InitEquipsAndSkills()
            self.supportCardModel:InitPasterModel()
        end
        local preAttr, supportPasterAttr = self.supportCardModel:GetSupportPasterAbility()
        local supportPasterSkillLvl = self:GetSupportPasterSkillLev(self.supportCardModel)
        self.supportPasterAttr = supportPasterAttr
        self.supportPasterSkillLvl = supportPasterSkillLvl or 0
    else
        self.supportCardModel = nil
        self.supportPasterAttr = {}
        self.supportPasterSkillLvl = 0
    end
end

-- 球员助力 属性
function PlayerCardModel:GetSupportAbility(index)
    return self.supportPasterAttr[index] or 0
end

-- 球员助力 全技能等级
function PlayerCardModel:GetSupportSkillLvl(slot)
    return self.supportPasterSkillLvl
end

--球员助力 获取周贴提供的助阵属性加成
function PlayerCardModel:GetSupportPasterAbility()
    local ability = {}
    local supportAbility = {}
    local skills = self:GetSkills()
    for k, paster in pairs(self:GetPasterModel()) do
        if paster:GetPasterType() == PasterMainType.Week then
            local pasterId = paster:GetId()
            local slot
            for i, v in ipairs(skills) do
                if tostring(v.ptid) == tostring(pasterId) then
                    slot = i
                    break
                end
            end
            local skillItemModel = self:GetSkillModel(slot)
            local newPasterModel = self:GetPasterAppointModel(pasterId)
            local attributePlusTable = skillItemModel:GetEffectPlus(newPasterModel:GetPasterSkillLvl())
            local index = 1
            local isAllAttribute = false
            local supporterPer = skillItemModel:GetSkillSupporterPercent() / 10000
            for abilityIndex, plusValue in pairs(attributePlusTable) do
                if not ability[abilityIndex] then
                    ability[abilityIndex] = plusValue
                    supportAbility[abilityIndex] = plusValue * supporterPer
                else
                    ability[abilityIndex] = ability[abilityIndex] + plusValue
                    supportAbility[abilityIndex] = supportAbility[abilityIndex] + plusValue * supporterPer
                end
            end
        end
    end

    for k, v in pairs(supportAbility) do
        supportAbility[k] = math.floor(supportAbility[k])
    end
    return ability, supportAbility
end

--球员助力 获取荣耀贴纸、周年贴纸助阵加成的初始等级
function PlayerCardModel:GetSupportPasterSkillInitLev()
    local lev2 = 0
    local lev3 = 0
    local lev5 = 0
    for k, paster in pairs(self:GetPasterModel()) do
        if paster:IsMonthPaster() then
            lev2 = lev2 + 1
        elseif paster:IsHonorPaster() then
            lev3 = lev3 + paster:GetHonorSkillLevelEx()
        elseif paster:IsAnnualPaster() then
            lev5 = lev5 + paster:GetAnnualSkillLevelEx()
        end
    end
    return lev2, lev3, lev5
end

--球员助力获取荣耀贴纸、周年贴纸助阵加成的等级
function PlayerCardModel:GetSupportPasterSkillLev(supportCardModel)
    local lev2, lev3, lev5 = supportCardModel:GetSupportPasterSkillInitLev()
    local perCfg = self:GetSupportPasterPer()
    return math.floor(((tonumber(perCfg['2'])) * lev2 + tonumber(perCfg['3']) * lev3 + tonumber(perCfg['5']) * lev5) / 10000)
end

--球员助力 获取荣耀贴纸、周年贴纸加成的百分比
function PlayerCardModel:GetSupportPasterPer()
    local qualityFixed = self:GetQualityConfigFixed()
    local pasterPercent = CardSupporter[qualityFixed].pasterPercent
    return pasterPercent
end

-- 根据card表里的quality 和 qualitySpecial 把品质转换为其他配表里的缩写
function PlayerCardModel:GetQualityConfigFixed()
    local quality = self:GetCardQuality()
    local qualitySpecial = self:GetCardQualitySpecial()
    local qualityFixed = CardHelper.GetQualityConfigFixed(quality, qualitySpecial)
    return qualityFixed
end

-- 球员助力 品质要求
function PlayerCardModel:IsSupporterQualityFulfill(quality)
    if self:GetCardQuality() < 6 then
        return false
    end
    local qualityFixed = self:GetQualityConfigFixed()
    local supporterQuality = CardSupporter[qualityFixed].supporterQuality
    for i, v in pairs(supporterQuality) do
        if quality == v then
            return true
        end
    end
    return false 
end

return PlayerCardModel

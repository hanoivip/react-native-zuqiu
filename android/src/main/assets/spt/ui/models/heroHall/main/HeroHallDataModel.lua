local Model = require("ui.models.Model")
local FootballHall = require("data.FootballHall")
local FootballHallShow = require("data.FootballHallShow")
local FootballHallStatue = require("data.FootballHallStatue")
local FootballHallImprove = require("data.FootballHallImprove")
local AttributeType = require("ui.models.heroHall.main.HeroHallAttributeType")
local ImproveType = require("ui.models.heroHall.main.HeroHallImproveType")
local HeroHallEffectType = require("ui.models.heroHall.main.HeroHallEffectType")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local Card = require("data.Card")

local HeroHallDataModel = class(Model, "HeroHallDataModel")

local default_hall_pic = "posun1"

function HeroHallDataModel:ctor()
    HeroHallDataModel.super.ctor(self)
    self.heroHallProvideMap = cache.getPlayerHeroHallProvideMap() or {}
    if table.nums(self.heroHallProvideMap) == 0 then
        for hallID, config in pairs(FootballHall) do
            for k, configBaseID in pairs(config.playerHall) do
                if not self.heroHallProvideMap[configBaseID] then
                    self.heroHallProvideMap[configBaseID] = {}
                end
                table.insert(self.heroHallProvideMap[configBaseID], hallID)
            end
        end
        cache.setPlayerHeroHallProvideMap(self.heroHallProvideMap)
    end
end

-- 根据殿堂id获得配表
function HeroHallDataModel:GetHallConfigDataById(hallID)
    return FootballHall[tostring(hallID)] or {}
end

-- 根据球员BaseID获得配置表中顺序
function HeroHallDataModel:GetStatueIndex(hallID, baseID)
    local hallData = FootballHall[tostring(hallID)] or {}
    local playerHall = hallData.playerHall
    for k, configBaseID in pairs(playerHall) do
        if configBaseID == baseID then
            return tonumber(k)
        end
    end
    return -1
end

-- 根据球员baseID，判断球员是否为殿堂中配置的球员，并返回hallID
function HeroHallDataModel:IsStatueCard(baseID)
    local result = self.heroHallProvideMap[baseID] ~= nil
    local hallIDList = self.heroHallProvideMap[baseID] or {}
    return result, hallIDList
end

-- 根据评分，获得殿堂图片资源
function HeroHallDataModel:GetHallPicResByScore(score)
    for k, v in pairs(FootballHallShow) do
        if score >= v.lowScore and score <= v.highScore then
            return v.pictureID
        end
    end
    return default_hall_pic
end

-- 根据等级获得额外属性提高万分比的值
function HeroHallDataModel:GetImprovePercentById(id)
    if FootballHallImprove[tostring(id)] then
        return FootballHallImprove[tostring(id)].improvePercent
    else
        return 0
    end
end

-- 升级特殊条件，获取当前卡牌这个特殊条件的状态
function HeroHallDataModel:GetImproveStatus(id)
    if string.len(id) > 0 then
        local firstIndexStart, firstIndexEnd, improveStatue = string.find(id, "(%d+)", 1)
        local secondIndexStart, secondIndexEnd, improveSpecial = string.find(id, "(%d+)", firstIndexStart + string.len(improveStatue))
        return tonumber(improveStatue), tonumber(improveSpecial)
    else
        return 0, 0
    end
end

-- 根据品质，获得improve表中的id
-- 表中improveSpecial无值为0
function HeroHallDataModel:GetImproveConfigIdByQuality(quality, qualitySpecail)
    local id = ""
    if qualitySpecail > 0 then
        id = ImproveType.quality.improveType .. "_" .. quality .. "_" .. qualitySpecail
    else
        id = ImproveType.quality.improveType .. "_" .. quality
    end
    return id
end

-- 根据进阶，获得improve表中的id
function HeroHallDataModel:GetImproveConfigIdByUpgrade(upgrade)
    local id = ImproveType.upgrade.improveType .. "_" .. upgrade
    return id
end

-- 根据转生，获得improve表中的id
function HeroHallDataModel:GetImproveConfigIdByAscend(ascend)
    local id = ImproveType.ascend.improveType .. "_" .. ascend
    return id
end

-- 根据球员特训，获得improve表中的id
function HeroHallDataModel:GetImproveConfigIdByTrainingBase(chapter, stage)
    local id = ImproveType.TrainingBase.improveType .. "_" .. chapter .. "_" .. stage
    return id
end

function HeroHallDataModel:GetStatueConfigByLevel(level)
    return FootballHallStatue[tostring(level)]
end

-- 根据等级获得基础属性值
function HeroHallDataModel:GetStatueBasicAttributeByLevel(level)
    return self:GetStatueConfigByLevel(level).improveNum
end

-- 根据等级，获得雕像图片资源
function HeroHallDataModel:GetStatueIconByLevel(level)
    return self:GetStatueConfigByLevel(level).pictureID
end

-- 根据等级，获得雕像品质名称及等级
function HeroHallDataModel:GetStatueQualityDescByLevel(level)
    return self:GetStatueConfigByLevel(level).nameLevel .. self:GetStatueConfigByLevel(level).nameQuality
end

-- 根据等级，获得雕像升级特殊条件
function HeroHallDataModel:GetStatueUpgradeSpecialCondition(level)
    local condition = {}
    local specialCondition = self:GetStatueConfigByLevel(level).improveType
    if string.len(specialCondition) > 0 then
        condition[specialCondition] = self:GetStatueConfigByLevel(level).improveStatus
    end
    return condition
end

-- 根据当前等级，获得雕像升级消耗资源
function HeroHallDataModel:GetUpgradeMaterialByLevel(currLevel)
    local material = {}
    local level = tostring(currLevel)
    local statueConfig = self:GetStatueConfigByLevel(level)
    material.m = statueConfig.m or 0
    material.d = statueConfig.d or 0
    material.smd = statueConfig.smd or 0
    material.smb = statueConfig.smb or 0
    return material
end

-- 获得殿堂的属性值
function HeroHallDataModel:GetHallAttributes(hallID, hallData)
    local statueList = hallData.list
    local attributes = clone(AttributeType)
    for baseID, statueData in pairs(statueList) do
        local statueAttrbutes = self:GetAttributesByStatueData(hallID, statueData)
        for attrName, v in pairs(attributes) do
            attributes[attrName] = v + statueAttrbutes[attrName]
        end
    end
    return attributes
end

-- 根据雕像数据计算雕像所增益的属性值
-- attributes, table, 所有属性最后结果
-- fixImprove, number, 属性最终值，便于访问计算
-- basicImprove, number, 不计算额外加成的基础属性值，读表获得
-- multiImprove, number, 品质、进阶、转生、特训的额外加成万分之数值，最后除以10000返回小数
function HeroHallDataModel:GetAttributesByStatueData(hallID, statueData)
    local attributes = clone(AttributeType)
    local basicImprove = self:GetStatueBasicAttributeByLevel(statueData.level)
    local attributeType = self:GetHallConfigDataById(hallID).improveType
    local multiImprove = 0  -- 配表中为万分之一数值

    for k, v in pairs(statueData.list) do
        if string.len(v) > 0 then
            multiImprove = multiImprove + self:GetImprovePercentById(v)
        end
    end

    local fixImprove = math.ceil(basicImprove * (1 + (multiImprove / 10000)))

    for k, v in pairs(attributeType) do
        attributes[v] = fixImprove
    end

    return attributes, fixImprove, basicImprove, multiImprove / 10000
end

-- 获得额外属性提升的描述信息
function HeroHallDataModel:GetImproveDesc(statueData)
    local improveList = statueData.list
    local improveDesc = clone(ImproveType)
    local id = improveList[ImproveType.quality.improveType]
    if string.len(id) > 0 then
        local quality, qualitySpecial = self:GetImproveStatus(id)
        local strQuality = lang.transstr(CardHelper.GetQualitySign(CardHelper.GetQualityFixed(quality, qualitySpecial)))
        local strPercent = string.format("%.2f", self:GetImprovePercentById(id) / 100) .. "%"
        if statueData.hasCard then
            improveDesc.quality.desc = lang.transstr("hero_hall_statue_quality_extra", strQuality, strPercent)
        else
            improveDesc.quality.desc = lang.transstr("hero_hall_statue_quality_extra_1", strQuality, strPercent)
        end
    end

    id = improveList[ImproveType.upgrade.improveType]
    if string.len(id) > 0 then
        local upgrade = self:GetImproveStatus(id)
        local strPercent = string.format("%.2f", self:GetImprovePercentById(id) / 100) .. "%"
        improveDesc.upgrade.desc = lang.transstr("hero_hall_statue_upgrade_extra", upgrade, strPercent)
    else
        improveDesc.upgrade.desc = lang.transstr("hero_hall_statue_upgrade_extra_none")
    end

    id = improveList[ImproveType.ascend.improveType]
    if string.len(id) > 0 then
        local ascend = self:GetImproveStatus(id)
        local strPercent = string.format("%.2f", self:GetImprovePercentById(id) / 100) .. "%"
        improveDesc.ascend.desc = lang.transstr("hero_hall_statue_ascend_extra", ascend, strPercent)
    else
        improveDesc.ascend.desc = lang.transstr("hero_hall_statue_ascend_extra_none")
    end

    id = improveList[ImproveType.TrainingBase.improveType]
    if string.len(id) > 0 then
        local trainingBase, trainingBaseSpecial = self:GetImproveStatus(id)
        local strTrainingBase = trainingBase .."-" .. trainingBaseSpecial
        local strPercent = string.format("%.2f", self:GetImprovePercentById(id) / 100) .. "%"
        improveDesc.TrainingBase.desc = lang.transstr("hero_hall_statue_TrainingBase_extra", strTrainingBase, strPercent)
    else
        improveDesc.TrainingBase.desc = lang.transstr("hero_hall_statue_TrainingBase_extra_none")
    end

    local result = {}
    for k, v in pairs(improveDesc) do
        table.insert(result, v)
    end
    table.sort(result, function(a, b)
        return a.index < b.index
    end)

    return result
end

-- 获取雕像的全技能等级增加数值
function HeroHallDataModel:GetSkillImprove(level)
    return tonumber(self:GetStatueConfigByLevel(level).improveSkill)
end

-- 获取雕像全技能等级生效卡牌品质列表
function HeroHallDataModel:GetImproveSkillPlayer(level)
    return self:GetStatueConfigByLevel(level).improveSkillPlayer
end

-- 雕像全技能等级增加品质条件
function HeroHallDataModel:GetImproveSkillCondition(level)
    local improveSkillPlayer = self:GetImproveSkillPlayer(level)
    local maxQuality = 0
    for k, quality in ipairs(improveSkillPlayer) do
        if tonumber(quality) >= maxQuality then
            maxQuality = tonumber(quality)
        end
    end
    return CardHelper.GetQualitySign(maxQuality)
end

-- 获取殿堂的全技能等级增加数值
function HeroHallDataModel:GetHallSkillImprove(statueList, cid)
    local hlvl = 0
    for i, statueData in pairs(statueList) do
        local improveSkillPlayer = self:GetImproveSkillPlayer(statueData.level)
        local quality = Card[cid].quality
        local needHlvl = false
        for k, v in ipairs(improveSkillPlayer) do
            if tonumber(quality) == tonumber(v) then
                needHlvl = true
                break
            end
        end
        if needHlvl then
            hlvl = hlvl + self:GetSkillImprove(statueData.level)
        end
    end
    return hlvl
end

function HeroHallDataModel:GetStatueMaxLevel()
    return table.nums(FootballHallStatue)
end

-- 根据hallID获得殿堂加成效果配置
function HeroHallDataModel:GetHallEffect(hallID)
    local hallEffect = {}
    local hallConfig = self:GetHallConfigDataById(hallID)
    if string.len(hallConfig.hallEffectType) > 0 then
        hallEffect[hallConfig.hallEffectType] = hallConfig.hallEffect
    end

    if string.len(hallConfig.additionHallEffectType) > 0 then
        hallEffect[hallConfig.additionHallEffectType] = hallConfig.additionHallEffect
    end
    return hallEffect
end

return HeroHallDataModel
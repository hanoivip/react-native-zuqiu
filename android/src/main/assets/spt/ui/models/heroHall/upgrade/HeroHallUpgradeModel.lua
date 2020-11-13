local Model = require("ui.models.Model")
local CurrencyType = require("ui.models.itemList.CurrencyType")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local ImproveType = require("ui.models.heroHall.main.HeroHallImproveType")
local HeroHallMapModel = require("ui.models.heroHall.main.HeroHallMapModel")

local HeroHallUpgradeModel = class(Model, "HeroHallUpgradeModel")

function HeroHallUpgradeModel:ctor(statueData, cardModel, heroHallDataModel)
    self.statueData = statueData
    self.cardModel = cardModel
    self.heroHallDataModel = heroHallDataModel
    self.playerInfoModel = PlayerInfoModel.new()
    self.heroHallMapModel = HeroHallMapModel.new()
end

-- 升级雕像后更新，这里的satueData是父界面model的引用，这里改动即可
function HeroHallUpgradeModel:UpdateAfterUpgrade(resposeData)
    self.statueData.level = resposeData.level
    local level = resposeData.level
    self.statueData.score = resposeData.score
    -- 额外属性列表
    self.statueData.list = resposeData.list
    -- 属性值
    self.statueData.attributes, self.statueData.fixAttribute, self.statueData.basicAttribute, self.statueData.multiAttribute = self.heroHallDataModel:GetAttributesByStatueData(self.statueData.hallId, self.statueData)
    -- 描述
    self.statueData.improveDesc = self.heroHallDataModel:GetImproveDesc(self.statueData)
    -- 对应等级icon
    self.statueData.hallPicRes = self.heroHallDataModel:GetStatueIconByLevel(level)
    -- 名字前缀
    self.statueData.statueQualityDesc = tostring(self.heroHallDataModel:GetStatueQualityDescByLevel(level))
    -- 全技能等级增加
    self.statueData.hlvl = self.heroHallDataModel:GetSkillImprove(level)
    -- 全技能等级加成品质条件
    self.statueData.hlvlCondition = self.heroHallDataModel:GetImproveSkillCondition(level)
end

-- 更新玩家货币
function HeroHallUpgradeModel:UpdateCurrency(cost)
    for k, v in pairs(cost) do
        if v.num > 0 then
            if v.type == CurrencyType.Money then-- 欧元
                self.playerInfoModel:SetMoney(v.curr_num)
            elseif v.type == CurrencyType.Diamond then-- 钻石
                self.playerInfoModel:SetDiamond(v.curr_num)
            elseif v.type == CurrencyType.HeroHallSmd then-- 殿堂精华
                self.playerInfoModel:SetHeroHallSmdCurrency(v.curr_num)
            elseif v.type == CurrencyType.HeroHallSmb then-- 殿堂升阶石
                self.playerInfoModel:SetHeroHallSmbCurrency(v.curr_num)
            else
                dump("illegal currency type")
            end
        end
    end
end

function HeroHallUpgradeModel:GetStatueData()
    return self.statueData
end

function HeroHallUpgradeModel:GetCardModel()
    return self.cardModel
end

function HeroHallUpgradeModel:GetHeroHallDataModel()
    return self.heroHallDataModel
end

function HeroHallUpgradeModel:GetCurrLevel()
    return self.statueData.level
end

function HeroHallUpgradeModel:GetNextLevel()
    if self:IsMaxLevel() then
        return self:GetCurrLevel()
    else
        return self.statueData.level + 1
    end
end

function HeroHallUpgradeModel:GetMaxLevel()
    return self.heroHallDataModel:GetStatueMaxLevel()
end

function HeroHallUpgradeModel:IsMaxLevel()
    return self.statueData.level == self:GetMaxLevel()
end

function HeroHallUpgradeModel:GetCurrLevelAttributes()
    local attributes = {}
    for attributeName, value in pairs(self.statueData.attributes) do
        if value > 0 then
            attributes[attributeName] = self.statueData.basicAttribute
        end
    end
    return attributes, self.statueData.basicAttribute
end

function HeroHallUpgradeModel:GetNextLevelAttributes()
    local attributes = {}
    local nextBasicAttribute = self.heroHallDataModel:GetStatueBasicAttributeByLevel(self:GetNextLevel())
    for attributeName, value in pairs(self.statueData.attributes) do
        if value > 0 then
            attributes[attributeName] = nextBasicAttribute
        end
    end
    return attributes, nextBasicAttribute
end

function HeroHallUpgradeModel:GetCurrLevelSkillImprove()
    return self.statueData.hlvl
end

function HeroHallUpgradeModel:GetNextLevelSkillImprove()
    return self:GetSkillImproveByLevel(self:GetNextLevel())
end

function HeroHallUpgradeModel:GetSkillImproveByLevel(level)
    return self.heroHallDataModel:GetSkillImprove(level)
end

function HeroHallUpgradeModel:GetCurrLevelSkillImproveCondition()
    return self.statueData.hlvlCondition
end

function HeroHallUpgradeModel:GetNextLevelSkillImproveCondition()
    return self:GetSkillImproveConditionByLevel(self:GetNextLevel())
end

function HeroHallUpgradeModel:GetSkillImproveConditionByLevel(level)
    return self.heroHallDataModel:GetImproveSkillCondition(level)
end

function HeroHallUpgradeModel:GetCurrLevelIcon()
    return self:GetIconByLevel(self:GetCurrLevel())
end

function HeroHallUpgradeModel:GetNextLevelIcon()
    return self:GetIconByLevel(self:GetNextLevel())
end

function HeroHallUpgradeModel:GetIconByLevel(level)
    return self.heroHallDataModel:GetStatueIconByLevel(level)
end

function HeroHallUpgradeModel:GetCurrLevelStatueQualityDesc()
    return self:GetStatueQualityDescByLevel(self:GetCurrLevel())
end

function HeroHallUpgradeModel:GetNextLevelStatueQualityDesc()
    return self:GetStatueQualityDescByLevel(self:GetNextLevel())
end

function HeroHallUpgradeModel:GetStatueQualityDescByLevel(level)
    return self.heroHallDataModel:GetStatueQualityDescByLevel(level)
end

function HeroHallUpgradeModel:GetStatueCardName()
    return self.statueData.cardName
end

-- 获得升级消耗材料
function HeroHallUpgradeModel:GetUpgradeMaterial()
    return self.heroHallDataModel:GetUpgradeMaterialByLevel(self:GetCurrLevel())
end

-- 获得升级特殊条件
function HeroHallUpgradeModel:GetUpgradeSpecialCondition()
    return self.heroHallDataModel:GetStatueUpgradeSpecialCondition(self:GetCurrLevel())
end

-- 材料判断
function HeroHallUpgradeModel:CanMaterialUpgrade()
    local material = self:GetUpgradeMaterial()
    local canMaterialUpgrade = true
    local materialNotEnoughList = {}
    for currencyType, v in pairs(material) do
        if v > 0 then
            local isEnough
            if currencyType == CurrencyType.Money then-- 欧元
                isEnough = self.playerInfoModel:GetMoney() >= v
            elseif currencyType == CurrencyType.Diamond then-- 钻石
                isEnough = self.playerInfoModel:GetDiamond() >= v
            elseif currencyType == CurrencyType.HeroHallSmd then-- 殿堂精华
                isEnough = self.playerInfoModel:GetHeroHallSmdCurrency() >= v
            elseif currencyType == CurrencyType.HeroHallSmb then-- 殿堂升阶石
                isEnough = self.playerInfoModel:GetHeroHallSmbCurrency() >= v
            else
                canMaterialUpgrade = false
                isEnough = true
                dump("illegal currency type")
            end
            canMaterialUpgrade = canMaterialUpgrade and isEnough
            materialNotEnoughList[currencyType] = isEnough
        end
    end
    return canMaterialUpgrade, materialNotEnoughList
end

-- 特殊条件判断
function HeroHallUpgradeModel:CanSpecialUpgrade()
    local condition = self:GetUpgradeSpecialCondition()
    local canSpecialUpgrade = true
    for k, v in pairs(condition) do
        if string.len(self.statueData.list[k]) <= 0 then
            canSpecialUpgrade = false
        else
            if k ~= ImproveType.TrainingBase.improveType then
                local currCondition = self.heroHallDataModel:GetImproveStatus(self.statueData.list[k])
                canSpecialUpgrade = canSpecialUpgrade and currCondition >= v
            else
                local currCondition = self.heroHallMapModel:GetTrainingBaseStatusByBaseID(self:GetBaseId())
                canSpecialUpgrade = canSpecialUpgrade and currCondition >= v
            end
        end
    end
    return canSpecialUpgrade, condition
end

function HeroHallUpgradeModel:GetBaseId()
    return self.statueData.baseId
end

function HeroHallUpgradeModel:GetHallId()
    return self.statueData.hallId
end

return HeroHallUpgradeModel
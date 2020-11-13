local EventSystem = require ("EventSystem")
local Model = require("ui.models.Model")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local EquipsMapModel = require("ui.models.EquipsMapModel")
local ItemsMapModel = require("ui.models.ItemsMapModel")
local SkillItemModel = require("ui.models.common.SkillItemModel")
local PasterManagerModel = require("ui.models.cardDetail.PasterManagerModel")
local PlayerBindingEquipModel = require("ui.models.cardDetail.PlayerBindingEquipModel")
local CardDetailPageType = require("ui.scene.cardDetail.CardDetailPageType")
local CardOwnershipType = require("ui.controllers.cardDetail.CardOwnershipType")
local CardDetailModuleType = require("ui.controllers.cardDetail.CardDetailModuleType")

local CardDetailModel = class(Model, "CardDetailModel")

function CardDetailModel:ctor(cardModel)
    self.cardModel = cardModel
    self.currentModuleType = CardDetailModuleType.NONE -- 默认二级界面
    self.currentPageTag = CardDetailPageType.BasePage -- 默认页面标签
    CardDetailModel.super.ctor(self)
end

function CardDetailModel:GetPasterManagerModel()
    return self.pasterManagerModel
end

function CardDetailModel:GetImageRes(key)
    local pasterType = self.cardModel:GetPasterMainType()
    return self.pasterManagerModel:GetImageRes(key, pasterType)
end

function CardDetailModel:GetTextColor(key)
    local pasterType = self.cardModel:GetPasterMainType()
    return self.pasterManagerModel:GetTextColor(key, pasterType)
end

-- 设置当前二级界面标签
function CardDetailModel:SetCurrentModule(currentModuleType)
    self.currentModuleType = currentModuleType
end

function CardDetailModel:GetCurrentModule()
    return self.currentModuleType
end

-- 设置当前页面标签
function CardDetailModel:SetCurrentPage(currentPageTag)
    self.currentPageTag = currentPageTag
end

function CardDetailModel:GetCurrentPage()
    return self.currentPageTag
end

-- 是否可操作
function CardDetailModel:IsOperable()
    return self.cardModel:IsOperable()
end

-- 是否可跳转
function CardDetailModel:IsAllowChangeScene()
    return self.cardModel:IsAllowChangeScene()
end

-- 装备加成属性
function CardDetailModel:GetEquipAbilityPlus(slot)
    return self.cardModel:GetEquipAbilityPlus(slot)
end

-- 是否为门将
function CardDetailModel:IsGKPlayer()
    return self.cardModel:IsGKPlayer()
end

function CardDetailModel:Init()
    self.playerCardsMapModel = PlayerCardsMapModel.new()
    self.pasterManagerModel = PasterManagerModel.new()
    self.equipsMapModel = EquipsMapModel.new()
    self.itemsMapModel = ItemsMapModel.new()
    self:InitEquipsAndSkills()
    self:InitPasterModel()
    self:InitMedalModel()
	self:InitFeatureModel()
end

-- 更换球员后重新刷新数据
function CardDetailModel:RefreshCardModel(...)
    self.cardModel:RefreshCardData(...)
    self.cardModel = self:GetCardModel()
    self:InitEquipsAndSkills()
    self:InitPasterModel()
    self:InitMedalModel()
	self:InitFeatureModel()
end

function CardDetailModel:InitEquipsAndSkills()
    self.cardModel:InitEquipsAndSkills()
end

function CardDetailModel:InitPasterModel()
    self.cardModel:InitPasterModel()
end

function CardDetailModel:InitMedalModel()
    self.cardModel:InitMedalModel()
end

function CardDetailModel:InitFeatureModel()
    self.cardModel:InitFeatureModel()
end

function CardDetailModel:InitLegendRoadImprove()
    self.cardModel:InitLegendRoadImprove()
end

function CardDetailModel:GetEquipsList()
    return self.cardModel:GetEquips()
end

function CardDetailModel:GetEquipsMap()
    return self.cardModel:GetEquipsMap()
end

function CardDetailModel:GetEquipModel(slot)
    return self.cardModel:GetEquipModel(slot)
end

function CardDetailModel:GetSkillsList()
    return self.cardModel:GetSkills()
end

function CardDetailModel:GetSkillsMap()
    return self.cardModel:GetSkillsMap()
end

function CardDetailModel:GetSkillModel(slot)
    return self.cardModel:GetSkillModel(slot)
end

function CardDetailModel:GetCardModel()
    return self.cardModel
end

function CardDetailModel:GetItemsMapModel()
    return self.itemsMapModel
end

function CardDetailModel:CanWearEquip(slot)
    return self.cardModel:CanWearEquip(slot)
end

function CardDetailModel:UpdateEquipWear(data)
    for slot, ret in pairs(data) do
        self.playerCardsMapModel:WearEquipForCard(self.cardModel:GetPcid(), ret.slot)
        self.equipsMapModel:ResetEquipNum(ret.eid, ret.num)
    end

    EventSystem.SendEvent("CardDetailModel_UpdateEquipWear")
end

function CardDetailModel:IsReachWearEquipCondition(slot)
    return self.cardModel:IsReachWearEquipCondition(slot)
end

function CardDetailModel:IsEquipToReachCardLevel(slot)
    local equipItemModel = self:GetEquipModel(slot)
    local isReach = false
    local needCardLevel = equipItemModel:GetNeedCardLevel()
    isReach = self.cardModel:GetLevel() >= needCardLevel
    return isReach, needCardLevel
end

function CardDetailModel:CanLevelUp()
    return self.cardModel:IsCanLevelUp()
end

function CardDetailModel:CanUpgrade()
    return self.cardModel:IsCanUpgrade()
end

function CardDetailModel:CanSkillLevelUp(slot)
    local skillItemModel = self:GetSkillModel(slot)
    if tonumber(self.cardModel:GetSkillPoint()) > 0
        and skillItemModel:IsOpen()
        and tonumber(skillItemModel:GetLevel()) < tonumber(skillItemModel:GetSkillMaxLevel()) then
        return true
    end
    return false
end

function CardDetailModel:UpdateSkillLevelUp(data)
    self.playerCardsMapModel:ResetCardSkillData(self.cardModel:GetPcid(), data.cost.curr_num, data.skills)

    EventSystem.SendEvent("CardDetailModel_UpdateSkillLevelUp")
end

function CardDetailModel:UpdateLevelUp(data)
    assert(tostring(data.pcid) == tostring(self.cardModel:GetPcid()))
    self.playerCardsMapModel:ResetCardLevelData(self.cardModel:GetPcid(), data.after.lvl, data.after.exp)
    self.itemsMapModel:ResetItemNum(data.cost.id, data.cost.num)

    EventSystem.SendEvent("CardDetailModel_AddExp")

    if data.after.lvl > data.before.lvl and data.isLevel then
        EventSystem.SendEvent("CardDetailModel_UpdateLevelUp")
    end
end

function CardDetailModel:ResetCardData(data)
    self.playerCardsMapModel:ResetCardData(data.pcid, data)

    EventSystem.SendEvent("CardDetailModel_ResetCardData")
end

-- 是否存在某个卡牌的数据
function CardDetailModel:IsExistCard(pcid)
    if self.cardModel:GetOwnershipType() == CardOwnershipType.SELF then
        return self.playerCardsMapModel:GetCardData(pcid) ~= nil
    else
        return true
    end
end

function CardDetailModel:ClearChemicalChooseTag()
    self.cardModel:SetChooseChemicalTab(nil)
end

-- 球员助阵的开关 强制 优先级最高
function CardDetailModel:SetSupporterCloseByConfig(isClose)
    self.supportCloseByConfig = isClose
end

-- 球员助阵的开关 强制 优先级最高
function CardDetailModel:IsSupporterCloseByConfig()
    return self.supportCloseByConfig or false
end

return CardDetailModel

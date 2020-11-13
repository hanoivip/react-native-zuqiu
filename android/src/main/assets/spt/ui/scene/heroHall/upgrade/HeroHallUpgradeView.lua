local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssetFinder = require("ui.common.AssetFinder")
local CurrencyImagePath = require("ui.scene.itemList.CurrencyImagePath")
local ImproveType = require("ui.models.heroHall.main.HeroHallImproveType")

local HeroHallUpgradeView = class(unity.base, "HeroHallUpgradeView")

function HeroHallUpgradeView:ctor()
    self.txtTitleLeft = self.___ex.txtTitleLeft
    self.imgIconLeft = self.___ex.imgIconLeft
    self.txtNameLeft = self.___ex.txtNameLeft
    self.attributeLeft = self.___ex.attributeLeft
    self.txtTitleRight = self.___ex.txtTitleRight
    self.imgIconRight = self.___ex.imgIconRight
    self.txtNameRight = self.___ex.txtNameRight
    self.attributeRight = self.___ex.attributeRight
    self.imgCostIcon = self.___ex.imgCostIcon
    self.txtCost = self.___ex.txtCost
    self.cost = self.___ex.cost
    self.costParent = self.___ex.costParent
    self.specialCondition = self.___ex.specialCondition
    self.btnUpgrade = self.___ex.btnUpgrade
    self.buttonUpgrade = self.___ex.buttonUpgrade
    self.close = self.___ex.close
    self.cardAreaLeft = self.___ex.cardAreaLeft
    self.cardAreaRight = self.___ex.cardAreaRight

    self.onClickBtnUpgrade = nil
    self.canMaterialUpgrade = false     -- 升级消耗材料是否满足条件
    self.materialNotEnoughList = {}     -- 升级材料不足时列表
    self.canSpecialUpgrade = false      -- 升级特殊条件是否满足
    self.material = {}                  -- 升级所需材料列表
    self.condition = {}                 -- 升级特殊条件列表
end

function HeroHallUpgradeView:start()
    DialogAnimation.Appear(self.transform)
    self:RegBtnEvent()
end

function HeroHallUpgradeView:InitView(heroHallUpgradeModel)
    self.model = heroHallUpgradeModel
    self:UpdateView()
end

function HeroHallUpgradeView:UpdateView()
    -- 左侧等级title
    self.txtTitleLeft.text = lang.trans("friends_manager_item_level", self.model:GetCurrLevel())
    -- 右侧等级title
    self.txtTitleRight.text = lang.trans("friends_manager_item_level", self.model:GetNextLevel())
    -- 左侧icon
    self.imgIconLeft.overrideSprite = AssetFinder.GetHeroHallIcon(self.model:GetCurrLevelIcon())
    -- 右侧icon
    self.imgIconRight.overrideSprite = AssetFinder.GetHeroHallIcon(self.model:GetNextLevelIcon())
    -- 左侧雕像名字
    self.txtNameLeft.text = self.model:GetCurrLevelStatueQualityDesc() .. lang.transstr("hero_hall_statue") .. " · " .. self.model:GetStatueCardName()
    -- 右侧雕像名字
    self.txtNameRight.text = self.model:GetNextLevelStatueQualityDesc() .. lang.transstr("hero_hall_statue") ..  " · " .. self.model:GetStatueCardName()

    local cardModel = self.model:GetCardModel()
    -- 左侧球员卡牌
    self:InitCardArea(self.cardAreaLeft, cardModel)
    -- 右侧球员卡牌
    self:InitCardArea(self.cardAreaRight, cardModel)

    -- 左侧属性面板
    for k, v in pairs(self.attributeLeft) do
        GameObjectHelper.FastSetActive(self.attributeLeft[k].gameObject, false)
    end
    local attributesLeft, basicAttributeLeft = self.model:GetCurrLevelAttributes()
    local hlvlLeft = self.model:GetCurrLevelSkillImprove()
    local hlvlConditionLeft = self.model:GetCurrLevelSkillImproveCondition()
    if table.nums(attributesLeft) == 10 then        -- 全属性
        GameObjectHelper.FastSetActive(self.attributeLeft["1"].gameObject, true)
        self.attributeLeft["1"].text = lang.transstr("hero_hall_main_all_attribute") .. ": " .. basicAttributeLeft
        if hlvlLeft > 0 then
            GameObjectHelper.FastSetActive(self.attributeLeft["2"].gameObject, true)
            self.attributeLeft["2"].text = lang.trans("hero_hall_skill_all_add_para", hlvlConditionLeft, hlvlLeft)
        end
    else
        local index = 1
        for attributeName, value in pairs(attributesLeft) do
            GameObjectHelper.FastSetActive(self.attributeLeft[tostring(index)].gameObject, true)
            self.attributeLeft[tostring(index)].text = lang.transstr(attributeName) .. ": " .. value
            index = index + 1
        end
        if hlvlLeft > 0 then
            GameObjectHelper.FastSetActive(self.attributeLeft[tostring(index)].gameObject, true)
            self.attributeLeft[tostring(index)].text = lang.trans("hero_hall_skill_all_add_para", hlvlConditionLeft, hlvlLeft)
        end
    end
    -- 右侧属性面板
    for k, v in pairs(self.attributeRight) do
        GameObjectHelper.FastSetActive(self.attributeRight[k].gameObject, false)
    end
    local attributesRight, basicAttributeRight = self.model:GetNextLevelAttributes()
    local hlvlRight = self.model:GetNextLevelSkillImprove()
    local hlvlConditionRight = self.model:GetNextLevelSkillImproveCondition()
    if table.nums(attributesRight) == 10 then
        GameObjectHelper.FastSetActive(self.attributeRight["1"].gameObject, true)
        self.attributeRight["1"].text = lang.transstr("hero_hall_main_all_attribute") .. ": " .. basicAttributeLeft .. " <color=#86BE0E>+" .. basicAttributeRight - basicAttributeLeft .. "</color>"
        if hlvlRight > 0 then
            GameObjectHelper.FastSetActive(self.attributeRight["2"].gameObject, true)
            self.attributeRight["2"].text = lang.trans("hero_hall_skill_all_add_para", hlvlConditionRight, hlvlRight)
        end
    else
        local index = 1
        for attributeName, value in pairs(attributesRight) do
            GameObjectHelper.FastSetActive(self.attributeRight[tostring(index)].gameObject, true)
            self.attributeRight[tostring(index)].text = lang.transstr(attributeName) .. ": " .. basicAttributeLeft .. " <color=#86BE0E>+" .. basicAttributeRight - basicAttributeLeft .. "</color>"
            index = index + 1
        end
        if hlvlRight > 0 then
            GameObjectHelper.FastSetActive(self.attributeRight[tostring(index)].gameObject, true)
            self.attributeRight[tostring(index)].text = lang.trans("hero_hall_skill_all_add_para", hlvlConditionRight, hlvlRight)
        end
    end

    -- 升级按钮
    self.canMaterialUpgrade, self.materialNotEnoughList = self.model:CanMaterialUpgrade()
    self.canSpecialUpgrade, self.condition = self.model:CanSpecialUpgrade()
    self.buttonUpgrade.interactable = self.canSpecialUpgrade

    -- 消耗材料
    if self.canSpecialUpgrade then
        GameObjectHelper.FastSetActive(self.costParent, true)
        GameObjectHelper.FastSetActive(self.specialCondition.gameObject, false)
        for k, v in pairs(self.cost) do
            GameObjectHelper.FastSetActive(v, false)
        end
        self.material = self.model:GetUpgradeMaterial()
        local index = 1
        for k, v in pairs(self.material) do
            if v > 0 then
                GameObjectHelper.FastSetActive(self.cost[tostring(index)], true)
                self.imgCostIcon[tostring(index)].overrideSprite = self:GetMaterialIcon(k)
                self.txtCost[tostring(index)].text = string.formatNumWithUnit(v)
                index = index + 1
            end
        end
    else
        GameObjectHelper.FastSetActive(self.costParent, false)
        GameObjectHelper.FastSetActive(self.specialCondition.gameObject, true)
        local conditionDesc = ""
        local cardName = self.model:GetCardModel():GetName()
        for k, v in pairs(self.condition) do
            if k == ImproveType.quality.improveType then-- 品质要求
                conditionDesc = lang.transstr("hero_hall_upgrade_quality_condition", cardName, CardHelper.GetQualitySign(v))
            elseif k == ImproveType.upgrade.improveType then-- 进阶要求
                conditionDesc = lang.transstr("hero_hall_upgrade_upgrade_condition", cardName, v)
            elseif k == ImproveType.ascend.improveType then-- 转生要求
                conditionDesc = lang.transstr("hero_hall_upgrade_ascend_condition", cardName, v)
            elseif k == ImproveType.TrainingBase.improveType then-- 特训要求
                conditionDesc = lang.transstr("hero_hall_upgrade_TrainingBase_condition", cardName, v)
            else
                conditionDesc = ""
                dump("illegal upgrade condition")
            end
        end
        self.specialCondition.text = conditionDesc
    end
end

-- 初始化球员卡牌
function HeroHallUpgradeView:InitCardArea(cardArea, cardModel)
    res.ClearChildren(cardArea.transform)
    local cardObject, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
    cardObject.transform:SetParent(cardArea.transform, false)
    spt:InitView(cardModel)
    spt:IsShowName(false)
end

-- 升级雕像后更新
function HeroHallUpgradeView:UpdateAfterUpgrade(heroHallUpgradeModel)
    self:InitView(heroHallUpgradeModel)
end

function HeroHallUpgradeView:GetMaterialIcon(materialType)
    return res.LoadRes(CurrencyImagePath[materialType])
end

function HeroHallUpgradeView:RegBtnEvent()
    self.btnUpgrade:regOnButtonClick(function()
        if self.onClickBtnUpgrade then
            self.onClickBtnUpgrade(self.canMaterialUpgrade, self.canSpecialUpgrade, self.material, self.materialNotEnoughList)
        end
    end)

    self.close:regOnButtonClick(function()
        self:CloseDialog()
    end)
end

function HeroHallUpgradeView:CloseDialog()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)
end

return HeroHallUpgradeView
local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local SkillType = require("ui.common.enum.SkillType")

local CardSkillItemView = class(unity.base)

function CardSkillItemView:ctor()
    self.skill = self.___ex.skill
    self.skillName = self.___ex.skillName
    self.mask = self.___ex.mask
    self.upgradeTip = self.___ex.upgradeTip
    self.level = self.___ex.level
    self.levelObj = self.___ex.levelObj
    self.notActive = self.___ex.notActive
    self.active = self.___ex.active
end

function CardSkillItemView:InitView(skillItemModel, cardDetailModel)
    self.skillName.text = skillItemModel:GetName()
    self.skill.overrideSprite = AssetFinder.GetSkillIcon(skillItemModel:GetIconIndex())
    local isOpen = skillItemModel:IsOpen()
    GameObjectHelper.FastSetActive(self.mask, not isOpen)
    self.skill.color = isOpen and Color(1, 1, 1, 1) or Color(0, 1, 1, 0.8)
    local slot = skillItemModel:GetSlot()
    if isOpen then
        local skillLvl = skillItemModel:GetSkillTotalLevel()
        self.level.text = "Lv." .. tostring(skillLvl)
    else
        self.upgradeTip.text = lang.trans("need_upgrade_open", slot)
    end
    GameObjectHelper.FastSetActive(self.levelObj, isOpen)

    local isActive = false
    local isNeedTrainingChemical = false
    local isChemical = skillItemModel:IsChemicalSkill()
    local isTraining = skillItemModel:IsTrainingSkill()
    local cardId1, cardId2 = skillItemModel:GetChemicalSkillCoupleID()
    if isTraining then
        local skillType = skillItemModel:GetSkillType()
        if skillType == SkillType.ATTRIBUTE then
            -- 直接计算属性
            isNeedTrainingChemical = true
            isChemical = true
            isActive = true
        elseif skillType == SkillType.CHEMICAL then
            -- 需要最佳拍档在场
            isNeedTrainingChemical = false
            isChemical = true
            isActive = false
            cardId1, cardId2 = skillItemModel:GetTrainingChemicalSkillCoupleID()
        end
    end
    if isChemical and not isNeedTrainingChemical then
        isActive = cardDetailModel:GetCardModel():IsChemicalSkillValid(cardId1, cardId2)
        isShowChemicalSign = isActive
    end

    GameObjectHelper.FastSetActive(self.active.gameObject, isOpen and isChemical and isActive)
    GameObjectHelper.FastSetActive(self.notActive.gameObject, isOpen and isChemical and not isActive)
end

return CardSkillItemView
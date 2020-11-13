local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Upgrade = require("data.Upgrade")
local AssetFinder = require("ui.common.AssetFinder")
local CardQuality = require("data.CardQuality")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local UpgradeBoxPopView = class(unity.base)

function UpgradeBoxPopView:ctor()
    self.oldLimitValue = self.___ex.oldLimitValue
    self.newLimitValue = self.___ex.newLimitValue
    self.skillIcon = self.___ex.skillIcon
    self.skillName = self.___ex.skillName
    self.oldSkillNum = self.___ex.oldSkillNum
    self.newSkillNum = self.___ex.newSkillNum
    self.confirm = self.___ex.confirm
    self.skillInfoArea = self.___ex.skillInfoArea
    self.skillIconArea = self.___ex.skillIconArea
    self.functionArea = self.___ex.functionArea
    self.functionText = self.___ex.functionText
    self.verticalLayout = self.___ex.verticalLayout
    self.skillTitleSign = self.___ex.skillTitleSign
    self.ballTitleSign = self.___ex.ballTitleSign
end 

function UpgradeBoxPopView:start()
    DialogAnimation.Appear(self.transform)
    self.confirm:regOnButtonClick(function()
        self:OnBtnConfirm()
    end)
end

function UpgradeBoxPopView:OnBtnConfirm()
    if self.clickConfirm then 
        self.clickConfirm()
    end
end

function UpgradeBoxPopView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

local function GetMaxSkillNum(upgrade, quality, ascend)
    local skillMaxLvl = 0
    local cardMaxLvl = 0
    local slot = -1
    local skillStaticData = Upgrade[tostring(upgrade)]
    if skillStaticData then 
        cardMaxLvl = skillStaticData.cardMaxLvl
        skillMaxLvl = skillStaticData.skillMaxLvl
        slot = skillStaticData.skillUnlock

        local cardQualityTable = CardQuality[tostring(quality)]
        skillMaxLvl = skillMaxLvl + ascend * cardQualityTable.ascendSkillLvl
    end
    return cardMaxLvl, skillMaxLvl, slot
end

function UpgradeBoxPopView:InitView(cardModel, upgrade)
    local skillModelMap = cardModel:GetSkillsMap()
    local currentMaxCardLvl = cardModel:GetLevelLimit()
    local quality = cardModel:GetCardQuality()
    local ascend = cardModel:GetAscend()
    local preMaxCardLvl, oldMaxSkillNum, oldSlot = GetMaxSkillNum(upgrade - 1, quality, ascend)
    local baseMaxCardLvl, newMaxSkillNum, slot = GetMaxSkillNum(upgrade, quality, ascend)
    self.oldLimitValue.text = tostring(baseMaxCardLvl)
    self.newLimitValue.text = tostring(currentMaxCardLvl)
    local skillAdd = " +" .. (newMaxSkillNum - oldMaxSkillNum)
    self.oldSkillNum.text = tostring(oldMaxSkillNum)
    self.newSkillNum.text = tostring(newMaxSkillNum)
    local currentSkillModel = skillModelMap[slot]
    local hasSkill = false
    local function PopWithoutNewSkill()
        self.skillIcon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/SkillIcon/Skill_Default.png")
        self.verticalLayout.padding.top = 80
    end
    if currentSkillModel and oldSlot ~= slot then -- 在技能全部开启后还可以进阶，但是显示会不一样
        if currentSkillModel.cacheData.ptid then
            PopWithoutNewSkill()
        else
            self.skillName.text = currentSkillModel:GetName()
            self.skillIcon.overrideSprite = AssetFinder.GetSkillIcon(currentSkillModel:GetIconIndex())
            hasSkill = true
            self.verticalLayout.padding.top = 30
        end
    else
        PopWithoutNewSkill()
    end
    GameObjectHelper.FastSetActive(self.skillIconArea.gameObject, hasSkill)
    GameObjectHelper.FastSetActive(self.skillTitleSign.gameObject, hasSkill)
    GameObjectHelper.FastSetActive(self.ballTitleSign.gameObject, not hasSkill)

    local isOpenFunction = false
    if cardModel:IsCanTrain() and cardModel:GetUpgrade() == 3 then 
        isOpenFunction = true
        self.functionText.text = lang.trans("train_open")
    elseif cardModel:GetMaxAscendNum() > 0 and cardModel:GetUpgrade() == 4 then 
        isOpenFunction = true
        self.functionText.text = lang.trans("ascend_open")
    end
    GameObjectHelper.FastSetActive(self.functionArea.gameObject, isOpenFunction)
end

function UpgradeBoxPopView:onDestroy()
    -- 关闭进阶成功弹板
    GuideManager.Show(res.curSceneInfo.ctrl)
end

return UpgradeBoxPopView

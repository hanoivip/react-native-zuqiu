local AssetFinder = require("ui.common.AssetFinder")
local CardTrainingConstant = require("ui.scene.cardTraining.CardTrainingConstant")
local Skills = require("data.Skills")

local CardTrainingFinishTwoAttributeView = class(unity.base)

function CardTrainingFinishTwoAttributeView:ctor()
    self.attributeNameTxt = self.___ex.attributeNameTxt
    self.bgImg = self.___ex.bgImg
    self.plusTxt = self.___ex.plusTxt

    self.normalBgPath = "Assets/CapstonesRes/Game/UI/Scene/CardTraining/Images/Bg_4.png"
    self.selectedBgPath = "Assets/CapstonesRes/Game/UI/Scene/CardTraining/Images/Bg_3.png"
end

function CardTrainingFinishTwoAttributeView:start()
end

function CardTrainingFinishTwoAttributeView:InitView(data, isOn)
    if data.name == CardTrainingConstant.AllSkillLvlImprove then
        self.attributeNameTxt.text = lang.trans("card_training_rule_allSkill")
    else
        self.attributeNameTxt.text = Skills[data.name].skillName
    end
    self.plusTxt.text = "lv+" .. data.attributePlus

    if isOn then
        self.bgImg.overrideSprite = res.LoadRes(self.selectedBgPath)
    else
        self.bgImg.overrideSprite = res.LoadRes(self.normalBgPath)
    end
end

return CardTrainingFinishTwoAttributeView
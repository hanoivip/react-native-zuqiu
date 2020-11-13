local FeatureSkillEnum = require("ui.scene.cardDetail.feature.FeatureSkillEnum")
local CardFeatureAdditionModel = require("ui.models.cardDetail.feature.CardFeatureAdditionModel")
local CardFeatureCurrentAdditionModel = class(CardFeatureAdditionModel, "CardFeatureCurrentAdditionModel")

function CardFeatureCurrentAdditionModel:ctor()
	CardFeatureCurrentAdditionModel.super.ctor(self)
end

function CardFeatureCurrentAdditionModel:RefreshFeatureAddition(featureAdditionDetailModel)
	local grassConditionType = featureAdditionDetailModel:GetGrassCategory()
	local weatherConditionType = featureAdditionDetailModel:GetWeatherCategory()
	local teamConditionType = featureAdditionDetailModel:GetTeamCategory()
	local startersConditionType = featureAdditionDetailModel:GetStartersCategory()
	self:AllotAdditionContents(grassConditionType, weatherConditionType, teamConditionType, startersConditionType)
end

function CardFeatureCurrentAdditionModel:AllotAdditionContents(grassConditionType, weatherConditionType, teamConditionType, startersConditionType)
	self:ResetData()
	for i, v in pairs(self.featuresMap) do
		if v.conditionType == grassConditionType or
				v.conditionType == weatherConditionType or
				v.conditionType == teamConditionType or
				v.conditionType == startersConditionType then
			local playerTalentType = v.playerTalentType
			local playerTalentDetailSkill = v.playerTalentDetailSkill or {}
			local improvePlayerTalent = v.improvePlayerTalent or 0
			if playerTalentType == FeatureSkillEnum.PlayerTalentType.Skill then
				self:SetSkillAddition(playerTalentDetailSkill, improvePlayerTalent)
			elseif playerTalentType == FeatureSkillEnum.PlayerTalentType.Attr then
				self:SetAttrAddition(playerTalentDetailSkill, improvePlayerTalent)
			elseif playerTalentType == FeatureSkillEnum.PlayerTalentType.AttrPercent then
				self:SetPercentAddition(playerTalentDetailSkill, improvePlayerTalent)
			elseif playerTalentType == FeatureSkillEnum.PlayerTalentType.SkillSlot then
				self:SetSlotAddition(playerTalentDetailSkill, improvePlayerTalent)
			elseif playerTalentType == FeatureSkillEnum.PlayerTalentType.SkillWithOutPaster then
				self:SetSkillWithOutPasterAddition(improvePlayerTalent)
			elseif playerTalentType == FeatureSkillEnum.PlayerTalentType.SkillAll then
				self:SetSkillAllAddition(improvePlayerTalent)
			end
		end
	end
end

function CardFeatureCurrentAdditionModel:GetName()
	return lang.trans("current_addition")
end

function CardFeatureCurrentAdditionModel:HasIcon()
	return false
end

return CardFeatureCurrentAdditionModel

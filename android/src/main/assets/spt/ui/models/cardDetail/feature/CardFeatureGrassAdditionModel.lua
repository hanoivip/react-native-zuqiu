local CourtAssetFinder = require("ui.scene.court.CourtAssetFinder")
local FeatureSkillEnum = require("ui.scene.cardDetail.feature.FeatureSkillEnum")
local CardFeatureAdditionModel = require("ui.models.cardDetail.feature.CardFeatureAdditionModel")
local CardFeatureGrassAdditionModel = class(CardFeatureAdditionModel, "CardFeatureGrassAdditionModel")

function CardFeatureGrassAdditionModel:ctor()
	CardFeatureGrassAdditionModel.super.ctor(self)
end

function CardFeatureGrassAdditionModel:RefreshFeatureAddition(featureAdditionDetailModel)
	local grassConditionType = featureAdditionDetailModel:GetGrassCategory()
	self:SetConditionType(grassConditionType)
	CardFeatureGrassAdditionModel.super.RefreshFeatureAddition(self, grassConditionType)
end

function CardFeatureGrassAdditionModel:GetName()
	for i, v in ipairs(FeatureSkillEnum.GrassCategoryType) do
		if v.key == self.conditionType then 
			return lang.trans(v.label)
		end
	end
	return ""
end

function CardFeatureGrassAdditionModel:HasIcon()
	return true
end

function CardFeatureGrassAdditionModel:GetIcon()
	local grassConditionType = self:GetConditionType()
	return CourtAssetFinder.GetTechnologyIcon(grassConditionType)
end

return CardFeatureGrassAdditionModel

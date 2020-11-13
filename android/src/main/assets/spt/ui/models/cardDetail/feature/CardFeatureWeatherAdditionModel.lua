local CourtAssetFinder = require("ui.scene.court.CourtAssetFinder")
local FeatureSkillEnum = require("ui.scene.cardDetail.feature.FeatureSkillEnum")
local CardFeatureAdditionModel = require("ui.models.cardDetail.feature.CardFeatureAdditionModel")
local CardFeatureWeatherAdditionModel = class(CardFeatureAdditionModel, "CardFeatureWeatherAdditionModel")

function CardFeatureWeatherAdditionModel:ctor()
	CardFeatureWeatherAdditionModel.super.ctor(self)
end

function CardFeatureWeatherAdditionModel:RefreshFeatureAddition(featureAdditionDetailModel)
	local weatherConditionType = featureAdditionDetailModel:GetWeatherCategory()
	self:SetConditionType(weatherConditionType)
	CardFeatureWeatherAdditionModel.super.RefreshFeatureAddition(self, weatherConditionType)
end

function CardFeatureWeatherAdditionModel:GetName()
	for i, v in ipairs(FeatureSkillEnum.WeatherCategoryType) do
		if v.key == self.conditionType then 
			return lang.trans(v.label)
		end
	end
	return ""
end

function CardFeatureWeatherAdditionModel:HasIcon()
	return true
end

function CardFeatureWeatherAdditionModel:GetIcon()
	local weatherConditionType = self:GetConditionType()
	return CourtAssetFinder.GetTechnologyIcon(weatherConditionType)
end

return CardFeatureWeatherAdditionModel

local CourtBuildType = require("ui.scene.court.CourtBuildType")
local Model = require("ui.models.Model")
local FeatureSkillEnum = require("ui.scene.cardDetail.feature.FeatureSkillEnum")
local FeatureAdditionDetailModel = class(Model, "FeatureAdditionDetailModel")

function FeatureAdditionDetailModel:ctor()
	self.grassKey = CourtBuildType.GrassBuild
	self.weatherKey = CourtBuildType.SunShineBuild
	self.teamKey = FeatureSkillEnum.DefaultTeam
	self.startersKey = FeatureSkillEnum.DefaultStarters
end

function FeatureAdditionDetailModel:GetGrassCategory()
	return self.grassKey
end

function FeatureAdditionDetailModel:SetGrassCategory(grassKey)
	self.grassKey = grassKey
end

function FeatureAdditionDetailModel:GetWeatherCategory()
	return self.weatherKey
end

function FeatureAdditionDetailModel:SetWeatherCategory(weatherKey)
	self.weatherKey = weatherKey
end

function FeatureAdditionDetailModel:GetTeamCategory()
	return self.teamKey
end

function FeatureAdditionDetailModel:SetTeamCategory(teamKey)
	self.teamKey = teamKey
end

function FeatureAdditionDetailModel:GetStartersCategory()
	return self.startersKey
end

function FeatureAdditionDetailModel:SetStartersCategory(startersKey)
	self.startersKey = startersKey
end

function FeatureAdditionDetailModel:ChangeCategory(categoryType, changeKey)
	if categoryType == FeatureSkillEnum.CategoryType.Grass then 
		self:SetGrassCategory(changeKey)
	elseif categoryType == FeatureSkillEnum.CategoryType.Weather then 
		self:SetWeatherCategory(changeKey)
	elseif categoryType == FeatureSkillEnum.CategoryType.HomeAndAway then 
		self:SetTeamCategory(changeKey)
	end
	EventSystem.SendEvent("FeatureAddition_CategoryChange", categoryType, changeKey)
end

return FeatureAdditionDetailModel

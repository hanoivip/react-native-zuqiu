local Model = require("ui.models.Model")
local FeatureSkillEnum = require("ui.scene.cardDetail.feature.FeatureSkillEnum")
local FeatureChooseModel = class(Model, "FeatureChooseModel")

function FeatureChooseModel:ctor()
	self.qualityKey = nil
	self.buildKey = nil
	self.categoryKey = nil
	self.qualityIndex = 1
	self.buildIndex = 1
	self.categoryIndex = 1
end

function FeatureChooseModel:GetQualityKey()
	return self.qualityKey
end

function FeatureChooseModel:SetQualityKey(qualityKey)
	self.qualityKey = qualityKey
end

function FeatureChooseModel:GetBuildKey()
	return self.buildKey
end

function FeatureChooseModel:SetBuildKey(buildKey)
	self.buildKey = buildKey
end

function FeatureChooseModel:GetCategoryKey()
	return self.categoryKey
end

function FeatureChooseModel:SetCategoryKey(categoryKey)
	self.categoryKey = categoryKey
end

function FeatureChooseModel:GetQualityIndex()
	return self.qualityIndex
end

function FeatureChooseModel:GetBuildIndex()
	return self.buildIndex
end

function FeatureChooseModel:GetCategoryIndex()
	return self.categoryIndex
end

function FeatureChooseModel:ChangeBookCategory(categoryType, changeKey, groupIndex)
	if categoryType == FeatureSkillEnum.SortType.Quality then 
		self:SetQualityKey(changeKey)	
		self.qualityIndex = groupIndex
	elseif categoryType == FeatureSkillEnum.SortType.GrassAndWeather then 
		self:SetBuildKey(changeKey)
		self.buildIndex = groupIndex
	elseif categoryType == FeatureSkillEnum.SortType.Category then 
		self:SetCategoryKey(changeKey)
		self.categoryIndex = groupIndex
	end
	EventSystem.SendEvent("FeatureBookChoose_CategoryChange")
end

function FeatureChooseModel:QualityFilter(coachBookModelsMap)
	local filterModels = {}
	if self.qualityKey then 
		for i, model in ipairs(coachBookModelsMap) do
			local quality = model:GetSkillQuality()
			if tonumber(quality) == tonumber(self.qualityKey) then 
				table.insert(filterModels, model)
			end
		end
	else
		filterModels = coachBookModelsMap
	end
	return filterModels
end

function FeatureChooseModel:GrassAndWeatherFilter(coachBookModelsMap)
	local filterModels = {}
	if self.buildKey then 
		for i, model in ipairs(coachBookModelsMap) do
			local condition = model:GetSkillCondition()
			if tostring(condition) == tostring(self.buildKey) then 
				table.insert(filterModels, model)
			end
		end
	else
		filterModels = coachBookModelsMap
	end
	return filterModels
end

function FeatureChooseModel:CategoryFilter(coachBookModelsMap)
	local filterModels = {}
	if self.categoryKey then 
		for i, model in ipairs(coachBookModelsMap) do
			local playerTalentType = model:GetSkillTalentType()
			for m, v in ipairs(self.categoryKey) do
				if tonumber(playerTalentType) == tonumber(v) then 
					table.insert(filterModels, model)
				end
			end
		end
	else
		filterModels = coachBookModelsMap
	end
	return filterModels
end

function FeatureChooseModel:GetBookCategorySort(coachBookModelsMap)
	local filterModels = self:QualityFilter(coachBookModelsMap)
	filterModels = self:GrassAndWeatherFilter(filterModels)
	filterModels = self:CategoryFilter(filterModels)
	return filterModels
end

return FeatureChooseModel

local FeatureSkillEnum = require("ui.scene.cardDetail.feature.FeatureSkillEnum")
local CardFeatureAdditionModel = require("ui.models.cardDetail.feature.CardFeatureAdditionModel")
local CardFeatureTeamAdditionModel = class(CardFeatureAdditionModel, "CardFeatureTeamAdditionModel")

function CardFeatureTeamAdditionModel:ctor()
	CardFeatureTeamAdditionModel.super.ctor(self)
end

function CardFeatureTeamAdditionModel:RefreshFeatureAddition(featureAdditionDetailModel)
	local teamConditionType = featureAdditionDetailModel:GetTeamCategory()
	self:SetConditionType(teamConditionType)
	CardFeatureTeamAdditionModel.super.RefreshFeatureAddition(self, teamConditionType)
end

function CardFeatureTeamAdditionModel:GetName()
	for i, v in ipairs(FeatureSkillEnum.TeamCategoryType) do
		if v.key == self.conditionType then 
			return lang.trans(v.label)
		end
	end
	return ""
end

function CardFeatureTeamAdditionModel:HasIcon()
	return false
end

function CardFeatureTeamAdditionModel:GetIcon()

end

return CardFeatureTeamAdditionModel

local FeatureSkillEnum = require("ui.scene.cardDetail.feature.FeatureSkillEnum")
local CardFeatureAdditionModel = require("ui.models.cardDetail.feature.CardFeatureAdditionModel")
local CardFeatureStartersAdditionModel = class(CardFeatureAdditionModel, "CardFeatureStartersAdditionModel")

function CardFeatureStartersAdditionModel:ctor()
	CardFeatureStartersAdditionModel.super.ctor(self)
end

function CardFeatureStartersAdditionModel:RefreshFeatureAddition(featureAdditionDetailModel)
	local startersConditionType = featureAdditionDetailModel:GetStartersCategory()
	self:SetConditionType(startersConditionType)
	CardFeatureStartersAdditionModel.super.RefreshFeatureAddition(self, startersConditionType)
end

function CardFeatureStartersAdditionModel:GetName()
	return lang.trans("starter_players")
end

function CardFeatureStartersAdditionModel:HasIcon()
	return false
end

function CardFeatureStartersAdditionModel:GetIcon()

end

return CardFeatureStartersAdditionModel

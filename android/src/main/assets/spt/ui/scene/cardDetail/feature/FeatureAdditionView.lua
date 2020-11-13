local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Dropdown = UI.Dropdown
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local CardFeatureCurrentAdditionModel = require("ui.models.cardDetail.feature.CardFeatureCurrentAdditionModel")
local CardFeatureWeatherAdditionModel = require("ui.models.cardDetail.feature.CardFeatureWeatherAdditionModel")
local CardFeatureGrassAdditionModel = require("ui.models.cardDetail.feature.CardFeatureGrassAdditionModel")
local CardFeatureTeamAdditionModel = require("ui.models.cardDetail.feature.CardFeatureTeamAdditionModel")
local CardFeatureStartersAdditionModel = require("ui.models.cardDetail.feature.CardFeatureStartersAdditionModel")
local CardFeatureAdditionModel = require("ui.models.cardDetail.feature.CardFeatureAdditionModel")
local FeatureSkillEnum = require("ui.scene.cardDetail.feature.FeatureSkillEnum")
local FeatureAdditionView = class(unity.base)

function FeatureAdditionView:ctor()
    self.listScrollView = self.___ex.listScrollView
    self.btnClose = self.___ex.btnClose
    self.grassDrop = self.___ex.grassDrop
    self.weatherDrop = self.___ex.weatherDrop
    self.teamDrop = self.___ex.teamDrop
	self.grassLabel = self.___ex.grassLabel
	self.weatherLabel = self.___ex.weatherLabel
	self.teamLabel = self.___ex.teamLabel
	self.teamArrow = self.___ex.teamArrow
	self.weatherArrow = self.___ex.weatherArrow
	self.grassArrow = self.___ex.grassArrow

	self.grassShadowLabel = self.___ex.grassShadowLabel
	self.weatherShadowLabel = self.___ex.weatherShadowLabel
	self.teamShadowLabel = self.___ex.teamShadowLabel
end

function FeatureAdditionView:InitOptions(dropDown, categoryTypes, categoryType)
	dropDown.options:Clear()  --Lua assist checked flag
    for i, data in ipairs(categoryTypes) do
        local tempData = Dropdown.OptionData()
        tempData.text = lang.trans(data.label)
        if i % 2 == 1 then
            tempData.image = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Medal/Bytes/Medal_Filter_Box_Bg1.png")
        end
        dropDown.options:Add(tempData)
    end

    local ClickDropdown = function(index) -- index 从0
        local groupIndex = index + 1
		local data = categoryTypes[groupIndex]
		local key = data.key
        self.featureAdditionDetailModel:ChangeCategory(categoryType, key)
		self:SetLabelShadow()
    end
    dropDown.onValueChanged:AddListener(ClickDropdown)
end

function FeatureAdditionView:GetIndex(categoryTypes, categoryType)
	for i = 1, #categoryTypes do
		if categoryTypes[i].key == categoryType then
			return i - 1
		end
	end
	return 0
end

function FeatureAdditionView:start()
    self:InitOptions(self.grassDrop, FeatureSkillEnum.GrassCategoryType, FeatureSkillEnum.CategoryType.Grass)
	self:InitOptions(self.weatherDrop, FeatureSkillEnum.WeatherCategoryType, FeatureSkillEnum.CategoryType.Weather)
	self:InitOptions(self.teamDrop, FeatureSkillEnum.TeamCategoryType, FeatureSkillEnum.CategoryType.HomeAndAway)

	DialogAnimation.Appear(self.transform)

    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
end

function FeatureAdditionView:InitView(cardModel, featureAdditionDetailModel)
	self.featureAdditionDetailModel = featureAdditionDetailModel
	local additionModelsMap = {}
	local featureSkills = cardModel:GetCoachFeature()
	local categoryType
	local cardFeatureAdditionModel = CardFeatureCurrentAdditionModel.new()
	cardFeatureAdditionModel:InitFeatureSkills(featureSkills)
	cardFeatureAdditionModel:SetAdditionType(FeatureSkillEnum.CategoryType.CurrentAll)
	table.insert(additionModelsMap, cardFeatureAdditionModel)

	categoryType = self.featureAdditionDetailModel:GetGrassCategory()
	cardFeatureAdditionModel = CardFeatureGrassAdditionModel.new()
	cardFeatureAdditionModel:InitFeatureSkills(featureSkills)
	cardFeatureAdditionModel:SetAdditionType(FeatureSkillEnum.CategoryType.Grass)
	cardFeatureAdditionModel:SetConditionType(categoryType)
	table.insert(additionModelsMap, cardFeatureAdditionModel)
	self.grassDrop.captionText.text = cardFeatureAdditionModel:GetName()
	self.grassDrop.value = self:GetIndex(FeatureSkillEnum.GrassCategoryType, categoryType)

	categoryType = self.featureAdditionDetailModel:GetWeatherCategory()
	cardFeatureAdditionModel = CardFeatureWeatherAdditionModel.new()
	cardFeatureAdditionModel:InitFeatureSkills(featureSkills)
	cardFeatureAdditionModel:SetAdditionType(FeatureSkillEnum.CategoryType.Weather)
	cardFeatureAdditionModel:SetConditionType(categoryType)
	table.insert(additionModelsMap, cardFeatureAdditionModel)
	self.weatherDrop.captionText.text = cardFeatureAdditionModel:GetName()
	self.weatherDrop.value = self:GetIndex(FeatureSkillEnum.WeatherCategoryType, categoryType)

	categoryType = self.featureAdditionDetailModel:GetTeamCategory()
	cardFeatureAdditionModel = CardFeatureTeamAdditionModel.new()
	cardFeatureAdditionModel:InitFeatureSkills(featureSkills)
	cardFeatureAdditionModel:SetAdditionType(FeatureSkillEnum.CategoryType.HomeAndAway)
	cardFeatureAdditionModel:SetConditionType(categoryType)
	table.insert(additionModelsMap, cardFeatureAdditionModel)
	self.teamDrop.captionText.text = cardFeatureAdditionModel:GetName()
	self.teamDrop.value = self:GetIndex(FeatureSkillEnum.TeamCategoryType, categoryType)

	cardFeatureAdditionModel = CardFeatureStartersAdditionModel.new()
	cardFeatureAdditionModel:InitFeatureSkills(featureSkills)
	cardFeatureAdditionModel:SetAdditionType(FeatureSkillEnum.CategoryType.Starters)
	cardFeatureAdditionModel:SetConditionType(self.featureAdditionDetailModel:GetStartersCategory())
	table.insert(additionModelsMap, cardFeatureAdditionModel)

	self.listScrollView:InitView(cardModel, featureAdditionDetailModel, additionModelsMap)
end

function FeatureAdditionView:SetLabelShadow()
	self.grassShadowLabel.text = self.grassLabel.text
	self.weatherShadowLabel.text = self.weatherLabel.text
	self.teamShadowLabel.text = self.teamLabel.text
end

function FeatureAdditionView:OnEnterScene()

end

function FeatureAdditionView:OnExitScene()

end

function FeatureAdditionView:Close()
    DialogAnimation.Disappear(self.transform, nil, self.closeDialog)
end

return FeatureAdditionView

local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local UI = UnityEngine.UI
local Dropdown = UI.Dropdown
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CoachItemType = require("ui.models.coach.common.CoachItemType")
local FeatureSkillEnum = require("ui.scene.cardDetail.feature.FeatureSkillEnum")
local FeatureManualPageView = class(unity.base)

function FeatureManualPageView:ctor()
	self.infoBarDynParent = self.___ex.infoBarDynParent
    self.listScrollView = self.___ex.listScrollView
	self.scrollRect = self.___ex.scrollRect
	self.animator = self.___ex.animator
    self.qualityDrop = self.___ex.qualityDrop
    self.funcDrop = self.___ex.funcDrop
    self.categoryDrop = self.___ex.categoryDrop
    self.qualityLabel = self.___ex.qualityLabel
    self.funcLabel = self.___ex.funcLabel
    self.categoryLabel = self.___ex.categoryLabel
	self.contentRect = self.___ex.contentRect

    self.qualityShadowLabel = self.___ex.qualityShadowLabel
    self.funcShadowLabel = self.___ex.funcShadowLabel
    self.categoryShadowLabel = self.___ex.categoryShadowLabel

    self.itemMap = {}
end

function FeatureManualPageView:GetItemRes()
    if not self.itemRes then
        self.itemRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/Feature/FeatureItemFrame.prefab")
    end
    return self.itemRes
end

function FeatureManualPageView:start()
	self.listScrollView:regOnCreateItem(function(scrollSelf, index) 
		local obj = Object.Instantiate(self:GetItemRes())
		local spt = res.GetLuaScript(obj)
		scrollSelf:resetItem(spt, index)
		return obj
	end)

	self.listScrollView:regOnResetItem(function(scrollSelf, spt, index) 
		local itemModel = scrollSelf.itemDatas[index]
		spt:InitView(itemModel)
	end)

    self:InitOptions(self.qualityDrop, FeatureSkillEnum.QualitySortType, FeatureSkillEnum.SortType.Quality)
	self:InitOptions(self.funcDrop, FeatureSkillEnum.KindSortType, FeatureSkillEnum.SortType.GrassAndWeather)
	self:InitOptions(self.categoryDrop, FeatureSkillEnum.CategorySortType, FeatureSkillEnum.SortType.Category)
end

function FeatureManualPageView:InitOptions(dropDown, categoryTypes, categoryType)
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
        self.featureChooseModel:ChangeBookCategory(categoryType, key, groupIndex)
    end
    dropDown.onValueChanged:AddListener(ClickDropdown)
end

function FeatureManualPageView:InitView(FeatureManualModelsMap, featureChooseModel)
	self.featureManualModelsMap = FeatureManualModelsMap
	self.featureChooseModel = featureChooseModel

	local qualityIndex = featureChooseModel:GetQualityIndex()
	local buildIndex = featureChooseModel:GetBuildIndex()
	local categoryIndex = featureChooseModel:GetCategoryIndex()
	self.qualityDrop.value = qualityIndex - 1
	self.funcDrop.value = buildIndex - 1
	self.categoryDrop.value = categoryIndex - 1

	local qualityLabel = FeatureSkillEnum.QualitySortType[qualityIndex] and FeatureSkillEnum.QualitySortType[qualityIndex].label or "feature_itemList_quality"
	local funcLabel = FeatureSkillEnum.KindSortType[buildIndex] and FeatureSkillEnum.KindSortType[buildIndex].label or "feature_itemList_kind"
	local categoryLabel = FeatureSkillEnum.CategorySortType[categoryIndex] and FeatureSkillEnum.CategorySortType[categoryIndex].label or "feature_itemList_type"
	self.qualityLabel.text = lang.trans(qualityLabel)
	self.funcLabel.text = lang.trans(funcLabel)
	self.categoryLabel.text = lang.trans(categoryLabel)
	self:SetLabelShadow()
	local coachItemArray = self.featureChooseModel:GetBookCategorySort(self.featureManualModelsMap)
	self.listScrollView:refresh(coachItemArray)
end

function FeatureManualPageView:EventFeatureBookCategoryChange()
	local filterModels = self.featureChooseModel:GetBookCategorySort(self.featureManualModelsMap)
	self.listScrollView:refresh(filterModels)
	self:SetLabelShadow()
end

function FeatureManualPageView:SetLabelShadow()
	self.qualityShadowLabel.text = self.qualityLabel.text
	self.funcShadowLabel.text = self.funcLabel.text
	self.categoryShadowLabel.text = self.categoryLabel.text
end

function FeatureManualPageView:OnEnterScene()
	EventSystem.AddEvent("FeatureBookChoose_CategoryChange", self, self.EventFeatureBookCategoryChange)
end

function FeatureManualPageView:OnExitScene()
	EventSystem.RemoveEvent("FeatureBookChoose_CategoryChange", self, self.EventFeatureBookCategoryChange)
end

function FeatureManualPageView:OnDestroy()
    self.itemRes = nil
end

function FeatureManualPageView:PlayLeaveAnimation()
    self.animator:Play("EffectPlayerListLeave")
end

function FeatureManualPageView:RegOnInfoBarDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

return FeatureManualPageView

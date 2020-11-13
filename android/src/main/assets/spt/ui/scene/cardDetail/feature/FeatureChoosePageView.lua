local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local UI = UnityEngine.UI
local Dropdown = UI.Dropdown
local Vector2 = UnityEngine.Vector2
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CoachItemType = require("ui.models.coach.common.CoachItemType")
local FeatureSkillEnum = require("ui.scene.cardDetail.feature.FeatureSkillEnum")
local FeatureChoosePageView = class(unity.base)

function FeatureChoosePageView:ctor()
    self.listScrollView = self.___ex.listScrollView
    self.infoBoard = self.___ex.infoBoard
    self.btnEquip = self.___ex.btnEquip
    self.btnClose = self.___ex.btnClose
    self.itemType = self.___ex.itemType
    self.itemArea = self.___ex.itemArea
    self.itemName = self.___ex.itemName
    self.desc = self.___ex.desc
    self.labelText = self.___ex.labelText
    self.qualityDrop = self.___ex.qualityDrop
    self.funcDrop = self.___ex.funcDrop
    self.categoryDrop = self.___ex.categoryDrop
    self.qualityLabel = self.___ex.qualityLabel
    self.funcLabel = self.___ex.funcLabel
    self.categoryLabel = self.___ex.categoryLabel
-- 标签倒影
    self.qualityShadowLabel = self.___ex.qualityShadowLabel
    self.funcShadowLabel = self.___ex.funcShadowLabel
    self.categoryShadowLabel = self.___ex.categoryShadowLabel

	self.bookFilterBoard = self.___ex.bookFilterBoard
	self.contentRect = self.___ex.contentRect
	self.title = self.___ex.title
    self.itemMap = {}
    self.selectItemIndex = nil
end

function FeatureChoosePageView:GetItemRes()
    if not self.itemRes then
        self.itemRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/Feature/ChooseItem.prefab")
    end
    return self.itemRes
end

-- 实例化对象资源
function FeatureChoosePageView:GetInstantiateObjectPath()
	if not self.objectRes then 
		local path = self.coachItemMapModel:GetItemBoxPrefabPathByType(self.coachItemType)
		self.objectRes = res.LoadRes(path)
	end
	return self.objectRes
end

function FeatureChoosePageView:start()
	self.listScrollView:regOnCreateItem(function(scrollSelf, index) 
		local obj = Object.Instantiate(self:GetItemRes())
		local spt = res.GetLuaScript(obj)
		scrollSelf:resetItem(spt, index)
		return obj
	end)

	self.listScrollView:regOnResetItem(function(scrollSelf, spt, index) 
		local objectRes = self:GetInstantiateObjectPath()
		local itemModel = scrollSelf.itemDatas[index]
		spt:InitView(self.coachItemMapModel, itemModel, index, self.selectItemIndex, objectRes)
		spt.clickItem = function() self:OnClickItem(itemModel, index) end
		self:UpdateItemIndex(spt, index)
	end)

    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
    self.btnEquip:regOnButtonClick(function()
        self:OnClickEquip()
    end)

    DialogAnimation.Appear(self.transform)

	self.qualityLabel.text = lang.trans("feature_itemList_quality")
	self.funcLabel.text = lang.trans("feature_itemList_kind")
	self.categoryLabel.text = lang.trans("feature_itemList_type")
    self:InitOptions(self.qualityDrop, FeatureSkillEnum.QualitySortType, FeatureSkillEnum.SortType.Quality)
	self:InitOptions(self.funcDrop, FeatureSkillEnum.KindSortType, FeatureSkillEnum.SortType.GrassAndWeather)
	self:InitOptions(self.categoryDrop, FeatureSkillEnum.CategorySortType, FeatureSkillEnum.SortType.Category)
end

function FeatureChoosePageView:InitOptions(dropDown, categoryTypes, categoryType)
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
        self.featureChooseModel:ChangeBookCategory(categoryType, key)
        self:SetLabelShadow()
    end
    dropDown.onValueChanged:AddListener(ClickDropdown)
end

function FeatureChoosePageView:UpdateItemIndex(spt, index)
    spt:UpdateItemIndex(index)
    self.itemMap[tostring(index)] = spt
end

function FeatureChoosePageView:OnClickItem(itemModel, index)
    if self.selectItemIndex == index then
        return 
    end
    local preItemItem = self.itemMap[tostring(self.selectItemIndex)]
    if preItemItem then
        preItemItem:IsSelect(false)
    end
    local currentItemItem = self.itemMap[tostring(index)]
    if currentItemItem then
        currentItemItem:IsSelect(true)
    end
    self.selectItemIndex = index
    self:OnClickItemInfo(itemModel)
end

function FeatureChoosePageView:OnClickEquip()
    if self.clickEquip then 
        self.clickEquip(self.itemModel, self.itemSelectModel)
    end
end

-- 特性道具
function FeatureChoosePageView:GetFeatureItemModels()
	local itemModels = {}
	local modelMaps = self.coachItemMapModel:GetAllPlayerTalentFuncItemModels() or {}
    for id, itemModel in pairs(modelMaps) do
        table.insert(itemModels, itemModel)
    end
	return itemModels
end

-- 特性技能书
function FeatureChoosePageView:GetFeatureBookModels()
	local itemModels = {}
	local modelMaps = self.coachItemMapModel:GetAllPlayerTalentSkillBookModels() or {}
    for id, itemModel in pairs(modelMaps) do
        table.insert(itemModels, itemModel)
    end
	return itemModels
end

local BookSizeH = 446.6
local ItemSizeH = 507.7
function FeatureChoosePageView:InitView(coachItemType, itemSelectModel, coachItemMapModel, featureChooseModel)
    GameObjectHelper.FastSetActive(self.infoBoard, false)
	self.coachItemMapModel = coachItemMapModel
	self.coachItemType = coachItemType
	self.itemSelectModel = itemSelectModel
	self.featureChooseModel = featureChooseModel
    if itemSelectModel then
        self:OnClickItemInfo(itemSelectModel)
    end

	local coachItemArray = {}
	if coachItemType == CoachItemType.PlayerTalentSkillBook then 
		self.contentRect.sizeDelta = Vector2(self.contentRect.sizeDelta.x, BookSizeH)
		self.title.text = lang.trans("choose_feature")
		GameObjectHelper.FastSetActive(self.bookFilterBoard, true)		

		coachItemArray = self:GetFeatureBookModels()
		coachItemArray = self.featureChooseModel:GetBookCategorySort(coachItemArray)
	elseif coachItemType == CoachItemType.PlayerTalentFunctionalityItem then 
		self.contentRect.sizeDelta = Vector2(self.contentRect.sizeDelta.x, ItemSizeH)
		self.title.text = lang.trans("choose_item")
		GameObjectHelper.FastSetActive(self.bookFilterBoard, false)

		coachItemArray = self:GetFeatureItemModels()
	end

	self.listScrollView:refresh(coachItemArray)
end

-- 展示选择道具（书）信息
function FeatureChoosePageView:OnClickItemInfo(itemModel)
	self.itemModel = itemModel
	GameObjectHelper.FastSetActive(self.infoBoard, true)

	if not self.objectLuaSpt then 
		local objectRes = self:GetInstantiateObjectPath()
		local obj = Object.Instantiate(objectRes)
		obj.transform:SetParent(self.itemArea, false)
		local spt = res.GetLuaScript(obj)
		self.objectLuaSpt = spt
	end
	self.objectLuaSpt:InitView(itemModel)

	self.itemName.text = itemModel:GetName()
	self.desc.text = itemModel:GetDesc()

	local itemChoosetype = self:GetButtonState(itemModel, self.itemSelectModel)
	local lableText = (itemChoosetype == CoachItemType.ItemChooseType.Unload and lang.trans("unload"))
					or (itemChoosetype == CoachItemType.ItemChooseType.Replace and lang.trans("replace"))
					or (itemChoosetype == CoachItemType.ItemChooseType.Equip and lang.trans("use"))
					or ""
	self.labelText.text = lableText
end

function FeatureChoosePageView:GetButtonState(itemModel, itemSelectModel)
	local id = itemModel:GetId()
	if itemSelectModel then 
		selectId = itemSelectModel:GetId()
		if id == selectId then 
			return CoachItemType.ItemChooseType.Unload
		else	
			return CoachItemType.ItemChooseType.Replace
		end
	else	
		return CoachItemType.ItemChooseType.Equip
	end
end

function FeatureChoosePageView:Close()
    DialogAnimation.Disappear(self.transform, nil, self.closeDialog)
end

function FeatureChoosePageView:EventFeatureBookCategoryChange()
	local coachItemArray = self:GetFeatureBookModels()
	local filterModels = self.featureChooseModel:GetBookCategorySort(coachItemArray)
	self.listScrollView:refresh(filterModels)
	GameObjectHelper.FastSetActive(self.infoBoard, false)
    local preItemItem = self.itemMap[tostring(self.selectItemIndex)]
    if preItemItem then
        preItemItem:IsSelect(false)
    end
	self.selectItemIndex = nil
end

-- 更新标签倒影
function FeatureChoosePageView:SetLabelShadow()
	self.qualityShadowLabel.text = self.qualityLabel.text
	self.funcShadowLabel.text = self.funcLabel.text
	self.categoryShadowLabel.text = self.categoryLabel.text
end

function FeatureChoosePageView:OnEnterScene()
	EventSystem.AddEvent("FeatureBookChoose_CategoryChange", self, self.EventFeatureBookCategoryChange)
end

function FeatureChoosePageView:OnExitScene()
	EventSystem.RemoveEvent("FeatureBookChoose_CategoryChange", self, self.EventFeatureBookCategoryChange)
end

function FeatureChoosePageView:OnDestroy()
    self.itemRes = nil
	self.objectRes = nil
end

return FeatureChoosePageView

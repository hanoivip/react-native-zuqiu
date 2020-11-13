local FeatureSkillEnum = require("ui.scene.cardDetail.feature.FeatureSkillEnum")
local SkillItemModel = require("ui.models.common.SkillItemModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local FeatureAdditionBarView = class(unity.base)

function FeatureAdditionBarView:ctor()
    self.nameTxt = self.___ex.name
    self.icon = self.___ex.icon
    self.attr = self.___ex.attr
	self.iconBg = self.___ex.iconBg
	self.scrollView = self.___ex.scrollView
	
	self:RefreshSkillAddition()
	EventSystem.AddEvent("FeatureAddition_CategoryChange", self, self.EventCategoryChange)
end

function FeatureAdditionBarView:InitView(cardModel, featureAdditionDetailModel, additionModel)
	self.cardModel = cardModel
	self.featureAdditionDetailModel = featureAdditionDetailModel
	self.additionModel = additionModel
	self:RefreshAddition()
end

function FeatureAdditionBarView:RefreshSkillAddition()
    self.scrollView:regOnCreateItem(function (scrollSelf, index)
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/Feature/CardSkillAddition.prefab"
        local obj, spt = res.Instantiate(prefab)
        scrollSelf:resetItem(spt, index)
        return obj
    end)

    self.scrollView:regOnResetItem(function (scrollSelf, spt, index)
        local data = scrollSelf.itemDatas[index]
        spt:InitView(data)
        scrollSelf:updateItemIndex(spt, index)
    end)
end

function FeatureAdditionBarView:RefreshAddition()
	self.additionModel:RefreshFeatureAddition(self.featureAdditionDetailModel)
	local hasIcon = self.additionModel:HasIcon()
	GameObjectHelper.FastSetActive(self.iconBg.gameObject, hasIcon)

	if hasIcon then 
		local iconRes = self.additionModel:GetIcon()
		self.icon.overrideSprite = iconRes
	end

	local skillsMap = self.additionModel:GetSkillMap()
	local attrsMap = self.additionModel:GetAttrMap()
	local percentsMap = self.additionModel:GePercentMap()
	local skillSlotsMap = self.additionModel:GetSlotMap()
	local skillsWithoutPasterAdd = self.additionModel:GetSkillsWithoutPasterLevel()
	local skillsAllAdd = self.additionModel:GetSkillsAllLevel()
	local attrList = self.cardModel:GetAttrNameList()

	for i, name in ipairs(attrList) do
		local attr = attrsMap[tostring(name)] or 0
		local percent = percentsMap[tostring(name)] or 0
		self.attr["s" .. i]:InitView(name, attr, percent)
	end
	self.nameTxt.text = self.additionModel:GetName()

	local skillAdditionModelsMap = {}
	local skills = self.cardModel:GetSkills()

	for slot, v in ipairs(skills) do
		local data = clone(v)
		data.lvl = 0
		local skillItemModel = SkillItemModel.new()
		skillItemModel:InitWithCache(data)
		
		local isAddition = true -- 贴纸只算周贴和月贴
		if skillItemModel:IsPasterSkill() then 
			if not skillItemModel:IsPasterByMonthAndWeek() then 
				isAddition = false
			end
		end

		if isAddition then 
			local skillLevel = skillsMap[tostring(data.exSid)] or skillsMap[tostring(data.sid)]
			if skillLevel then
				data.lvl = data.lvl + skillLevel
			end

			local slotLevel = skillSlotsMap[tostring(slot)] 
			if slotLevel then
				data.lvl = data.lvl + slotLevel
			end

			if skillsWithoutPasterAdd > 0 then
				if not skillItemModel:IsPasterSkill() then 
					data.lvl = data.lvl + skillsWithoutPasterAdd
				end
			end

			if skillsAllAdd > 0 then
				data.lvl = data.lvl + skillsAllAdd
			end
		end

		if data.lvl > 0 then 
			table.insert(skillAdditionModelsMap, skillItemModel)
		end
	end
	self.scrollView:refresh(skillAdditionModelsMap)
end

function FeatureAdditionBarView:EventCategoryChange(categoryType, changeKey)
	local additionType = self.additionModel:GetAdditionType()
	if additionType == FeatureSkillEnum.CategoryType.CurrentAll or additionType == categoryType then 
		self:RefreshAddition()
	end
end

function FeatureAdditionBarView:onDestroy()
	EventSystem.RemoveEvent("FeatureAddition_CategoryChange", self, self.EventCategoryChange)
end

return FeatureAdditionBarView

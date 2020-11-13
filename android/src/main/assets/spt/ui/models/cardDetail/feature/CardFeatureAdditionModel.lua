local Model = require("ui.models.Model")
local PlayerTalentSkill = require("data.PlayerTalentSkill")
local FeatureSkillEnum = require("ui.scene.cardDetail.feature.FeatureSkillEnum")
local CardFeatureAdditionModel = class(Model, "CardFeatureAdditionModel")

function CardFeatureAdditionModel:ctor()
	self:ResetData()
	self.featuresMap = {}
end

function CardFeatureAdditionModel:ResetData()
    self.attrsMap = {}
    self.percentsMap = {}
    self.skillsMap = {}
    self.skillSlotsMap = {}
    self.skillsWithoutPasterAdd = 0
    self.skillsAllAdd = 0
end

function CardFeatureAdditionModel:InitFeatureSkills(featureSkills)
	-- 只显示已开启的特性
    self.featuresMap = {}
	for slot, v in pairs(featureSkills) do
		local sid = v.sid
		local open = v.open
		if open then 
			local featureData = PlayerTalentSkill[tostring(sid)] or {}
			table.insert(self.featuresMap, featureData)
		end
	end
end

function CardFeatureAdditionModel:RefreshFeatureAddition(conditionType)
	self:ResetData()
	for i, v in pairs(self.featuresMap) do
		if v.conditionType == conditionType then 
			local playerTalentType = v.playerTalentType
			local playerTalentDetailSkill = v.playerTalentDetailSkill or {}
			local improvePlayerTalent = v.improvePlayerTalent or 0
			if playerTalentType == FeatureSkillEnum.PlayerTalentType.Skill then
				self:SetSkillAddition(playerTalentDetailSkill, improvePlayerTalent)
			elseif playerTalentType == FeatureSkillEnum.PlayerTalentType.Attr then
				self:SetAttrAddition(playerTalentDetailSkill, improvePlayerTalent)
			elseif playerTalentType == FeatureSkillEnum.PlayerTalentType.AttrPercent then
				self:SetPercentAddition(playerTalentDetailSkill, improvePlayerTalent)
			elseif playerTalentType == FeatureSkillEnum.PlayerTalentType.SkillSlot then
				self:SetSlotAddition(playerTalentDetailSkill, improvePlayerTalent)
			elseif playerTalentType == FeatureSkillEnum.PlayerTalentType.SkillWithOutPaster then
				self:SetSkillWithOutPasterAddition(improvePlayerTalent)
			elseif playerTalentType == FeatureSkillEnum.PlayerTalentType.SkillAll then
				self:SetSkillAllAddition(improvePlayerTalent)
			end
		end
	end
end

function CardFeatureAdditionModel:SetSkillAddition(playerTalentDetailSkill, improvePlayerTalent)
	for i, skillId in ipairs(playerTalentDetailSkill) do
		local skillAdd = self.skillsMap[tostring(skillId)]
		if skillAdd then
			self.skillsMap[tostring(skillId)] = skillAdd + tonumber(improvePlayerTalent)
		else
			self.skillsMap[tostring(skillId)] = tonumber(improvePlayerTalent)
		end
	end
end

function CardFeatureAdditionModel:SetAttrAddition(playerTalentDetailSkill, improvePlayerTalent)
	for i, attr in ipairs(playerTalentDetailSkill) do
		local attrAdd = self.attrsMap[tostring(attr)]
		if attrAdd then
			self.attrsMap[tostring(attr)] = attrAdd + tonumber(improvePlayerTalent)
		else
			self.attrsMap[tostring(attr)] = tonumber(improvePlayerTalent)
		end
	end
end

-- 写的是千分比转换成百分比
function CardFeatureAdditionModel:SetPercentAddition(playerTalentDetailSkill, improvePlayerTalent)
	for i, percent in ipairs(playerTalentDetailSkill) do
		local percentAdd = self.percentsMap[tostring(percent)]
		if percentAdd then
			self.percentsMap[tostring(percent)] = percentAdd + tonumber(improvePlayerTalent) / 10
		else
			self.percentsMap[tostring(percent)] = tonumber(improvePlayerTalent) / 10
		end
	end
end

function CardFeatureAdditionModel:SetSlotAddition(playerTalentDetailSkill, improvePlayerTalent)
	for i, slot in ipairs(playerTalentDetailSkill) do
		local slotAdd = self.skillSlotsMap[tostring(slot)]
		if slotAdd then
			self.skillSlotsMap[tostring(slot)] = slotAdd + tonumber(improvePlayerTalent) 
		else
			self.skillSlotsMap[tostring(slot)] = tonumber(improvePlayerTalent)
		end
	end
end

function CardFeatureAdditionModel:SetSkillWithOutPasterAddition(improvePlayerTalent)
	self.skillsWithoutPasterAdd = self.skillsWithoutPasterAdd + tonumber(improvePlayerTalent)
end

function CardFeatureAdditionModel:SetSkillAllAddition(improvePlayerTalent)
	self.skillsAllAdd = self.skillsAllAdd + tonumber(improvePlayerTalent)
end

-- 技能加成
function CardFeatureAdditionModel:GetSkillMap()
	return self.skillsMap 
end

-- 属性加成
function CardFeatureAdditionModel:GetAttrMap()
	return self.attrsMap 
end

-- 属性百分比加成
function CardFeatureAdditionModel:GePercentMap()
	return self.percentsMap 
end

-- 技能位置加成
function CardFeatureAdditionModel:GetSlotMap()
	return self.skillSlotsMap 
end

-- 技能不包含贴纸技能等级加成
function CardFeatureAdditionModel:GetSkillsWithoutPasterLevel()
	return self.skillsWithoutPasterAdd 
end

-- 所有技能等级加成
function CardFeatureAdditionModel:GetSkillsAllLevel()
	return self.skillsAllAdd 
end

function CardFeatureAdditionModel:SetAdditionType(additionType)
	self.additionType = additionType
end

function CardFeatureAdditionModel:GetAdditionType()
	return self.additionType
end

function CardFeatureAdditionModel:SetConditionType(conditionType)
	self.conditionType = conditionType
end

function CardFeatureAdditionModel:GetConditionType()
	return self.conditionType
end

function CardFeatureAdditionModel:GetName()
	return ""
end

function CardFeatureAdditionModel:HasIcon()
	return false
end

function CardFeatureAdditionModel:GetIcon()
	return ""
end

return CardFeatureAdditionModel

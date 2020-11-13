local CoachItemType = require("ui.models.coach.common.CoachItemType")
local FeatureSkillItemModel = require("ui.models.cardDetail.feature.FeatureSkillItemModel")
local FeatureSkillItemAppointModel = class(FeatureSkillItemModel, "FeatureSkillItemAppointModel")

function FeatureSkillItemAppointModel:ctor(id)
	FeatureSkillItemAppointModel.super.ctor(self, id)
	self.featureStatu = CoachItemType.SkillFuncType.Choose
	self.appointNum = 0
end

function FeatureSkillItemAppointModel:ChangeFeatureStatu(slot, sid)
	local itemFunctionAmount = self:GetItemFunctionAmount()
	if self.appointNum < itemFunctionAmount then
		if self.param[tostring(slot)] then 
			self.param[tostring(slot)] =  nil
			self.appointNum = self.appointNum - 1
		else
			self.param[tostring(slot)] = {["sid"] = sid, ["statu"] = CoachItemType.SkillFuncType.Appoint} 
			self.appointNum = self.appointNum + 1
		end
	else
		if self.param[tostring(slot)] then 
			self.param[tostring(slot)] =  nil
			self.appointNum = self.appointNum - 1
		end
	end

	-- 满足条件后默认状态更改
	if self.appointNum >= itemFunctionAmount then 
		self.featureStatu = CoachItemType.SkillFuncType.Normal
	else
		self.featureStatu = CoachItemType.SkillFuncType.Choose
	end
end

function FeatureSkillItemAppointModel:GetItemFunctionStatu(slot)
	local featureStatu = self.featureStatu
	if self.param[tostring(slot)] then 
		featureStatu = self.param[tostring(slot)].statu
	end
	return featureStatu
end

function FeatureSkillItemAppointModel:HasUseTip()
	local itemFunctionAmount = self:GetItemFunctionAmount()
	if self.appointNum < itemFunctionAmount then
		return true, lang.trans("coach_feature_operational6")
	end
	return false
end

function FeatureSkillItemAppointModel:HasOperational()
    return true
end

return FeatureSkillItemAppointModel

local CoachItemType = require("ui.models.coach.common.CoachItemType")
local FeatureSkillItemModel = require("ui.models.cardDetail.feature.FeatureSkillItemModel")
local FeatureSkillItemLockModel = class(FeatureSkillItemModel, "FeatureSkillItemLockModel")

function FeatureSkillItemLockModel:ctor(id)
	FeatureSkillItemLockModel.super.ctor(self, id)
	self.featureStatu = CoachItemType.SkillFuncType.Choose
	self.lockNum = 0
end

function FeatureSkillItemLockModel:ChangeFeatureStatu(slot, sid)
	local itemFunctionAmount = self:GetItemFunctionAmount()
	if self.lockNum < itemFunctionAmount then
		if self.param[tostring(slot)] then 
			self.param[tostring(slot)] =  nil
			self.lockNum = self.lockNum - 1
		else
			self.param[tostring(slot)] = {["sid"] = sid, ["statu"] = CoachItemType.SkillFuncType.Lock} 
			self.lockNum = self.lockNum + 1
		end
	else
		if self.param[tostring(slot)] then 
			self.param[tostring(slot)] =  nil
			self.lockNum = self.lockNum - 1
		end
	end

	-- 满足条件后默认状态更改
	if self.lockNum >= itemFunctionAmount then 
		self.featureStatu = CoachItemType.SkillFuncType.Normal
	else
		self.featureStatu = CoachItemType.SkillFuncType.Choose
	end
end

function FeatureSkillItemLockModel:HasUseTip()
	local itemFunctionAmount = self:GetItemFunctionAmount()
	if self.lockNum < itemFunctionAmount then
		return true, lang.trans("coach_feature_operational5")
	end
	return false
end

function FeatureSkillItemLockModel:GetItemFunctionStatu(slot)
	local featureStatu = self.featureStatu
	if self.param[tostring(slot)] then 
		featureStatu = self.param[tostring(slot)].statu
	end
	return featureStatu
end

function FeatureSkillItemLockModel:HasOperational()
    return true
end

return FeatureSkillItemLockModel

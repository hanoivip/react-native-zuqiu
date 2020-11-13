local PlayerTalentFunctionalityItem = require("data.PlayerTalentFunctionalityItem")
local CoachItemType = require("ui.models.coach.common.CoachItemType")
local Model = require("ui.models.Model")
local FeatureSkillItemModel = class(Model, "FeatureSkillItemModel")

function FeatureSkillItemModel:ctor(id)
	self.id = id
	self:InitWithStatic(id)
	self.featureStatu = CoachItemType.SkillFuncType.Normal
	self.param = {}
end

function FeatureSkillItemModel:InitWithStatic(id)
    self.staticData = PlayerTalentFunctionalityItem[tostring(id)] or {}
end

function FeatureSkillItemModel:GetId()
	return self.id
end

-- 物品类型（1为锁定型道具，2为增加型道具，3为指定替换道具，4为选择替换道具）
function FeatureSkillItemModel:GetItemFunction()
    return self.staticData.itemFunction
end

-- 道具可作用的数量
function FeatureSkillItemModel:GetItemFunctionAmount()
    return self.staticData.itemFunctionAmount
end

function FeatureSkillItemModel:ChangeFeatureStatu(slot, sid)
end

function FeatureSkillItemModel:GetItemFunctionStatu(slot)
    return self.featureStatu
end

function FeatureSkillItemModel:GetItemFunctionParam()
    return self.param
end

function FeatureSkillItemModel:HasOperational()
    return false
end

function FeatureSkillItemModel:HasUseTip()
	return false
end

return FeatureSkillItemModel

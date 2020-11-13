local CoachItemMapModel = require("ui.models.coach.common.CoachItemMapModel")
local FeatureChooseModel = require("ui.models.cardDetail.feature.FeatureChooseModel")
local DialogManager = require("ui.control.manager.DialogManager")
local CoachItemType = require("ui.models.coach.common.CoachItemType")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local FeatureChoosePageCtrl = class(BaseCtrl)

FeatureChoosePageCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/Feature/FeatureChoosePage.prefab"
FeatureChoosePageCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function FeatureChoosePageCtrl:Init()
    self.view.clickEquip = function(equipFeatureModel, itemSelectModel) self:OnClickEquip(equipFeatureModel, itemSelectModel) end
end

function FeatureChoosePageCtrl:Refresh(cardDetailModel, coachItemType, featureSelectModel)
    FeatureChoosePageCtrl.super.Refresh(self)
	self.cardDetailModel = cardDetailModel
    self.featureSelectModel = featureSelectModel
	self.coachItemMapModel = CoachItemMapModel.new()
	self.featureChooseModel = FeatureChooseModel.new()
	self.coachItemType = coachItemType
    self.view:InitView(coachItemType, featureSelectModel, self.coachItemMapModel, self.featureChooseModel)
end

-- 道具的要求判断是否满足条件
function FeatureChoosePageCtrl:IsAllowOperational(coachItemTyp, equipFeatureModel)
	local hasOperational = false
	local cardModel = self.cardDetailModel:GetCardModel()
	local featureModelsMap = cardModel:GetFeatureModelsMap()
	if coachItemTyp == CoachItemType.PlayerTalentFunctionalityItem then
		local featureNum = cardModel:GetFeaturesCount()
		local itemFunctionType = equipFeatureModel:GetItemFunction()
		if itemFunctionType == CoachItemType.ItemFuncType.Lock then
			-- 锁定道具
			local itemFunctionAmount = equipFeatureModel:GetItemFunctionAmount()
			if featureNum <= itemFunctionAmount then
				hasOperational = true
				DialogManager.ShowToast(lang.trans("coach_feature_operational1"))
			end
		elseif itemFunctionType == CoachItemType.ItemFuncType.Replace or
			itemFunctionType == CoachItemType.ItemFuncType.Choose then
			local itemFunctionAmount = equipFeatureModel:GetItemFunctionAmount()
			if featureNum < itemFunctionAmount then
				hasOperational = true
				DialogManager.ShowToast(lang.trans("coach_feature_operational2"))
			end
		elseif itemFunctionType == CoachItemType.ItemFuncType.Add then
			if featureNum >= CoachItemType.SkillFeaturesNum then
				hasOperational = true
				DialogManager.ShowToast(lang.trans("coach_feature_operational3"))
			end
		end
	elseif coachItemTyp == CoachItemType.PlayerTalentSkillBook then
		local selectSkillId = equipFeatureModel:GetSkillId()
		for k, model in pairs(featureModelsMap) do
			local featureId = model:GetId()
			if featureId == selectSkillId then
				hasOperational = true
				DialogManager.ShowToast(lang.trans("coach_feature_operational4"))
				break 
			end
		end
	end
	return hasOperational
end

function FeatureChoosePageCtrl:OnClickEquip(equipFeatureModel, itemSelectModel)
	local itemChoosetype = self.view:GetButtonState(equipFeatureModel, itemSelectModel)
	if itemChoosetype == CoachItemType.ItemChooseType.Unload then 
		EventSystem.SendEvent("CardFeatureUnloadHandle", self.coachItemType)
	elseif itemChoosetype == CoachItemType.ItemChooseType.Replace then
		local hasOperational = self:IsAllowOperational(self.coachItemType, equipFeatureModel)
		if hasOperational then return end
		EventSystem.SendEvent("CardFeatureReplaceHandle", self.coachItemType, equipFeatureModel)
	elseif itemChoosetype == CoachItemType.ItemChooseType.Equip then
		local hasOperational = self:IsAllowOperational(self.coachItemType, equipFeatureModel)
		if hasOperational then return end
		EventSystem.SendEvent("CardFeatureEquipHandle", self.coachItemType, equipFeatureModel)
	end
	self.view:Close()
end

function FeatureChoosePageCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function FeatureChoosePageCtrl:OnExitScene()
    self.view:OnExitScene()
end

return FeatureChoosePageCtrl

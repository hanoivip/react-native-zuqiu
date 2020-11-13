local CoachItemType = require("ui.models.coach.common.CoachItemType")
local DialogManager = require("ui.control.manager.DialogManager")
local CoachItemMapModel = require("ui.models.coach.common.CoachItemMapModel")
local FeatureBoxPopCtrl = require("ui.controllers.cardDetail.feature.FeatureBoxPopCtrl")
local FeatureBoxReplacePopCtrl = require("ui.controllers.cardDetail.feature.FeatureBoxReplacePopCtrl")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local FeaturePageCtrl = class(BaseCtrl, "FeaturePageCtrl")

function FeaturePageCtrl:ctor(view, content)
	self.targetItemId = nil
	self.targetFeatureId = nil
    self:Init(content)
end

function FeaturePageCtrl:Init(content)
    local pageObject, pageSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/Feature/FeaturePage.prefab")

    pageObject.transform:SetParent(content, false)
    self.pageView = pageSpt
    self.pageView.clickUse = function(skillModel, itemModel) self:OnBtnUse(skillModel, itemModel) end
    self.pageView.clickItem = function(itemModel) self:OnBtnItem(itemModel) end
	self.pageView.clickFeature = function(skillModel) self:OnBtnFeature(skillModel) end
	self.pageView.clickQuestion = function() self:OnBtnQuestion() end
	self.pageView.featureChoose = function(skillModel, oldSkill, pcid, skillBookId, itemId) self:FeatureChoose(skillModel, oldSkill, pcid, skillBookId, itemId) end
	self.pageView.clickFeatureInfo = function(featureModel) self:ClickFeatureInfo(featureModel) end
end

function FeaturePageCtrl:ClickFeatureInfo(featureModel)
	res.PushDialog("ui.controllers.cardDetail.feature.FeatureDetailCtrl", featureModel)
end

function FeaturePageCtrl:OnBtnUse(skillModel, itemModel)
    local cardModel = self.cardDetailModel:GetCardModel()
    if not cardModel:IsOperable() then 
        return 
    end

	if not skillModel then 
		return 
	end
	local cardModel = self.cardDetailModel:GetCardModel()
	local pcid = cardModel:GetPcid()
	local skillBookId = skillModel:GetId()
	local itemId, param
	local isChooseFeature = false
	if itemModel then
		itemId = itemModel:GetId()
		local itemParam = itemModel:GetItemFunctionParam()
		if next(itemParam) then 
			param = { }
			for slot, v in pairs(itemParam) do
				table.insert(param, slot)
			end
		end

		local hasTip, tip = itemModel:HasUseTip()
		if hasTip then
			DialogManager.ShowToast(tip)
			return
		end
		
		local itemFunctionType = itemModel:GetItemFunction()
		isChooseFeature = tobool(itemFunctionType == CoachItemType.ItemFuncType.Choose)
	end

    local confirmCallback = function()
        self.pageView:coroutine(function()
            local respone = req.cardFeatureByCoach(pcid, skillBookId, itemId, param)
            if api.success(respone) then
                local data = respone.val
                local coachItemMapModel = CoachItemMapModel.new()
                coachItemMapModel:UpdateCoachItemFromRewards(data.cost)
                if isChooseFeature then
                    FeatureBoxReplacePopCtrl.new(skillModel, data.oldSkill, pcid, skillBookId, itemId)
                else
                    FeatureBoxPopCtrl.new(skillModel, data.oldSkill)
                    self.cardDetailModel:ResetCardData(data.card)
                end
            else
                self.pageView:InitialFeature()
            end
        end)
    end

    local title = lang.trans("tips")
    local msg = lang.trans("card_feature_tip", skillModel:GetName())
    -- 二次确认
    DialogManager.ShowConfirmPop(title, msg, confirmCallback)
end

function FeaturePageCtrl:FeatureChoose(skillModel, oldSkill, pcid, skillBookId, itemId)
	self.pageView:coroutine(function()
		local respone = req.cardFeatureChooseByCoach(pcid, skillBookId, itemId)
		if api.success(respone) then
			local data = respone.val
			FeatureBoxPopCtrl.new(skillModel, oldSkill)
			self.cardDetailModel:ResetCardData(data.card)
		else
			self.pageView:InitialFeature()
		end
	end)
end

function FeaturePageCtrl:OnBtnItem(itemModel)
    local cardModel = self.cardDetailModel:GetCardModel()
    if not cardModel:IsOperable() then 
        return 
    end
	res.PushDialog("ui.controllers.cardDetail.feature.FeatureChoosePageCtrl", self.cardDetailModel, CoachItemType.PlayerTalentFunctionalityItem, itemModel)
end

function FeaturePageCtrl:OnBtnFeature(skillModel)
    local cardModel = self.cardDetailModel:GetCardModel()
    if not cardModel:IsOperable() then 
        return 
    end
	res.PushDialog("ui.controllers.cardDetail.feature.FeatureChoosePageCtrl", self.cardDetailModel, CoachItemType.PlayerTalentSkillBook, skillModel)
end

function FeaturePageCtrl:OnBtnQuestion()
	local titleText = lang.trans("coach_feature_title")
	local contentText = lang.trans("feature_desc")
	DialogManager.ShowAlertPop(titleText, contentText) 
end

function FeaturePageCtrl:EnterScene()
    self.pageView:EnterScene()
end

function FeaturePageCtrl:ExitScene()
    self.pageView:ExitScene()
end

function FeaturePageCtrl:InitView(cardDetailModel)
    self.cardDetailModel = cardDetailModel
    self.pageView:InitView(cardDetailModel)
end

function FeaturePageCtrl:ShowPageVisible(isVisible)
    self.pageView:ShowPageVisible(isVisible)
end

return FeaturePageCtrl

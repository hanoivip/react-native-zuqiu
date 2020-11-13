local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Color = UnityEngine.Color
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local CardFeatureModel = require("ui.models.cardDetail.CardFeatureModel")
local FeatureSKillState = require("ui.scene.cardDetail.feature.FeatureSKillState")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local FeatureReplaceView = class(unity.base)

function FeatureReplaceView:ctor()
    self.canvasGroup = self.___ex.canvasGroup
    self.btnCancel = self.___ex.btnCancel
    self.btnConfirm = self.___ex.btnConfirm
    self.contentRect = self.___ex.contentRect
	self.contentText = self.___ex.contentText
	self.arrow = self.___ex.arrow
end

function FeatureReplaceView:GetFeatureSkillRes()
    if not self.featureSkillRes then
        self.featureSkillRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/Feature/FeatureSkill.prefab")
    end
    return self.featureSkillRes
end

function FeatureReplaceView:InitView(skillModel, oldSkill, pcid, skillBookId, itemId)
	self.skillModel = skillModel
	self.oldSkill = oldSkill
	self.pcid = pcid
	self.skillBookId = skillBookId
	self.itemId = itemId
	local models = {}
	local skillId = skillModel:GetSkillId()
	local bookFeatureModel = CardFeatureModel.new(skillId)
    bookFeatureModel:SetFeatureSKillState(FeatureSKillState.Enable)
	local featureCount = 1
	if oldSkill and oldSkill ~= "" then 
		featureCount= 2
		local cardFeatureModel = CardFeatureModel.new(oldSkill)
        cardFeatureModel:SetFeatureSKillState(FeatureSKillState.Enable)
		models[1] = cardFeatureModel
		models[2] = bookFeatureModel
		self.contentText.text = lang.trans("coach_feature_replace_tip")
	else
		models[1] = bookFeatureModel
		self.contentText.text = lang.trans("coach_feature_replace_tip2")
	end

	for i = 1, featureCount do
		local obj = Object.Instantiate(self:GetFeatureSkillRes())
		local spt = res.GetLuaScript(obj)
		obj.transform:SetParent(self.contentRect, false)
		spt:InitView(models[i])
		spt:SetNameColor(Color.white)
	end
end

function FeatureReplaceView:start()
    self.btnCancel:regOnButtonClick(function (eventData)
		if self.clickCancel then 
			self.clickCancel()
		end
    end)
    self.btnConfirm:regOnButtonClick(function (eventData)
		if self.clickConfirm then 
			self.clickConfirm(self.skillModel, self.oldSkill, self.pcid, self.skillBookId, self.itemId)
		end
    end)

    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function FeatureReplaceView:Close()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)

	self.featureSkillRes = nil
end

return FeatureReplaceView

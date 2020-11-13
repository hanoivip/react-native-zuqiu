local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Color = UnityEngine.Color
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CardFeatureModel = require("ui.models.cardDetail.CardFeatureModel")
local FeatureSKillState = require("ui.scene.cardDetail.feature.FeatureSKillState")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local FeatureBoxPopView = class(unity.base)

function FeatureBoxPopView:ctor()
    self.confirm = self.___ex.confirm
	self.arrow = self.___ex.arrow
    self.featureSkillArea = self.___ex.featureSkillArea
end 

function FeatureBoxPopView:start()
    DialogAnimation.Appear(self.transform)
    self.confirm:regOnButtonClick(function()
        self:OnBtnConfirm()
    end)
end

function FeatureBoxPopView:OnBtnConfirm()
    if self.clickConfirm then 
        self.clickConfirm()
    end
end

function FeatureBoxPopView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

function FeatureBoxPopView:GetFeatureSkillRes()
    if not self.featureSkillRes then
        self.featureSkillRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/Feature/FeatureSkill.prefab")
    end
    return self.featureSkillRes
end

function FeatureBoxPopView:InitView(skillModel, oldSkill)
	local skillId = skillModel:GetSkillId()
	local bookFeatureModel = CardFeatureModel.new(skillId)
    bookFeatureModel:SetFeatureSKillState(FeatureSKillState.Enable)
	local models = {}
	local featureCount = 2

	if oldSkill and oldSkill ~= "" then
		local cardFeatureModel = CardFeatureModel.new(oldSkill)
        cardFeatureModel:SetFeatureSKillState(FeatureSKillState.Enable)
		models[1] = cardFeatureModel
		models[2] = bookFeatureModel
	else
		featureCount = 1
		models[1] = bookFeatureModel
	end

	for i = 1, featureCount do
		local obj = Object.Instantiate(self:GetFeatureSkillRes())
		local spt = res.GetLuaScript(obj)
		obj.transform:SetParent(self.featureSkillArea, false)
		spt:InitView(models[i])
		spt:SetNameColor(Color.white)
	end
    GameObjectHelper.FastSetActive(self.arrow.gameObject, featureCount > 1)
end

return FeatureBoxPopView
